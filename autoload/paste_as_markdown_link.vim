" autoload/paste_as_markdown_link.vim - Core functions for paste_as_markdown_link
" Maintainer: Your Name
" Version: 1.0.0
" License: MIT

" Cached platform detection result
let s:cached_platform = ''

" Path to this script's directory (resolved at script load time)
let s:script_dir = expand('<sfile>:p:h') . '/'

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
  if !empty(s:cached_platform)
    return s:cached_platform
  endif

  if has('mac') || has('macunix') || system('uname') =~? 'darwin'
    let s:cached_platform = 'macos'
  elseif has('unix')
    let s:cached_platform = 'linux'
  else
    let s:cached_platform = 'unknown'
  endif

  return s:cached_platform
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

" Get the path to the compiled Swift clipboard helper binary
function! s:get_swift_helper_path() abort
  return s:script_dir . 'clipboard_html'
endfunction

" Compile the Swift clipboard helper if it doesn't exist yet
function! s:ensure_swift_helper() abort
  let l:binary = s:get_swift_helper_path()
  if filereadable(l:binary)
    return l:binary
  endif

  let l:source = l:binary . '.swift'
  if !filereadable(l:source)
    return ''
  endif

  silent call system('swiftc -O -o ' . shellescape(l:binary) . ' ' . shellescape(l:source))
  if v:shell_error != 0
    return ''
  endif

  return l:binary
endfunction

" Get HTML clipboard on macOS using compiled Swift helper (fast) or osascript (fallback)
function! s:get_html_clipboard_macos() abort
  " Try the fast compiled Swift helper first
  let l:binary = s:ensure_swift_helper()
  if !empty(l:binary)
    let l:result = system(shellescape(l:binary))
    if v:shell_error == 0
      return l:result
    endif
  endif

  " Fallback: AppleScript to get HTML clipboard (slower, ~1-3s)
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

  " Convert all anchor tags to markdown links using a function for proper handling
  " This pattern matches any <a> tag with href (handles both quote styles, nested content, etc.)
  " Use \c for case-insensitive matching
  let l:result = substitute(l:result,
        \ '\c<a\s[^>]*href=["'']\([^"'']*\)["''][^>]*>\(\_.\{-}\)</a>',
        \ '\=s:make_markdown_link(submatch(1), submatch(2))', 'g')

  " Handle empty link text - use URL as text
  let l:result = substitute(l:result, '\[\](\([^)]*\))', '[\1](\1)', 'g')

  " Strip remaining HTML tags
  let l:result = substitute(l:result, '<[^>]*>', '', 'g')

  " Decode common HTML entities
  let l:result = s:decode_html_entities(l:result)

  " Clean up excessive whitespace (but preserve single spaces between words)
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
  " Trim leading whitespace
  let l:clean_text = substitute(l:clean_text, '^\s*', '', '')
  " Trim trailing whitespace
  let l:clean_text = substitute(l:clean_text, '\s*$', '', '')
  " Normalize internal whitespace
  let l:clean_text = substitute(l:clean_text, '\s\+', ' ', 'g')

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

" ============================================================================
" Test Helper Functions (exposed for unit testing)
" ============================================================================

" Test helper: convert HTML to markdown
function! paste_as_markdown_link#test_convert(html) abort
  return s:convert_html_to_markdown(a:html)
endfunction

" Test helper: detect platform
function! paste_as_markdown_link#test_platform() abort
  return s:detect_platform()
endfunction

" Test helper: decode HTML entities
function! paste_as_markdown_link#test_decode_entities(text) abort
  return s:decode_html_entities(a:text)
endfunction

" Test helper: make markdown link
function! paste_as_markdown_link#test_make_link(url, text) abort
  return s:make_markdown_link(a:url, a:text)
endfunction
