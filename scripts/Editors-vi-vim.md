# GUI & CUI Linux/Unix 编辑器

-----

## GUI Editors

- Emacs
- Nedit
- Gedit
- pico

## CUI Editors

-----

- Vi  [Classic screen-based editor]
- Vim [vi improved, enhanced support for programmers]
- Ex [Powerful line-based editor integrated with vi]
- Ed [Original unix line-based editor useful in scripts]

-----

There are 3 types of operation in vi or vim editors.

### Commands in insert mode:

-----

- i = inserts the text at current cursor position
- I = inserts the text at beginning of line
- A = Appends the text at end of line
- o = inserts a line below current cursor position
- O = inserts a line above current cursor position
- r = replace a single char at current cursor position

ESC

### Commands in execute mode or extended mode:

- :q       = quit without saving
- :!       = forcefully
- :q!	   = quit forcefully without saving
- :w       = save
- :wq      = save & quit
- :wq!     = save, quit forcefully
- :se nu   = setting line numbers
- :se nonu = Removing the line numbers
- :20      = Press enter to go to specific line like 20
- :6,10 w! <new_file> : We can copy desire lines     [ :12,18 w! >>/root/Desktop/mac.txt ]

- :1, $s/redhat/keshav/g = Serach and replace the word.

ESC

### Commands at command mode:

- dd   = Deletes a line
- ndd  = Delete 3 lines  # 3dd 
- yy   = Copy a line
- nyy  = copies 3 lines  # 3yy # 100yy
- p    = put (paste deleted or copied text)
- u    = undo (can undo 1000 times)
- ctrl+r = Redo
- G      = Moves cursor to last line of file
- /<word to find> = To search for a particular word.

-----
[code link](https://github.com/chennakesavulukummari/devops_slearn_26thJan2019_01/blob/master/Editors-vi-vim)
