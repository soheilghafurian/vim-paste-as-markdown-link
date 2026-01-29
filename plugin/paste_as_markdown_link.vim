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

" Commands
command! PasteAsMarkdownLink call paste_as_markdown_link#paste()

" Plug mappings for user customization
nnoremap <silent> <Plug>(PasteAsMarkdownLink) :call paste_as_markdown_link#paste()<CR>
inoremap <silent> <Plug>(PasteAsMarkdownLinkInsert) <C-o>:call paste_as_markdown_link#paste()<CR>
