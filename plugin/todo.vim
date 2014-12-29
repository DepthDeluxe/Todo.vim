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

" Plugin main
function s:Todo()

  " copy all matches into the a register
  let @a = ""
  let @b = ""
  " g/\v(TODO|XXX|FIXME):/yank a

  let l:matches = []
  g/\v(TODO|XXX|FIXME):/let l:matches = matches + [[line("."), getline(line("."))]]

  echo l:matches

  call s:WriteToFile(l:matches)
  call s:OpenWindow()

endfunction

" Opens a window with the file in read only mode
" Todo: Enter binding to open the file
function s:OpenWindow()
  " open the file in readonly mode
  new
  view /tmp/todo.tmp
endfunction

function s:WriteToFile(matches)
  call delete("/tmp/todo.tmp")
  sp /tmp/todo.tmp

  for pair in a:matches
    let l:line = pair[0].": ".pair[1]
    put =l:line
  endfor

  write
  close
endfunction

" The command to use
command! Todo call s:Todo()
