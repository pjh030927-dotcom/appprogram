@echo off
setlocal
chcp 65001 >nul
where flutter >nul 2>nul
if errorlevel 1 (
  echo SETUP_FLUTTER_MISSING: Flutter SDK를 PATH에 등록한 뒤 다시 실행하세요.
  exit /b 2
)
where git >nul 2>nul
if errorlevel 1 (
  echo SETUP_GIT_MISSING: Git을 설치한 뒤 다시 실행하세요.
  exit /b 2
)
if exist week6_notice (
  echo SETUP_TARGET_EXISTS: 기존 week6_notice를 보호합니다. 새 실습 폴더에서 실행하세요.
  exit /b 3
)
flutter create --platforms=web --project-name week6_notice week6_notice
if errorlevel 1 exit /b 4
copy /y "%~dp0starter_main.dart" "week6_notice\lib\main.dart" >nul
if errorlevel 1 exit /b 5
copy /y "%~dp0notice_test.dart" "week6_notice\test\widget_test.dart" >nul
if errorlevel 1 exit /b 6
echo 준비 완료. TODO 구현 전 행동 테스트는 실패하는 것이 정상입니다.
echo cd week6_notice
echo flutter run -d chrome
exit /b 0
