NeoBundle 'Shougo/unite.vim'

" ヤンクされたテキストの履歴取得
let g:unite_source_history_yank_enable =1

" 最近開いたファイル履歴の保存数
let g:unite_source_file_mru_limit = 200

" <C-u> をPrefix Keyに設定
nnoremap [unite] <Nop>
nmap     <C-u> [unite]

" バッファ一覧を開く
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>

" ヤンク一覧を開く
nnoremap <silent> [unite]y :<C-u>Unite history/yank<CR>

" ファイル一覧を開く
nnoremap <silent> [unite]f :<C-u>UniteWithCurrentDir file<CR>

" ファイル一覧を開く - Most Recently Used
nnoremap <silent> [unite]u :<C-u>UniteWithCurrentDir file_mru<CR>
