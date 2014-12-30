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

" internal commands
command TodoOpen call s:TodoOpen()
command TodoBufEnter call s:TodoBufEnter()
command TodoBufLeave call s:TodoBufLeave()
command TodoBufWinEnter call s:TodoBufWinEnter()
command TodoBufWinLeave call s:TodoBufWinLeave()
command TodoCursorMoved call s:TodoCursorMoved()

" define shortcut
" XXX: move to dotfiles
nnoremap <Leader>t :Todo<CR>

" bind autocmds
autocmd BufEnter /tmp/todo.tmp TodoBufEnter
autocmd BufLeave /tmp/todo.tmp TodoBufLeave

autocmd BufWinEnter /tmp/todo.tmp TodoBufWinEnter
autocmd BufWinLeave /tmp/todo.tmp TodoBufWinLeave

autocmd CursorMoved /tmp/todo.tmp TodoCursorMoved
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
  " find a match
  let l:match = s:FindMatch()
  if l:match == []
    return
  endif

  " switch window up and go to that line
  wincmd k
  execute l:match[0]
endfunction

" finds a match from the matches list
function s:FindMatch()
  " get array index, return if out of bounds
  let l:arraypos = line(".") - 4
  if l:arraypos < 0 || l:arraypos >= len(s:matches)
    return []
  endif

  " store the match
  return s:matches[l:arraypos]
endfunction

" autocmd handlers
"
function s:TodoBufEnter()
  if winnr() == 1
    quit
  endif

  nnoremap <Enter> :wincmd k<CR>

  set cursorline

  execute 'resize ' . s:Todo_mini_size*3
endfunction

function s:TodoBufLeave()
  unmap <Enter>

  set nocursorline

  wincmd k
  set nocursorline
  wincmd j

  execute 'resize ' . s:Todo_mini_size
endfunction

function s:TodoBufWinEnter()
  let s:Todo_open = 1
endfunction

function s:TodoBufWinLeave()
  let s:Todo_open = 0
endfunction

function s:TodoCursorMoved()
  let l:match = s:FindMatch()
  if l:match == []
    return
  endif

  wincmd k
  execute l:match[0]
  set cursorline
  wincmd j
endfunction
