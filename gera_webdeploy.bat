@ECHO OFF
ECHO ##################################################################
ECHO ### Iniciando o processo de build e deploy da versão WEB #########
ECHO ##################################################################
ECHO .
ECHO .
ECHO Fazendo build WEB...........
CALL flutter build web
ECHO Fazendo deploy para Firebase...........
CALL firebase deploy --only hosting:webscrumpoker
REM PAUSE