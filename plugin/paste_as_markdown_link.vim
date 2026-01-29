" paste_as_markdown_link.vim - Convert HTML links to markdown when pasting
" Maintainer: Your Name
" Version: 1.0.0
" License: MIT

" Guard against multiple loads
if exists('g:loaded_paste_as_markdown_link')
  finish
endif
let g:loaded_paste_as_markdown_link = 1

" Check Vim version (require Vim 8+)
if v:version < 800
  echohl WarningMsg
  echom 'paste_as_markdown_link requires Vim 8.0 or later'
  echohl None
  finish
endif

" Configuration defaults
if !exists('g:paste_as_markdown_link_enabled')
  let g:paste_as_markdown_link_enabled = 1
endif

if !exists('g:paste_as_markdown_link_linux_tool')
  let g:paste_as_markdown_link_linux_tool = 'xclip'
endif

" Filetypes where the plugin is active (default: markdown only)
if !exists('g:paste_as_markdown_link_filetypes')
  let g:paste_as_markdown_link_filetypes = ['markdown', 'md']
endif

" Plug mappings for user customization (always available for manual mapping)
nnoremap <silent> <Plug>(PasteAsMarkdownLink) :call paste_as_markdown_link#paste()<CR>
inoremap <silent> <Plug>(PasteAsMarkdownLinkInsert) <C-o>:call paste_as_markdown_link#paste()<CR>

" Buffer-local command setup for supported filetypes
function! s:setup_buffer() abort
  if index(g:paste_as_markdown_link_filetypes, &filetype) >= 0
    command! -buffer PasteAsMarkdownLink call paste_as_markdown_link#paste()
  endif
endfunction

augroup paste_as_markdown_link
  autocmd!
  autocmd FileType * call s:setup_buffer()
augroup END
