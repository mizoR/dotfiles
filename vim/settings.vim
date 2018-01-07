" Customize indentation
autocmd BufNewFile,BufRead *.c      set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.pl     set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.pm     set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.t      set expandtab   tabstop=4 shiftwidth=4 filetype=perl
autocmd BufNewFile,BufRead *.psgi   set expandtab   tabstop=4 shiftwidth=4 filetype=perl
autocmd BufNewFile,BufRead *.java   set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.gradle set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.groovy set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.swift  set expandtab   tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.go     set noexpandtab tabstop=4 shiftwidth=4
autocmd BufNewFile,BufRead *.tt     setf tt2html " see: http://qiita.com/soymsk/items/441389a390e672086e66
autocmd BufNewFile,BufRead *.ru     set filetype=ruby
autocmd BufNewFile,BufRead Gemfile  set filetype=ruby
autocmd BufNewFile,BufRead Podfile  set filetype=ruby
autocmd BufNewFile,BufRead Capfile  set filetype=ruby
autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby

" Input current date
nmap <C-i><C-d> <ESC>i<C-r>=strftime("%Y/%m/%d(%a)")<CR><CR>
