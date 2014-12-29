"-------------------------------
"   Name Of File: todo.vim
"
"    Description: Collects all TODO, FIXME, and XXX in a folder and displays
"                 them in a clean interface.
"
"         Author: Colin Heinzmann (cheinzmann3@gmail.com)
"        Version: 0.1
"-------------------------------

" Load script only once
if exists("g:loaded_todo")
  finish
endif
let g:loaded_todo = 1

" initialization
command! Todo call s:Todo()
" --------------

" Plugin main
function s:Todo()

  " match upper case and lower case text
  let l:matches = []
  g/\v([t|T][o|O][d|D][o|O]|[x|X]{3}|[f|F][i|I][x|X][m|M][e|E]):/let l:matches = matches + [[line("."), getline(line("."))]]

  call s:WriteToFile(@%, l:matches)
  call s:OpenWindow()

endfunction

" Opens a window with the file in read only mode
" Todo: Enter binding to open the file
function s:OpenWindow()
  " open the file in readonly mode with
  " editing turned off
  new
  view /tmp/todo.tmp
  set nomodifiable

  " bind the enter key
  " map <Enter> GoToTodo
  map <F2> :echo 'Current time is '.strftime('%c')<CR>
endfunction

function s:WriteToFile(origname, matches)
  call delete("/tmp/todo.tmp")
  sp /tmp/todo.tmp

  " write the filename
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

