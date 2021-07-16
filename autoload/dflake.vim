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


let s:min_version = '0.23.0'
let s:is_win = has('win32') || has('win64')
let s:TYPE = {'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}
let s:checked = 0

function! s:version_requirement(val, min)
  let val = split(a:val, '\.')
  let min = split(a:min, '\.')
  for idx in range(0, len(min) - 1)
    let v = get(val, idx, 0)
    if     v < min[idx] | return 0
    elseif v > min[idx] | return 1
    endif
  endfor
  return 1
endfunction


function! s:check_requirements()
  if s:checked
    return
  endif

  if !exists('*fzf#run')
    throw "fzf#run function not found. You also need Vim plugin from the main fzf repository (i.e. junegunn/fzf *and* junegunn/fzf.vim)"
  endif
  if !exists('*fzf#exec')
    throw "fzf#exec function not found. You need to upgrade Vim plugin from the main fzf repository ('junegunn/fzf')"
  endif
  let exec = fzf#exec()
  let output = split(system(exec . ' --version'), "\n")
  if v:shell_error || empty(output)
    throw 'Failed to run "fzf --version": ' . string(output)
  endif
  let fzf_version = matchstr(output[-1], '[0-9.]\+')

  if s:version_requirement(fzf_version, s:min_version)
    let s:checked = 1
    return
  end
  throw printf('You need to upgrade fzf. Found: %s (%s). Required: %s or above.', fzf_version, exec, s:min_version)
endfunction


function! s:extend_opts(dict, eopts, prepend)
  if empty(a:eopts)
    return
  endif
  if has_key(a:dict, 'options')
    if type(a:dict.options) == s:TYPE.list && type(a:eopts) == s:TYPE.list
      if a:prepend
        let a:dict.options = extend(copy(a:eopts), a:dict.options)
      else
        call extend(a:dict.options, a:eopts)
      endif
    else
      let all_opts = a:prepend ? [a:eopts, a:dict.options] : [a:dict.options, a:eopts]
      let a:dict.options = join(map(all_opts, 'type(v:val) == s:TYPE.list ? join(map(copy(v:val), "fzf#shellescape(v:val)")) : v:val'))
    endif
  else
    let a:dict.options = a:eopts
  endif
endfunction


function! s:escape(path)
  let path = fnameescape(a:path)
  return s:is_win ? escape(path, '$') : path
endfunction


function! s:merge_opts(dict, eopts)
  return s:extend_opts(a:dict, a:eopts, 0)
endfunction


function! s:wrap(name, opts, bang)
  " fzf#wrap does not append --expect if sink or sink* is found
  let opts = copy(a:opts)
  let options = ''
  if has_key(opts, 'options')
    let options = type(opts.options) == s:TYPE.list ? join(opts.options) : opts.options
  endif
  if options !~ '--expect' && has_key(opts, 'sink*')
    let Sink = remove(opts, 'sink*')
    let wrapped = fzf#wrap(a:name, opts, a:bang)
    let wrapped['sink*'] = Sink
  else
    let wrapped = fzf#wrap(a:name, opts, a:bang)
  endif
  return wrapped
endfunction


function! s:fzf(name, opts, extra)
  call s:check_requirements()

  let [extra, bang] = [{}, 0]
  if len(a:extra) <= 1
    let first = get(a:extra, 0, 0)
    if type(first) == s:TYPE.dict
      let extra = first
    else
      let bang = first
    endif
  elseif len(a:extra) == 2
    let [extra, bang] = a:extra
  else
    throw 'invalid number of arguments'
  endif

  let extra  = copy(extra)
  let eopts  = has_key(extra, 'options') ? remove(extra, 'options') : ''
  let merged = extend(copy(a:opts), extra)
  call s:merge_opts(merged, eopts)
  return fzf#run(s:wrap(a:name, merged, bang))
endfunction


let s:default_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }


function! s:action_for(key, ...)
  let default = a:0 ? a:1 : ''
  let Cmd = get(s:default_action, a:key, default)
  return type(Cmd) == s:TYPE.string ? Cmd : default
endfunction


function! s:open(cmd, target)
  if stridx('edit', a:cmd) == 0 && fnamemodify(a:target, ':p') ==# expand('%:p')
    return
  endif
  execute a:cmd s:escape(a:target)
endfunction


function! s:flake8_handler(lines)
  if len(a:lines) < 2
    return
  endif

  let cmd = s:action_for(a:lines[0], 'e')

  let l:parsed = split(a:lines[1], ":")
  let first = {}
  let first.filename = l:parsed[0]
  let first.lnum = l:parsed[1]
  let first.col = l:parsed[2]

  call s:open(cmd, first.filename)
  call cursor(first.lnum, first.col)
  normal! zz

endfunction


""
" Run flake8 at the vim current working directory
function! dflake#dflake(...)
  silent let s:flakeresult = split(system('flake8'), "\n")
  let l:opts = {
  \ 'source':  s:flakeresult,
  \ 'options': ['--ansi', '--prompt', '"flake8> "',
  \             '--delimiter', ':', '--preview-window', '+{2}-/2']
  \}
  function! opts.sink(lines)
    return s:flake8_handler(a:lines)
  endfunction
  let opts['sink*'] = remove(opts, 'sink')

  return s:fzf('flake', l:opts, a:000)
endfunction
