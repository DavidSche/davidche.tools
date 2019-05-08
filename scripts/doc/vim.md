# Note for vimtutor

Just type `vimtutor` to learn the basic usage of Vim.

## 1. Basic

### 1.1 Moving the cursor

```
     ^
     k
< h     l >
     j
     v
```

### 1.2 Exiting vim 😱

- Normally: `:q`
- Write and exit: `:x` or `:wq`
- Without saving changes: `:q!`
- Write with sudo: `:w !sudo tee %`

### 1.3 Deletion

- Single character: `x`

### 1.4 Insertion

- Activate insertion mode: `i`
- Insert from the beginning of the line: `I`

### 1.5 Appending

- Append to this word: `a`
- Append to this line: `A`

## 2. Combined Operation

### 2.1 Delete

`d motion` where 'motion' is what the operator will operate on

- Delete from cursor to the start of the next word, EXCLUDING its first character: `dw`
- Delete from cursor to the end of the current word, INCLUDING the last character: `de`
- Delete from cursor th the end of line: 'd$'

### 2.2 Using a count for a motion

`number motion`

- Moving to the start of the line: `0`
- Moving the cursor 5 words forward: `5w`
- Moving the cursor to the end of the 3rd word forward: `3e`

### 2.3 Using a count to delete more

`operator number motion`

- Delete 2 words: `d2w`

### 2.4 Delete a whole line

- Delete current line: `dd`
- Delete 2 lines from current line: `2dd`

### 2.5 Undo and redo

- Undo the last commands: `u`
- Undo a whole line: `U`
- Redo the commands: `CTRL-r`

## 3. Put and replace

### 3.1 Put

- Put line below current line: `p`
- Put line above current line: `P`

### 3.2 Replace

- Replace current character to 'x': `rx`
- Replace multiple characters: `R`

### 3.3 Change

- Remove the rest of word and activate insert mode: `ce` or `cw`
- Remove the rest of line and activate insert mode: `c$`

## 4. Search and substitute

### 4.1 Cursor location and file status

- Show your location in the file and the file status: `CTRL-g`
- Move to the bottom of the file: `G`
- Move to the start of the file: `gg`
- Move to line 233: `233G`

### 4.2 Search

- Search in forward direction: `/`
- Search in backward direction: `?`
- Find next in the same direction: `n`
- Find next in the opposite direction: `N`
- To go back to where you came from: `CTRL-o`
- To go forward: `CTRL-i`

### 4.3 Matching parentheses search

- Find a match of ')', ']', or '}': `%`

### 4.4 The substitute command

- To change the 1st occurrence of the word in the line: `:s/<old>/<new>`
- To change all the occurrence of the word in the line: `:s/<old>/<new>/g`
- To change all the occurrence of the word between line #1 and #2: `:#1,#2s/<old>/<new>/g`
- To change every occurence of the word in the whole file: `:%s/<old>/<new>/g`
- To change every occurence of the word in the whole file with a prompt: `:%s/<old>/<new>/gc`

## 5. External

### 5.1 How to execute an external command

- Execute an external command: `:!<cmd>`

### 5.2 Write to another file

- Write the whole file to another file: `:w <file>`
- Use `v` to select the text you want to copy, then type `:` you will see `:'<,'>`, write to file: `:'<,'>w <file>`

### 5.3 Insert to current file

- Insert file to current file: `:r <file>`
- Insert from command line output: `:r !<cmd>`

## 6. New line and copy

### 6.1 Open

- Open a line below the cursor: `o`
- Open a line above the cursor: `O`

### 6.2 Copy

- Copy one word: `yw`
- Copy from cursor to the end of the line: `y$`
- Copy the whole line: `yy`

### 6.3 Set option

- Ingore case: `:set ic`
- Disable ignoring case: `:set noic`
- 'hlsearch'(highlight) and 'incsearch'(show partial matches): `:set hls is`

## 7. Others

### 7.1 Getting help

- Press `<HELP>` or `<F1>` or type: `:help`
- Get help for command: `:help <cmd>`

### 7.2 Completion

- Press `<TAB>` or `<CTRL-d>`

### 7.3 Multiple windows

- Jump to another window: `<CTRL-w>`