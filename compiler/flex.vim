" Vim compiler file for Adobe Flex 2
" Compiler: Adobe Flex 2 (mxmlc)
" Maintainer: swaroopNOSPAM@swaroopch.info
" Last Change: 2008 Nov 21

if exists("current_compiler")
    finish
endif
let current_compiler = "flex"

setlocal makeprg=mxmlc\ %

setlocal errorformat =
    \%f(%l):\ Error:\ %m

" vim: filetype=vim
