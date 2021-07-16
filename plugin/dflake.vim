" Copyright (c) 2021 johntd54
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

""
" @section Introduction, intro
" Run Python flake8 lint checker with support of fzf.
"
" USAGE: Run `:Dflake` to open lint problems in fzf, select files and open in:
"
" * current buffer with <CR>
" * new tab with <ctrl-t>
" * horizontal split with <ctrl-x>
" * vertical split with <ctrl-v>
"
" Or <ctr-z> to close the listing.
"
"
" This plugin depends on `flake8`, 'junegunn/fzf' program and Vim plugin in
" order to display flake8 warnings with `fzf`.
"
" For support, please refer to :help dflake.
"

""
" @section Installation, install
" @order intro install commands credit license
"
" Install software dependency:
" 
" 1. Make sure to have `fzf` installed.
" 2. Make sure to have `flake8` installed.
"
" Use your favorite Vim plugin manager and include:
"
" 1. Plug 'junegunn/fzf' (required for integrating fzf with Vim)
" 2. Plug 'johntd54/dflake.vim'
"

""
" @section Credit, credit
" 
" This plugin depends on `fzf` and `flake8` to work. Also, it has referenced
" and make use parts of the code from 'junegunn/fzf.vim'.
"
" The vim document is generated with `vimdoc`.
" 

""
" @section License, license
" MIT License
"

if exists('s:dflake_loaded')
  finish
endif
let s:dflake_loaded = 1

""
" Run flake8 and show the issues in fzf for selection
command! -bar -bang Dflake call dflake#dflake(fzf#vim#with_preview(), <bang>0)
