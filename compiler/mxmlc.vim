" Mxmlc compiler file for Adobe Flex 
" Compiler: Adobe Flex (mxmlc)
" Maintainer: David Fishburn <dfishburn.vim at gmail.com>
" Last Change: 2009 May 09

if exists("current_compiler")
    finish
endif
let current_compiler = "mxmlc"

if exists("g:mxmclPath")
  let mxmlcCmd = g:mxmlcPath
else
  let mxmlcCmd = "mxmlc"
endif
if exists("b:mxmlcOptions")
  let mxmlcCmd = mxmlcCmd . ' ' . b:mxmlcOptions
endif
if exists("b:mxmlcDebug")
  let mxmlcCmd = mxmlcCmd . ' -compiler.debug '
endif
if exists("b:mxmlcIncludeLibs")
  " Allow this to be a comma separate list of SWC files, 
  " expand it out separtely
  let mxmlcCmd = mxmlcCmd . ' -compiler.include-libraries '.substitute(b:mxmlcIncludeLibs, ',', ' -compiler.include-libraries ', 'g')
endif
if exists("b:mxmlcOutputDir")
  let mxmlcCmd = mxmlcCmd . " -output " . fnamemodify(b:mxmlcOutputDir, ":p") . expand("%:r") . '.swf'
endif
let mxmlcCmd = mxmlcCmd . " ". expand("%:p")

let &l:makeprg=mxmlcCmd

echomsg mxmlcCmd
" setlocal errorformat=
"             \%f(%l):\ Error:\ %m
" setlocal errorformat=
"             \%-GLoading\ configuration\ file,
" 
setlocal errorformat=
            \%-GLoading\ configuration\ file,
            \%E%f(%l):\ \ Error:\ %m,
            \%W%f(%l):\ Warning:\ %m,
            \%+C%.%#
" Sample output
"
"Loading configuration file C:\Programs\Adobe\FlexBuilder3\sdks\3.1.0\frameworks\flex-config.xml
"C:\projects\flex\src\MMO.mxml(1991): Warning: Data binding will not be able to detect assignments to "sessionReportXML".
"
"				<mx:DataGrid id="dg_session_report" width="781" height="433" dataProvider="{sessionReportXML.row}" 
"
"C:\projects\flex\src\MMO.mxml(488):  Error: Access of undefined property debugFlexBuilderRun.
"
"                if( debugFlexBuilderRun ) {
"
"C:\projects\flex\src\MMO.mxml(495):  Error: Access of undefined property lastFaultMessage.
"
"                if( now.time - lastFaultMessage.time > 60000 ) {
"
"C:\projects\flex\src\MMO.mxml(498):  Error: Access of undefined property lastFaultMessage.
"
"                        lastFaultMessage = now;
"
"C:\projects\flex\src\MMO.mxml(501):  Error: Access of undefined property ServerMonitor.
"
"                        ServerMonitor.webServerDown();
" 

" vim: filetype=vim
