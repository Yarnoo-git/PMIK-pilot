@echo off
echo ================================================================================
echo PMIK-pilot Python 가상환경 설정
echo ================================================================================
echo.

REM Check Python version
python --version | findstr /R "3\.10" >nul
if errorlevel 1 (
    echo [ERROR] Python 3.10이 필요합니다.
    echo 현재 설치된 Python 버전:
    python --version
    echo.
    echo Python 3.10을 설치한 후 다시 실행해주세요.
    pause
    exit /b 1
)

echo [1/4] Python 3.10 확인 완료
python --version
echo.

REM Create virtual environment
echo [2/4] 가상환경 생성 중...
if exist venv (
    echo 기존 venv 폴더가 존재합니다. 삭제하고 새로 만들까요? (Y/N)
    set /p answer=
    if /i "%answer%"=="Y" (
        rmdir /s /q venv
        python -m venv venv
    ) else (
        echo 기존 가상환경을 사용합니다.
    )
) else (
    python -m venv venv
)
echo.

REM Activate virtual environment
echo [3/4] 가상환경 활성화 중...
call venv\Scripts\activate.bat
echo.

REM Install dependencies
echo [4/4] 패키지 설치 중...
python -m pip install --upgrade pip
pip install -r requirements.txt
echo.

echo ================================================================================
echo 설치 완료!
echo ================================================================================
echo.
echo 가상환경 활성화: venv\Scripts\activate
echo 가상환경 비활성화: deactivate
echo.
echo 데이터베이스 확인: python check_db.py
echo.
pause
