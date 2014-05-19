set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
autocmd BufWritePre * :%s/\s\+$//e
