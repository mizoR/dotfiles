" Syntax checking hacks
NeoBundle 'scrooloose/syntastic'

let g:syntastic_html_tidy_ignore_errors = [
  \   '<a> escaping malformed URI reference'
  \ ]
