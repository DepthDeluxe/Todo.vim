"-------------------------------
"   Name Of File: todo.vim
"
"    Description: Collects all TODO, FIXME, and XXX in a folder and displays
"                 them in a clean interface.
"
"         Author: Colin Heinzmann (cheinzmann3@gmail.com)
"        Version: 0.1
"------------------------------

" Load script only once
if exists("g:loaded_todo")
  finish
endif
let g:loaded_todo = 1

" initialization
let s:matches = []

let s:Todo_open = 0
let s:Todo_mini_size = 7

" define commands
command Todo call s:Todo()
command TodoOpen call s:TodoOpen()

" define shortcut
" XXX: move to dotfiles
nnoremap <Leader>t :Todo<CR>

" bind autocmds
autocmd BufEnter /tmp/todo.tmp nnoremap <Enter> :TodoOpen<CR>
autocmd BufLeave /tmp/todo.tmp unmap <Enter>

autocmd BufEnter /tmp/todo.tmp set cursorline
autocmd BufLeave /tmp/todo.tmp set nocursorline

autocmd BufEnter /tmp/todo.tmp execute 'resize ' . s:Todo_mini_size*3
autocmd BufLeave /tmp/todo.tmp execute 'resize ' . s:Todo_mini_size

autocmd BufWinEnter /tmp/todo.tmp let s:Todo_open = 1
autocmd BufWinLeave /tmp/todo.tmp let s:Todo_open = 0

" --------------

" Plugin main
function s:Todo()
  " Close the window if its already open
  if s:Todo_open
    call s:CloseWindow()
    return
  endif

  " match upper case and lower case text
  let l:matches = []
  g/\v([t|T][o|O][d|D][o|O]|[x|X]{3}|[f|F][i|I][x|X][m|M][e|E]):/let l:matches = matches + [[line("."), getline(line("."))]]

  let s:matches = l:matches

  call s:WriteToFile(@%, l:matches)
  call s:OpenWindow()

endfunction

" Opens a window with the file in read only mode
function s:OpenWindow()
  " open the file in readonly mode with
  " editing turned off
  new
  view /tmp/todo.tmp
  set nomodifiable
endfunction

function s:WriteToFile(origname, matches)
  call delete("/tmp/todo.tmp")
  sp /tmp/todo.tmp

  " write the filename
  set modifiable
  put =a:origname
  put ='--------'
  put =''

  " write the TODOs
  for pair in a:matches
    let l:line = pair[0].": ".pair[1]
    put =l:line
  endfor

  " delete the first line
  0delete

  write
  close
endfunction

function s:CloseWindow()
  view /tmp/todo.tmp
  close
endfunction

function s:TodoOpen()
  " get array index, return if out of bounds
  let l:arraypos = line(".") - 4
  if l:arraypos < 0 && l:arraypos >= len(s:matches)
    return
  endif

  " store the match
  let l:match = s:matches[l:arraypos]

  " switch window up and go to that line
  wincmd k
  execute l:match[0]

endfunction

