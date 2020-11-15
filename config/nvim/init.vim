" vim: foldmethod=marker

" vim-plug {{{1

" Specify a directory for plugins
call plug#begin(stdpath('data') . '/plugged')

Plug 'andrewradev/splitjoin.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'honza/vim-snippets'
Plug 'junegunn/vim-easy-align'
Plug 'jxnblk/vim-mdx-js'
Plug 'luochen1990/rainbow'
Plug 'mattn/emmet-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'NLKNguyen/papercolor-theme'
Plug 'ryyppy/vim-rescript'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vimwiki/vimwiki'

" Initialize plugin system
call plug#end()

" vim-plug 1}}}

" Appearance {{{1

set colorcolumn=+1
set cursorline
set number relativenumber

if (has("termguicolors"))
	set termguicolors
endif

set textwidth=80

colorscheme PaperColor

" Appearance 1}}}

" Behavior {{{1

set foldmethod=syntax
set ignorecase smartcase  " Use case insensitive search, except when using capital letters.
set magic  " Use 'magic' patterns (extended regular expressions).
set noexpandtab
set notimeout ttimeout ttimeoutlen=200  " Quickly time out on keycodes, but never time out on mappings.
set scrolloff=8  " Start scrolling when we're 8 lines away from margins.
set shiftwidth=4
set sidescrolloff=15
set smartindent
set tabstop=4
set undofile  " Enable persistent undos.
set whichwrap+=<,>,h,l,[,]  " Automatically wrap left and right.

augroup behavior
	autocmd!
	autocmd BufWritePre /tmp/* setlocal noundofile
	autocmd FileType json syntax match Comment +\/\/.\+$+	" jsonc comment highlighting
	autocmd InsertEnter * :set norelativenumber
	autocmd InsertLeave * :set relativenumber
augroup END

" Behavior 1}}}

" Commands {{{1

" CoC {{{2

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup cocgroup
	autocmd!
	" Setup formatexpr specified filetype(s).
	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
	" Update signature help on jump placeholder.
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call	 CocAction('fold', <f-args>)

" Add `:OrgImp` command for organize imports of the current buffer.
command! -nargs=0 OrgImp   :call	 CocAction('runCommand', 'editor.action.organizeImport')

" coc-prettier {{{3

" use :Prettier to format current buffer
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" coc-prettier 3}}}

" coc-smartf {{{3

augroup Smartf
	autocmd User SmartfEnter :hi Conceal ctermfg=220 guifg=#6638F0
	autocmd User SmartfLeave :hi Conceal ctermfg=239 guifg=#504945
augroup end

" coc-smartf 3}}}

" CoC 2}}}

" vim-surround {{{2

autocmd FileType vim,javascript,sh let b:comChar = g:commentChar[&ft] |
			\ let b:surround_{char2nr('z')}=b:comChar." {{{ \r ".b:comChar."  }}}" |
			\ let b:surround_{char2nr('Z')}=b:comChar." SECTION {{{LEVEL \r ".b:comChar." SECTION LEVEL}}}" |

" vim-surround 2}}}

command! Einit :execute 'edit '.stdpath('config').'/init.vim'
command! Lsft :execute 'echo' "glob($VIMRUNTIME . '/ftplugin/*.vim')"
command! Lssyn :execute 'echo' "glob($VIMRUNTIME . '/syntax/*.vim')"
command! PU PlugUpdate | PlugUpgrade
"command! Todo :Grepper -tool git -query '\(TODO\|FIXME\)'

" Commands 1}}}

" Functions {{{1

" check_back_space() {{{2

function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" check_back_space() 2}}}

" select_current_word() {{{2

function! s:select_current_word()
	if !get(g:, 'coc_cursors_activated', 0)
		return "\<Plug>(coc-cursors-word)"
	endif
	return "*\<Plug>(coc-cursors-word):nohlsearch\<CR>"
endfunc

" select_current_word() 2}}}

" show_documentation() {{{2

function! s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction

" show_documentation() 2}}}

" TwiddleCase() {{{2

" Press `~` to rotate between UPPER, lower, and Title cases on selection.
function! TwiddleCase(str)
	if a:str ==# toupper(a:str)
		let result = tolower(a:str)
	elseif a:str ==# tolower(a:str)
		let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
	else
		let result = toupper(a:str)
	endif
	return result
endfunction

" TwiddleCase() 2}}}

" Functions 1}}}

" Key Mappings {{{1

cnoremap <C-N> <Down>|		" Filter the command history in ex mode.
cnoremap <C-P> <Up>|		" Filter the command history in ex mode.
nnoremap <C-L> :nohl<CR>
nnoremap gb :bnext<CR>
nnoremap gB :bprevious<CR>
nnoremap gt :tabnext<CR>
nnoremap gT :tabprevious<CR>
nnoremap ZZ :w<CR>:bd<CR>
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv
vnoremap <C-H> "zy:exe "h ".@z.""<CR>|	    " Press Ctrl-H in visual mode to look up help for the selected word
set pastetoggle=<Leader>v

" CoC {{{2

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
			\ pumvisible() ? coc#_select_confirm() :
			\ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
			\ <SID>check_back_space() ? "\<TAB>" :
			\ coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
	inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
	inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Multiple cursors support
nmap <silent> <C-c> <Plug>(coc-cursors-position)
" more vscode like behavior
nmap <expr> <silent> <C-d> <SID>select_current_word()

" use normal command like `<leader>xi(`
nmap <leader>x  <Plug>(coc-cursors-operator)

" coc-explorer {{{3

nmap <leader>e :CocCommand explorer<CR>

" coc-explorer 3}}}

" coc-prettier {{{3

" use <leader>f to format selected range
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" coc-prettier 3}}}

" coc-smartf {{{3

" press <esc> to cancel.
nmap f <Plug>(coc-smartf-forward)
nmap F <Plug>(coc-smartf-backward)
nmap ; <Plug>(coc-smartf-repeat)
nmap , <Plug>(coc-smartf-repeat-opposite)

" coc-smartf 3}}}

" CoC 2}}}

" vim-easy-align {{{2

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" vim-easy-align 2}}}

" vim-rescript {{{2

" Note that <buffer> allows us to use different commands with the same keybindings depending
" on the filetype. This is useful if to override your e.g. ALE bindings while working on
" ReScript projects.
autocmd FileType rescript nnoremap <silent> <buffer> <localleader>f :RescriptFormat<CR>
autocmd FileType rescript nnoremap <silent> <buffer> <localleader>t :RescriptTypeHint<CR>
autocmd FileType rescript nnoremap <silent> <buffer> <localleader>b :RescriptBuild<CR>
autocmd FileType rescript nnoremap <silent> <buffer> gd :RescriptJumpToDefinition<CR>

" vim-rescript 2}}}

" Key Mappings 1}}}

" Plugin Configurations {{{1

" CoC {{{2

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
	" Recently vim can merge signcolumn and number column into one
	set signcolumn=number
else
	set signcolumn=yes
endif

let g:coc_snippet_next = '<tab>'

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" coc-vimlsp {{{3

let g:markdown_fenced_languages = [
			\ 'vim',
			\ 'help'
			\]

" coc-vimlsp 3}}}

" CoC 2}}}

" EditorConfig {{{2

" Ensure compatability with Tim Pope's Fugitive
let g:EditorConfig_exclude_patterns = [ 'fugitive://.*' ]

" EditorConfig 2}}}

" Rainbow {{{2

let g:rainbow_active = 1

" Rainbow 2}}}

" vim-airline {{{2

let g:airline_theme = 'papercolor'
let g:airline_powerline_fonts = 1
" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#exclude_preview = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

" vim-airline 2}}}

" vim-rescript {{{2

let g:rescript_type_hint_bin = "/mnt/d/Developer/reason-language-server/bin.exe"

" Hooking up the Rescript autocomplete function
set omnifunc=rescript#Complete

" When preview is enabled, then omnicomplete will display additional
" infos for a selected item 
set completeopt+=preview

" vim-rescript 2}}}

" vim-surround {{{2

let g:commentChar = {
			\ 'vim': '"',
			\ 'javascript': '//',
			\ 'sh': '#',
			\}

" vim-surround 2}}}

" Plugin Configurations 1}}}
