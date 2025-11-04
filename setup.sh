#!/bin/bash

echo "================================================================================"
echo "PMIK-pilot Python 가상환경 설정"
echo "================================================================================"
echo ""

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '3\.10\.\d+')
if [ -z "$PYTHON_VERSION" ]; then
    echo "[ERROR] Python 3.10이 필요합니다."
    echo "현재 설치된 Python 버전:"
    python3 --version
    echo ""
    echo "Python 3.10을 설치한 후 다시 실행해주세요."
    exit 1
fi

echo "[1/4] Python 3.10 확인 완료"
python3 --version
echo ""

# Create virtual environment
echo "[2/4] 가상환경 생성 중..."
if [ -d "venv" ]; then
    echo "기존 venv 폴더가 존재합니다. 삭제하고 새로 만들까요? (y/n)"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        rm -rf venv
        python3 -m venv venv
    else
        echo "기존 가상환경을 사용합니다."
    fi
else
    python3 -m venv venv
fi
echo ""

# Activate virtual environment
echo "[3/4] 가상환경 활성화 중..."
source venv/bin/activate
echo ""

# Install dependencies
echo "[4/4] 패키지 설치 중..."
python -m pip install --upgrade pip
pip install -r requirements.txt
echo ""

echo "================================================================================"
echo "✓ 설치 완료!"
echo "================================================================================"
echo ""
echo "가상환경 활성화: source venv/bin/activate"
echo "가상환경 비활성화: deactivate"
echo ""
echo "데이터베이스 확인: python check_db.py"
echo ""
