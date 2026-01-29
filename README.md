# Paste as Markdown Link

A Vim plugin that converts HTML links in your clipboard to markdown format when pasting. Copy a link from your browser or word processor, and paste it as a clean markdown link.

## Features

- Converts `<a href="url">text</a>` to `[text](url)`
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
Plugin 'soheilghafurian/vim-passte-as-markdown-link'
```

Then run `:PluginInstall` in Vim.

### Using vim-plug

```vim
Plug 'soheilghafurian/vim-passte-as-markdown-link'
```

Then run `:PlugInstall` in Vim.

### Manual Installation

Clone this repository into your Vim packages directory:

```bash
# Vim 8+ native package manager
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/soheilghafurian/vim-passte-as-markdown-link.git
```

## Usage

### Command

```vim
:PasteAsMarkdownLink
```

### Mappings

The plugin provides `<Plug>` mappings for customization. Add your preferred mapping to your `.vimrc`:

```vim
" Normal mode mapping
nmap <leader>p <Plug>(PasteAsMarkdownLink)

" Or use Ctrl+Shift+V
nmap <C-S-v> <Plug>(PasteAsMarkdownLink)

" Insert mode mapping
imap <C-S-v> <Plug>(PasteAsMarkdownLinkInsert)
```

### Workflow

1. Copy a link from your browser, Word, Google Docs, etc.
2. In Vim, use your mapped key or run `:PasteAsMarkdownLink`
3. The link is inserted as `[link text](url)`

## Configuration

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
│   └── paste_as_markdown_link.vim   # Core functions (lazy-loaded)
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
