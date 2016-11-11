" Customize indentation
autocmd BufNewFile,BufRead *.pl     set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.pm     set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.t      set expandtab   tabstop=4 shiftwidth=4 filetype=perl
autocmd BufNewFile,BufRead *.java   set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.gradle set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.groovy set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.swift  set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.go     set noexpandtab tabstop=4 shiftwidth=4

" Input current date
nmap <C-i><C-d> <ESC>i<C-r>=strftime("%Y/%m/%d(%a)")<CR><CR>
