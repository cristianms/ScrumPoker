@ECHO OFF
ECHO ##################################################################
ECHO ### Iniciando o processo de verificacao de metricas do projeto ###
ECHO ##################################################################
ECHO .
ECHO .
RMDIR metrics /s /q
ECHO Gerando dados de metricas
CALL flutter pub run dart_code_metrics:metrics lib --reporter=html
ECHO Abrindo relatorio no navegador
CALL metrics\index.html
REM PAUSE
REM Comandos adicionais
REM flutter pub run dart_code_metrics:metrics check-unnecessary-nullable lib
REM flutter pub run dart_code_metrics:metrics check-unused-code lib
REM flutter pub run dart_code_metrics:metrics check-unused-files lib
REM flutter pub run dart_code_metrics:metrics check-unused-l10n lib