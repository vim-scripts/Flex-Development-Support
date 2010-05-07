" MXML filetype plugin file==''?'':',')
" Language:    MXML (Flex development)
" Version:     1.0
" Maintainer:  David Fishburn <dfishburn at gmail dot com>
" Last Change: 2010 May 05

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

let s:save_cpo = &cpo
set cpo=

" Define how to find the macro definition of a variable using the various
" [d, [D, [_CTRL_D and so on features
" Match these values ignoring case
" ie  var name:String
let &l:define = '\<var\>'

" Comments can be of the form:
"   <!--
"   -->
" or
"   /*
"    *
"    */
" or
"   // 
setlocal comments=s1:/*,mb:*,ex:*/,://,s:<!--,m:\ \ \ \ \ ,e:-->
setlocal commentstring=<!--%s-->

let compilerpath= globpath(&rtp,"compiler/mxmlc.vim")
if filereadable(compilerpath)
    compiler mxmlc
endif

" t - Do not automatically wrap on long lines
" c - Auto-wrap comments using textwidth, inserting the current comment
"     leader automatically.
"     Do not format comments since these could also be 
"     Actionscript comments.
" l - Long lines are not broken in insert mode: When a line was longer than
"     'textwidth' when the insert command started, Vim does not
"     automatically format it.
setlocal formatoptions-=c
setlocal formatoptions-=l
setlocal formatoptions-=t

" Choose setting to be compatible with FlexBuilder (Eclipse)
setlocal tabstop=4
setlocal noexpandtab

" XML:  Thanks to Johannes Zellner and Akbar Ibrahim
" - case sensitive
" - don't match empty tags <fred/>
" - match <!--, --> style comments (but not --, --)
" - match <!, > inlined dtd's. This is not perfect, as it
"   gets confused for example by
"       <!ENTITY gt ">">
if exists("loaded_matchit")
    let b:match_ignorecase=0
    let b:match_words =
                \ &matchpairs .
                \ 
                \ ','.
                \ '\<if\>:'.
                \ '\<else\s\+if\>:'.
                \ '\<else\>,'.
                \ 
                \ '\<switch\>:'.
                \ '\<case\>\|\<break\>:'.
                \ '\<default\>,'.
                \
                \ '\%(\<do\>\|\<while\>\|\<for\>\):'.
                \ '\<break\>\|\<continue\>,'.
                \
                \ '\<try\>:'.
                \ '\<catch\>:'.
                \ '\<finally\>,'.
                \
                \  '<:>,' .
                \  '<\@<=!\[CDATA\[:]]>,'.
                \  '<\@<=!--:-->,'.
                \  '<\@<=?\k\+:?>,'.
                \  '<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,'.
                \  '<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>'
endif

if exists('&omnifunc')
    if exists('&ofu')
        setlocal omnifunc=mxmlcomplete#CompleteTags
    endif
    command! -nargs=+ MXMLns call mxmlcomplete#CreateConnection(<f-args>)
    command! -nargs=? MXMLent call mxmlcomplete#CreateEntConnection(<f-args>)

    " Automatically load all available namespaces
    for mxml_ns_files in split(globpath(&rtp,"autoload/xml/mxml_*.vim"), "\n")
        exec "MXMLns ".matchstr(mxml_ns_files, 'mxml_\zs\w\+\ze\.vim')
    endfor
endif


" If the above runtime command succeeded, do not load the default settings
if exists("b:did_ftplugin")
  finish
endif

let b:undo_ftplugin = "setl comments<"

" Don't load another plugin for this buffer
let b:did_ftplugin     = 1
let b:current_ftplugin = 'mxml'

" Mappings to move to the next BEGIN ... END block
" \W - no characters or digits
nmap <buffer> <silent> ]] :call search('\\c^\\s*{\\s*$', 'W' )<CR>
nmap <buffer> <silent> [[ :call search('\\c^\\s*{\\s*$', 'bW' )<CR>
nmap <buffer> <silent> ][ :call search('\\c^\\s*}\\s*$', 'W' )<CR>
nmap <buffer> <silent> [] :call search('\\c^\\s*}\\s*$', 'bW' )<CR>
vmap <buffer> <silent> ]] :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*{\\s*$', 'W' )<CR>
vmap <buffer> <silent> [[ :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*{\\s*$', 'bW' )<CR>
vmap <buffer> <silent> ][ :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*}\\s*$', 'W' )<CR>
vmap <buffer> <silent> [] :<C-U>exec "normal! gv"<Bar>call search('\\c^\\s*}\\s*$', 'bW' )<CR>


" Win32 can filter files in the browse dialog
if has("gui_win32") && !exists("b:browsefilter")
    let b:browsefilter = "MXML Files (*.mxml)\t*.mxml\n" .
	  \ "ActionScript Files (*.as)\t*.as\n"
	  \ "All Files (*.*)\t*.*\n"
endif

" Enable gf on import statements.  Convert . in the import
" statement to / and append .as to the name, then search the path.
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd+=.mxml
setlocal suffixesadd+=.as

" Functions to allow the user to change search
" path for MXML files.
" Mostly useful from autocmds.  This example below will work 
" with MXML and ActionScript files since they both define 
" a similar function.
"    autocmd bufread */PortalUI/*
"                \ let project_root = substitute(fnamemodify(expand("<afile>"), ':p:h'), 'PortalUI\zs.*', '', '')|
"                \ if exists("*AddSearchPath_".&ft) | call AddSearchPath_{&ft}(project_root.'/src') | endif
"
if !exists("*AddSearchPath_mxml")
    " NOTE: You cannot use function! since this file can be 
    " sourced from within this function.  That will result in
    " an error reported by Vim.
    function AddSearchPath_mxml(additional_path)
        " Path has this format 
        "    =.,.,C:\something,/opt/source
        " So check to see if the path has already been added
        if isdirectory(a:additional_path)
            if match(&path, '\(^\|,\)'.a:additional_path.'\($\|,\)') == -1
                let &l:path=(&l:path==''?'':',').a:additional_path
            endif
        endif
    endfunction
endif

" Undo the stuff we changed.
let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions<" .
		\     " | unlet! b:match_ignorecase b:match_words b:browsefilter"
let &cpo = s:save_cpo

" vim:sw=4:


