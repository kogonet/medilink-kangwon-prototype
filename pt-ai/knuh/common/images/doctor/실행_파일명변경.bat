@echo off
chcp 65001 > nul
echo 파일명 변경을 시작합니다...
node "%~dp0rename_doctors.js"
pause
