@echo off

rem the ^ character is an escape character for batch scripts, since MS-DOS (198x)
rem and since the < > characters are used to pipe/redirect output you need to escape them
rem -- use the actual custom html thingy in the project, ignore this

echo Nik's weird HTML5 Igor crash fix...
rem will do nothing if the folder already exists
mkdir %YYoutputFolder%\html5game
rem will append the line, won't do any harm if file already exists...
echo ^<!-- --^> >> %YYoutputFolder%\html5game\%YYPLATFORM_option_html5_index%

