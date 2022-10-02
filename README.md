navigate working directory history and subdirectories

# Installation

```vim
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'jiazhoulvke/cwd_finder.vim'
```

# Configuration

```vim
nnoremap <leader>pu <ESC>:cd ..<CR>:pwd<CR>
nnoremap <leader>pp <ESC>:Leaderf cwd_history<CR>
nnoremap <leader>pl <ESC>:Leaderf cwd_sub_dirs<CR>

```
