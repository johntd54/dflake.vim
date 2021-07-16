# dflake.vim

Run Python `flake8` lint checker with support of `fzf`.

<a href="https://asciinema.org/a/8irH829KXzQurK3Dmd0nTzaIa" target="_blank"><img src="https://asciinema.org/a/8irH829KXzQurK3Dmd0nTzaIa.svg" /></a>

**USAGE**: Run `:Dflake` to open lint problems in `fzf`, select files and open in:

  * current buffer with `<CR>`
  * new tab with `<ctrl-t>`
  * horizontal split with `<ctrl-x>`
  * vertical split with `<ctrl-v>`

Or <ctr-z> to close the listing.

This plugin depends on `flake8`, 'junegunn/fzf' program and Vim plugin in
order to display flake8 warnings with `fzf`.

For support, please refer to :help dflake.

## Installation

Install software dependency:

  1. Make sure to have `fzf` installed.
  2. Make sure to have `flake8` installed.

Use your favorite Vim plugin manager and include:

  1. Plug 'junegunn/fzf' (required for integrating fzf with Vim)
  2. Plug 'johntd54/dflake.vim'

## Credits

This plugin depends on `fzf` and `flake8` to work. Also, it has referenced and
make use parts of the code from 'junegunn/fzf.vim'.

The vim document is generated with `vimdoc`.

## License

MIT License
