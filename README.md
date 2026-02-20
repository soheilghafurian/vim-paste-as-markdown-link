# Paste as Markdown Link

A Vim plugin that converts HTML links in your clipboard to markdown format when pasting. Copy a link from your browser or word processor, and paste it as a clean markdown link.

## Features

- Converts `<a href="url">text</a>` to `[text](url)`
- **Image paste:** detects image data on the clipboard, saves it to a `<buffer>.assets/` folder, and inserts a markdown image link `![alt](path)`
- Plain text URLs stay as plain text (only HTML links are converted)
- Cross-platform support: macOS, Linux Mint, MX Linux
- Falls back to normal paste when no HTML content is available

## Requirements

- Vim 8.0 or later
- **macOS:** No additional dependencies (uses built-in `osascript` and `pbpaste`)
- **Linux:** Requires `xclip`

### Installing xclip on Linux

```bash
# Debian/Ubuntu/Linux Mint/MX Linux
sudo apt install xclip

# Fedora
sudo dnf install xclip

# Arch Linux
sudo pacman -S xclip
```

## Installation

### Using Vundle

Add this line to your `.vimrc`:

```vim
Plugin 'soheilghafurian/vim-paste-as-markdown-link'
```

Then run `:PluginInstall` in Vim.

### Using vim-plug

```vim
Plug 'soheilghafurian/vim-paste-as-markdown-link'
```

Then run `:PlugInstall` in Vim.

### Manual Installation

Clone this repository into your Vim packages directory:

```bash
# Vim 8+ native package manager
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/soheilghafurian/vim-paste-as-markdown-link.git
```

## Usage

### Command

```vim
:PasteAsMarkdownLink
```

### Mappings

The plugin provides `<Plug>` mappings for customization. Add your preferred mappings to your `.vimrc`:

```vim
" Normal mode — paste as markdown link at the cursor
nmap <leader>p <Plug>(PasteAsMarkdownLink)

" Insert mode — paste as markdown link without leaving insert mode
imap <C-p> <Plug>(PasteAsMarkdownLinkInsert)
```

You can substitute `<leader>p` and `<C-p>` with any keys you prefer, for example:

```vim
nmap <C-S-v> <Plug>(PasteAsMarkdownLink)
imap <C-S-v> <Plug>(PasteAsMarkdownLinkInsert)
```

### Workflow

1. Copy a link from your browser, Word, Google Docs, etc.
2. In Vim, use your mapped key or run `:PasteAsMarkdownLink`
3. The link is inserted as `[link text](url)`

### Image Paste

When the clipboard contains image data (e.g. from a screenshot):

1. Take a screenshot to clipboard (macOS: `Cmd+Shift+4` then `Ctrl`, Linux: screenshot tool with "copy to clipboard")
2. In Vim, use your mapped key or run `:PasteAsMarkdownLink`
3. You'll be prompted for an image name (press Enter for an auto-generated timestamp name)
4. The image is saved to `<buffer-name>.assets/img-<name>.png`
5. A markdown image link is inserted: `![img-<name>](./<buffer-name>.assets/img-<name>.png)`
6. The cursor is positioned on the alt text so you can edit it immediately

## Configuration

### Supported Filetypes

By default, the `:PasteAsMarkdownLink` command is only available in markdown files. To enable it for other filetypes:

```vim
" Add more filetypes (default: ['markdown', 'md'])
let g:paste_as_markdown_link_filetypes = ['markdown', 'md', 'text', 'rst']
```

To use in all filetypes, add a global mapping in your `.vimrc`:

```vim
nmap <leader>p <Plug>(PasteAsMarkdownLink)
```

### Enable/Disable Plugin

```vim
" Disable the plugin (default: 1)
let g:paste_as_markdown_link_enabled = 0
```

### Linux Clipboard Tool

```vim
" Set preferred clipboard tool on Linux (default: 'xclip')
let g:paste_as_markdown_link_linux_tool = 'xclip'
```

### Image File Extension

```vim
" Set the file extension for saved clipboard images (default: '.png')
let g:paste_as_markdown_link_image_extension = '.png'
```

## Examples

| Source (HTML) | Result (Markdown) |
|---------------|-------------------|
| `<a href="https://example.com">Click here</a>` | `[Click here](https://example.com)` |
| `<a href="https://github.com">GitHub</a>` | `[GitHub](https://github.com)` |
| `<a href="https://vim.org"></a>` | `[https://vim.org](https://vim.org)` |
| Plain text with URL | Plain text with URL (unchanged) |

## Troubleshooting

### Linux: "text/html not available"

Make sure `xclip` is installed and the source application provides HTML clipboard data. Some applications (like plain terminals) only provide plain text.

### macOS: Clipboard not working

Ensure you're running a version of macOS that supports the NSPasteboard APIs (macOS 10.10+).

### Nested HTML in links

The plugin handles simple nested tags like `<a href="url"><span>text</span></a>` by extracting just the text content.

## Development

### Running Tests

The plugin includes a comprehensive test suite. To run the tests:

```bash
# Using make
make test

# Or directly with Vim
vim -es -N -u NONE -i NONE -c "set nocompatible" -c "source test/run_tests.vim"

# Or using the shell script
./test/run_tests.sh
```

Test results are also written to `test/results.txt`.

### Project Structure

```
paste_as_markdown_link/
├── plugin/
│   └── paste_as_markdown_link.vim   # Plugin initialization
├── autoload/
│   ├── paste_as_markdown_link.vim   # Core functions (lazy-loaded)
│   ├── clipboard_html.swift         # Swift helper for HTML clipboard (macOS)
│   └── clipboard_image.swift        # Swift helper for image clipboard (macOS)
├── test/
│   ├── run_tests.vim                # Unit test suite
│   └── run_tests.sh                 # Test runner script
├── Makefile                         # Build/test automation
├── README.md                        # This file
└── LICENSE                          # MIT License
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
