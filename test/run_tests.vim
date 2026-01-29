" test/run_tests.vim - Unit tests for paste_as_markdown_link
" Run with: vim -es -S test/run_tests.vim

" Initialize test counters
let s:tests_run = 0
let s:tests_passed = 0
let s:tests_failed = 0
let s:test_output = []

" Test assertion helpers
function! s:assert_equal(expected, actual, message) abort
  let s:tests_run += 1
  if a:expected ==# a:actual
    let s:tests_passed += 1
    call add(s:test_output, '  PASS: ' . a:message)
    return 1
  else
    let s:tests_failed += 1
    call add(s:test_output, '  FAIL: ' . a:message)
    call add(s:test_output, '    Expected: ' . string(a:expected))
    call add(s:test_output, '    Actual:   ' . string(a:actual))
    return 0
  endif
endfunction

function! s:assert_match(pattern, actual, message) abort
  let s:tests_run += 1
  if a:actual =~# a:pattern
    let s:tests_passed += 1
    call add(s:test_output, '  PASS: ' . a:message)
    return 1
  else
    let s:tests_failed += 1
    call add(s:test_output, '  FAIL: ' . a:message)
    call add(s:test_output, '    Pattern: ' . a:pattern)
    call add(s:test_output, '    Actual:  ' . string(a:actual))
    return 0
  endif
endfunction

function! s:assert_not_empty(actual, message) abort
  let s:tests_run += 1
  if !empty(a:actual)
    let s:tests_passed += 1
    call add(s:test_output, '  PASS: ' . a:message)
    return 1
  else
    let s:tests_failed += 1
    call add(s:test_output, '  FAIL: ' . a:message)
    call add(s:test_output, '    Value was empty')
    return 0
  endif
endfunction

" Load the plugin
let s:plugin_root = expand('<sfile>:p:h:h')
execute 'source ' . s:plugin_root . '/plugin/paste_as_markdown_link.vim'
execute 'source ' . s:plugin_root . '/autoload/paste_as_markdown_link.vim'

" ============================================================================
" Test: HTML to Markdown Conversion
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing HTML to Markdown Conversion:')

" Test simple anchor tag
let s:input = '<a href="https://example.com">Click here</a>'
let s:expected = '[Click here](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Simple anchor tag conversion')

" Test anchor with single quotes
let s:input = "<a href='https://example.com'>Click here</a>"
let s:expected = '[Click here](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Anchor with single quotes')

" Test multiple anchors
let s:input = '<a href="https://one.com">One</a> and <a href="https://two.com">Two</a>'
let s:expected = '[One](https://one.com) and [Two](https://two.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Multiple anchor tags')

" Test anchor with other attributes
let s:input = '<a class="link" href="https://example.com" target="_blank">Link</a>'
let s:expected = '[Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Anchor with other attributes')

" Test anchor with href not first
let s:input = '<a target="_blank" href="https://example.com">Link</a>'
let s:expected = '[Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Anchor with href not first attribute')

" Test empty anchor text (should use URL)
let s:input = '<a href="https://example.com"></a>'
let s:expected = '[https://example.com](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Empty anchor text uses URL')

" Test anchor with nested span
let s:input = '<a href="https://example.com"><span>Nested text</span></a>'
let s:expected = '[Nested text](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Anchor with nested span')

" Test text mixed with anchors
let s:input = 'Check out <a href="https://example.com">this link</a> for more info'
let s:expected = 'Check out [this link](https://example.com) for more info'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Text mixed with anchor')

" Test stripping other HTML tags
let s:input = '<p><strong>Bold</strong> and <a href="https://example.com">link</a></p>'
let s:expected = 'Bold and [link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Strip other HTML tags')

" ============================================================================
" Test: HTML Entity Decoding
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing HTML Entity Decoding:')

" Test &amp;
let s:input = '<a href="https://example.com?a=1&amp;b=2">Link</a>'
let s:expected = '[Link](https://example.com?a=1&b=2)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode &amp; entity')

" Test &lt; and &gt;
let s:input = 'Use &lt;div&gt; tags'
let s:expected = 'Use <div> tags'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode &lt; and &gt; entities')

" Test &quot;
let s:input = 'He said &quot;hello&quot;'
let s:expected = 'He said "hello"'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode &quot; entity')

" Test &nbsp;
let s:input = 'Word&nbsp;Word'
let s:expected = 'Word Word'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode &nbsp; entity')

" Test numeric entity (decimal)
let s:input = '&#65;&#66;&#67;'
let s:expected = 'ABC'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode numeric entities (decimal)')

" Test numeric entity (hex)
let s:input = '&#x41;&#x42;&#x43;'
let s:expected = 'ABC'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Decode numeric entities (hex)')

" ============================================================================
" Test: Edge Cases
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing Edge Cases:')

" Test plain text (no HTML)
let s:input = 'Just plain text with https://example.com URL'
let s:expected = 'Just plain text with https://example.com URL'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Plain text passes through unchanged')

" Test empty input
let s:input = ''
let s:expected = ''
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Empty input returns empty')

" Test URL with special characters
let s:input = '<a href="https://example.com/path?query=value&amp;other=123#anchor">Link</a>'
let s:expected = '[Link](https://example.com/path?query=value&other=123#anchor)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'URL with query params and anchor')

" Test link text with special markdown chars
let s:input = '<a href="https://example.com">Text with [brackets]</a>'
let s:expected = '[Text with [brackets]](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Link text with brackets')

" Test uppercase tags
let s:input = '<A HREF="https://example.com">Link</A>'
let s:expected = '[Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Uppercase HTML tags')

" Test whitespace in link text
let s:input = '<a href="https://example.com">  Spaced Text  </a>'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_match('\[Spaced Text\]', s:result, 'Whitespace trimmed from link text')

" ============================================================================
" Test: Platform Detection
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing Platform Detection:')

let s:platform = paste_as_markdown_link#test_platform()
call s:assert_not_empty(s:platform, 'Platform detection returns a value')
call s:assert_match('^\(macos\|linux\|unknown\)$', s:platform, 'Platform is valid value')

" ============================================================================
" Test: Plugin Configuration
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing Plugin Configuration:')

" Test default enabled state
call s:assert_equal(1, g:paste_as_markdown_link_enabled, 'Plugin enabled by default')

" Test disable/enable
let g:paste_as_markdown_link_enabled = 0
call s:assert_equal(0, g:paste_as_markdown_link_enabled, 'Plugin can be disabled')
let g:paste_as_markdown_link_enabled = 1

" Test filetypes config exists
call s:assert_equal(1, exists('g:paste_as_markdown_link_filetypes'), 'Filetypes config exists')
call s:assert_equal(['markdown', 'md'], g:paste_as_markdown_link_filetypes, 'Default filetypes are markdown')

" Test Plug mapping exists
call s:assert_equal(1, hasmapto('paste_as_markdown_link#paste()'), 'Plug mapping exists')

" ============================================================================
" Test: Additional Edge Cases
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, 'Testing Additional Edge Cases:')

" Test deeply nested HTML
let s:input = '<a href="https://example.com"><strong><em>Bold Italic</em></strong></a>'
let s:expected = '[Bold Italic](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Deeply nested HTML in anchor')

" Test multiple links in paragraph
let s:input = '<p>Visit <a href="https://one.com">One</a>, <a href="https://two.com">Two</a>, and <a href="https://three.com">Three</a>.</p>'
let s:expected = 'Visit [One](https://one.com), [Two](https://two.com), and [Three](https://three.com).'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Multiple links in paragraph')

" Test mixed case attributes
let s:input = '<a HREF="https://example.com" CLASS="link">Mixed Case</a>'
let s:expected = '[Mixed Case](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Mixed case attributes')

" Test link with newlines in text
let s:input = "<a href=\"https://example.com\">Line 1\nLine 2</a>"
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_match('Line 1.*Line 2', s:result, 'Newlines normalized in link text')

" Test self-closing tags nearby
let s:input = '<br/><a href="https://example.com">Link</a><br/>'
let s:expected = '[Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Self-closing tags stripped')

" Test HTML comments
let s:input = '<!-- comment --><a href="https://example.com">Link</a>'
let s:expected = '[Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'HTML comments stripped')

" Test URL with percent encoding
let s:input = '<a href="https://example.com/path%20with%20spaces">Link</a>'
let s:expected = '[Link](https://example.com/path%20with%20spaces)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'URL with percent encoding preserved')

" Test link in table cell
let s:input = '<td><a href="https://example.com">Cell Link</a></td>'
let s:expected = '[Cell Link](https://example.com)'
let s:result = paste_as_markdown_link#test_convert(s:input)
call s:assert_equal(s:expected, s:result, 'Link in table cell')

" Test helper functions directly
call add(s:test_output, '')
call add(s:test_output, 'Testing Helper Functions:')

" Test make_link with empty text
let s:result = paste_as_markdown_link#test_make_link('https://example.com', '')
let s:expected = '[https://example.com](https://example.com)'
call s:assert_equal(s:expected, s:result, 'make_link with empty text uses URL')

" Test make_link with HTML in text
let s:result = paste_as_markdown_link#test_make_link('https://example.com', '<b>Bold</b>')
let s:expected = '[Bold](https://example.com)'
call s:assert_equal(s:expected, s:result, 'make_link strips HTML from text')

" Test decode_entities directly
let s:result = paste_as_markdown_link#test_decode_entities('&amp;&lt;&gt;&quot;')
let s:expected = '&<>"'
call s:assert_equal(s:expected, s:result, 'decode_entities handles multiple entities')

" ============================================================================
" Print Results
" ============================================================================

call add(s:test_output, '')
call add(s:test_output, '============================================================')
call add(s:test_output, 'Test Results: ' . s:tests_passed . '/' . s:tests_run . ' passed')
if s:tests_failed > 0
  call add(s:test_output, 'FAILURES: ' . s:tests_failed)
endif
call add(s:test_output, '============================================================')

" Write output to file and stdout
let s:output_file = s:plugin_root . '/test/results.txt'
call writefile(s:test_output, s:output_file)

" Print to stdout
for line in s:test_output
  echom line
endfor

" Exit with appropriate code
if s:tests_failed > 0
  cquit!
else
  quit!
endif
