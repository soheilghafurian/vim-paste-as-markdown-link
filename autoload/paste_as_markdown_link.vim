" autoload/paste_as_markdown_link.vim - Core functions for paste_as_markdown_link
" Maintainer: Your Name
" Version: 1.0.0
" License: MIT

" Main paste function
function! paste_as_markdown_link#paste() abort
  if !g:paste_as_markdown_link_enabled
    " Plugin disabled, do normal paste
    execute 'normal! "+p'
    return
  endif

  let l:html_content = s:get_html_clipboard()

  if !empty(l:html_content)
    let l:markdown = s:convert_html_to_markdown(l:html_content)
    if !empty(l:markdown)
      call s:insert_text(l:markdown)
      return
    endif
  endif

  " Fallback to plain text paste
  let l:plain = s:get_plain_clipboard()
  if !empty(l:plain)
    call s:insert_text(l:plain)
  endif
endfunction

" Detect the current platform
function! s:detect_platform() abort
  if has('mac') || has('macunix') || system('uname') =~? 'darwin'
    return 'macos'
  elseif has('unix')
    return 'linux'
  else
    return 'unknown'
  endif
endfunction

" Get HTML content from clipboard (platform-specific)
function! s:get_html_clipboard() abort
  let l:platform = s:detect_platform()

  if l:platform ==# 'macos'
    return s:get_html_clipboard_macos()
  elseif l:platform ==# 'linux'
    return s:get_html_clipboard_linux()
  endif

  return ''
endfunction

" Get HTML clipboard on macOS using osascript
function! s:get_html_clipboard_macos() abort
  " AppleScript to get HTML clipboard and decode from hex
  let l:script = 'use framework "Foundation"' . "\n"
  let l:script .= 'use framework "AppKit"' . "\n"
  let l:script .= 'set pb to current application''s NSPasteboard''s generalPasteboard()' . "\n"
  let l:script .= 'set htmlType to current application''s NSPasteboardTypeHTML' . "\n"
  let l:script .= 'set htmlData to pb''s stringForType:htmlType' . "\n"
  let l:script .= 'if htmlData is missing value then' . "\n"
  let l:script .= '  return ""' . "\n"
  let l:script .= 'else' . "\n"
  let l:script .= '  return htmlData as text' . "\n"
  let l:script .= 'end if'

  let l:result = system('osascript -e ' . shellescape(l:script))

  " Check for errors
  if v:shell_error != 0
    return ''
  endif

  " Remove trailing newline
  let l:result = substitute(l:result, '\n$', '', '')

  return l:result
endfunction

" Get HTML clipboard on Linux using xclip or xsel
function! s:get_html_clipboard_linux() abort
  let l:tool = g:paste_as_markdown_link_linux_tool

  if l:tool ==# 'xclip'
    " Check if text/html type is available
    let l:types = system('xclip -selection clipboard -t TARGETS -o 2>/dev/null')
    if l:types !~# 'text/html'
      return ''
    endif
    let l:result = system('xclip -selection clipboard -t text/html -o 2>/dev/null')
  elseif l:tool ==# 'xsel'
    " xsel doesn't support HTML directly, try xclip as fallback
    let l:result = system('xclip -selection clipboard -t text/html -o 2>/dev/null')
  else
    return ''
  endif

  if v:shell_error != 0
    return ''
  endif

  return l:result
endfunction

" Get plain text from clipboard
function! s:get_plain_clipboard() abort
  let l:platform = s:detect_platform()

  if l:platform ==# 'macos'
    let l:result = system('pbpaste')
  elseif l:platform ==# 'linux'
    let l:tool = g:paste_as_markdown_link_linux_tool
    if l:tool ==# 'xclip'
      let l:result = system('xclip -selection clipboard -o 2>/dev/null')
    elseif l:tool ==# 'xsel'
      let l:result = system('xsel --clipboard --output 2>/dev/null')
    else
      let l:result = system('xclip -selection clipboard -o 2>/dev/null')
    endif
  else
    " Try using Vim's + register
    let l:result = getreg('+')
  endif

  if v:shell_error != 0
    " Fallback to Vim's clipboard register
    return getreg('+')
  endif

  return l:result
endfunction

" Convert HTML content to markdown
function! s:convert_html_to_markdown(html) abort
  let l:result = a:html

  " Convert anchor tags to markdown links
  " Pattern matches <a href="url">text</a> with various attribute orders
  " Handle href with double quotes
  let l:result = substitute(l:result,
        \ '<a\s[^>]*href="\([^"]*\)"[^>]*>\([^<]*\)</a>',
        \ '[\2](\1)', 'gi')

  " Handle href with single quotes
  let l:result = substitute(l:result,
        \ "<a\\s[^>]*href='\\([^']*\\)'[^>]*>\\([^<]*\\)</a>",
        \ '[\\2](\\1)', 'gi')

  " Handle links with nested tags (e.g., <a href="url"><span>text</span></a>)
  " First, extract just the text content from nested tags
  let l:result = substitute(l:result,
        \ '<a\s[^>]*href="\([^"]*\)"[^>]*>\(\_.\{-}\)</a>',
        \ '\=s:make_markdown_link(submatch(1), submatch(2))', 'gi')

  " Handle empty link text - use URL as text
  let l:result = substitute(l:result, '\[\](\([^)]*\))', '[\1](\1)', 'g')

  " Strip remaining HTML tags
  let l:result = substitute(l:result, '<[^>]*>', '', 'g')

  " Decode common HTML entities
  let l:result = s:decode_html_entities(l:result)

  " Clean up excessive whitespace
  let l:result = substitute(l:result, '\s\+', ' ', 'g')
  let l:result = substitute(l:result, '^\s\+\|\s\+$', '', 'g')

  return l:result
endfunction

" Helper to create markdown link, stripping HTML from anchor text
function! s:make_markdown_link(url, text) abort
  " Strip HTML tags from the link text
  let l:clean_text = substitute(a:text, '<[^>]*>', '', 'g')
  " Decode HTML entities in the text
  let l:clean_text = s:decode_html_entities(l:clean_text)
  " Trim whitespace
  let l:clean_text = substitute(l:clean_text, '^\s\+\|\s\+$', '', 'g')

  " If text is empty, use URL
  if empty(l:clean_text)
    let l:clean_text = a:url
  endif

  return '[' . l:clean_text . '](' . a:url . ')'
endfunction

" Decode common HTML entities
function! s:decode_html_entities(text) abort
  let l:result = a:text

  " Named entities
  let l:result = substitute(l:result, '&amp;', '\&', 'g')
  let l:result = substitute(l:result, '&lt;', '<', 'g')
  let l:result = substitute(l:result, '&gt;', '>', 'g')
  let l:result = substitute(l:result, '&quot;', '"', 'g')
  let l:result = substitute(l:result, '&apos;', "'", 'g')
  let l:result = substitute(l:result, '&nbsp;', ' ', 'g')
  let l:result = substitute(l:result, '&#160;', ' ', 'g')

  " Numeric entities (decimal)
  let l:result = substitute(l:result, '&#\(\d\+\);',
        \ '\=nr2char(str2nr(submatch(1)))', 'g')

  " Numeric entities (hexadecimal)
  let l:result = substitute(l:result, '&#x\(\x\+\);',
        \ '\=nr2char(str2nr(submatch(1), 16))', 'g')

  return l:result
endfunction

" Insert text at cursor position
function! s:insert_text(text) abort
  " Use put command with a temporary register
  let l:save_reg = getreg('z')
  let l:save_regtype = getregtype('z')

  call setreg('z', a:text, 'c')

  " Check if we're at end of line to decide put behavior
  if col('.') >= col('$') - 1
    execute 'normal! "zp'
  else
    execute 'normal! "zP'
  endif

  " Restore register
  call setreg('z', l:save_reg, l:save_regtype)
endfunction
