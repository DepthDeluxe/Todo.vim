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
if exists("g:loaded_todo") || &cp
  finish
endif
let g:loaded_todo = 1

" Opens a window and places items there
function s:OpenWindow()

  " copy all matches into the a register
  let @a = ""
  g/\v(TODO|XXX|FIXME):/yank a

  " write text to the window and close
  call delete("/tmp/todo.tmp")
  sp /tmp/todo.tmp
  put "a
  write
  close

  " open the file in readonly mode
  new
  view /tmp/todo.tmp

endfunction

" The command to use
command! Todo call s:OpenWindow()
