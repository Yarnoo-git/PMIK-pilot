# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고할 가이드입니다.

## 프로젝트 개요

PMIK-pilot은 Python 3.10 기반의 HR 데이터 분석 개념 증명(PoC) 프로젝트입니다. Claude Code와 SQLite, 웹 검색 기능을 결합하여 [CLAUDE_CODE_ANALYSIS_USE_CASES.pdf](CLAUDE_CODE_ANALYSIS_USE_CASES.pdf)에 설명된 사용 사례를 구현합니다.

**목적:** 다음을 결합하여 자연어 기반 HR 데이터 분석 지원:
- 내부 데이터를 위한 SQLite 데이터베이스 쿼리
- 업계 벤치마크 및 모범 사례를 위한 웹 검색
- AI 기반 인사이트 및 권장사항

**관련 프로젝트:** [Excel-uploader](../Excel-uploader) - Excel 파일을 SQLite 데이터베이스에 업로드하는 Python GUI 애플리케이션

## 기술 스택

- **Python 버전:** 3.10 (필수)
- **데이터베이스:** SQLite 3
- **데이터 형식:** 한글 인코딩을 지원하는 Excel 파일(.xlsx)
- **주요 라이브러리:**
  - `sqlite3` - 데이터베이스 작업 (내장)
  - `pandas` >= 2.0.0 - 데이터 처리 및 분석
  - `openpyxl` >= 3.1.0 - Excel 파일 처리

## 환경 설정

### 초기 설정

**Windows:**
```batch
setup.bat
```

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

위 명령을 실행하면:
1. Python 3.10 설치 확인
2. 가상환경 생성 (`venv/`)
3. `requirements.txt`에서 의존성 패키지 설치

### 가상환경 활성화

**Windows:**
```batch
venv\Scripts\activate
```

**macOS/Linux:**
```bash
source venv/bin/activate
```

### 설정 확인

```bash
python check_db.py
```

### 가상환경 비활성화

```bash
deactivate
```

**중요:** 이 프로젝트에서 Python 스크립트를 실행하기 전에 항상 가상환경을 활성화하세요.

## 데이터베이스 구조

### 주 데이터베이스: PMIK_2025.db

이 SQLite 데이터베이스는 EOS(Employee Opinion Survey, 직원 의견 조사) 데이터를 포함합니다.

**테이블:**

### 1. **`pmik_eos`** (99행, 7컬럼)
   - **출처:** pmik_eos.xlsx
   - **목적:** EOS 설문 문항 마스터
   - **구조:** 77개 고유 문항(Q1~Q77), Q75와 Q76은 각각 12개의 선택지를 가진 복수 선택 문항

   **컬럼:**
   - `대분류` (TEXT) - 대분류 (예: "Value", "비전/전략", "기타")
   - `중분류` (TEXT) - 중분류 (예: "가치인식", "이해도", "동기부여 및 저해 요인")
   - `소분류` (TEXT) - 소분류 (예: "자기인식", "공유도", "동기부여 요인")
   - `No.` (REAL) - 문항 번호 (1.0~77.0)
   - `문항` (TEXT) - 설문 문항 텍스트
   - `선택(보기)` (TEXT) - 응답 선택지
     - Q1~Q74: 5점 척도 (①전혀 그렇지 않다 ~ ⑤매우 그렇다)
     - Q75, Q76: 복수 선택 문항 (12개 중 3개 선택)
     - Q77: 주관식 문항
   - `비고` (TEXT) - 비고/메모
     - Q75, Q76의 경우: 응답 매핑을 위한 선택지 번호 (1~12)

   **특수 문항:**
   - **Q75** (12행): "업무 몰입 동기부여 요인" - 12개 동기부여 요인 중 3개 선택
     - 각 행은 동일한 `No.` (75.0)와 `문항`을 가지지만, `선택(보기)`와 `비고`(1~12)가 다름
     - `pmik_raw_data.r075`와 매핑 (예: "4 11 10"은 4번, 11번, 10번 선택지를 의미)
   - **Q76** (12행): "업무 몰입 저해 요인" - 12개 저해 요인 중 3개 선택
     - 각 행은 동일한 `No.` (76.0)와 `문항`을 가지지만, `선택(보기)`와 `비고`(1~12)가 다름
     - `pmik_raw_data.r076`와 매핑 (예: "1 6 7"은 1번, 6번, 7번 선택지를 의미)

### 2. **`pmik_member`** (139행, 15컬럼)
   - **출처:** pmik_member.xlsx
   - **목적:** 설문 참여 직원의 마스터 데이터

   **컬럼:**
   - `ID(new)` (TEXT) - 직원 ID (예: "KR0005")
   - `Name(Kor.)` (TEXT) - 한글 이름
   - `Contract` (TEXT) - 계약 유형 (정규직/계약직)
   - `Temperory` (REAL) - 임시직 여부
   - `Job Title` (TEXT) - 직급 (B2, E1, S3 등)
   - `입사일` (TIMESTAMP) - 입사 날짜
   - `근속기간` (TEXT) - 재직 기간 (예: "7년 5개월")
   - `Email` (TEXT) - 이메일 주소
   - `근로시간` (INTEGER) - 주당 근무 시간
   - `Biz Unit.` (TEXT) - 사업부
   - `Department` (TEXT) - 부서명
   - `Team` (TEXT) - 팀명
   - `Unnamed: 12~14` - 예약/메타데이터 컬럼

### 3. **`pmik_raw_data`** (138행, 126컬럼)
   - **출처:** pmik_raw_data.xlsx
   - **목적:** EOS 설문 응답 데이터 (원시 데이터)
   - **응답률:** 95.7% (132/138 완료)

   **컬럼 그룹:**
   - **기본 정보** (27개 컬럼): id, surveys_id, name, corporate_id, email, rank, etc1(사업부), etc2(팀), created_at, completed_at, completed
   - **응답 컬럼** (99개 컬럼): r001~r099
     - r001~r077: 5점 척도 응답 (1-5)
     - r078~r100: 주관식 및 인구통계 문항

   **주요 컬럼:**
   - `id` (INTEGER) - 응답 ID
   - `name` (TEXT) - 응답자 이름
   - `corporate_id` (TEXT) - 직원 ID (pmik_member와 연결)
   - `email` (TEXT) - 이메일 주소
   - `rank` (TEXT) - 직급 (B1, B2, B3, S2, S3, E1, E2)
   - `etc1` (TEXT) - 사업부 (Sales, O&F, A&R)
   - `etc2` (TEXT) - 팀/부서
   - `completed` (INTEGER) - 완료 상태 (1=완료, 0=진행중)
   - `r001~r077` (REAL) - 5점 척도 응답 (1-5)

   **응답 분포:**
   - 5점 (매우 그렇다): 1,269건 (12.7%)
   - 4점 (그렇다): 3,370건 (33.8%)
   - 3점 (보통): 3,029건 (30.4%)
   - 2점 (그렇지 않다): 1,468건 (14.7%)
   - 1점 (전혀 그렇지 않다): 632건 (6.3%)

## 쿼리 예제

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# 카테고리별 EOS 문항 조회
df = pd.read_sql_query("SELECT * FROM pmik_eos WHERE 대분류 = 'Value'", conn)

# 전체 직원 조회
df = pd.read_sql_query("SELECT * FROM pmik_member", conn)

# 부서별 직원 조회
df = pd.read_sql_query("SELECT * FROM pmik_member WHERE Department = 'Sales'", conn)

# 완료된 설문 응답 조회
df = pd.read_sql_query("SELECT * FROM pmik_raw_data WHERE completed = 1", conn)

# 응답과 직원 데이터 조인
query = """
SELECT
    r.id, r.name, r.corporate_id, r.rank, r.etc1 as business_unit,
    r.r001, r.r002, r.r003,
    m."Job Title", m.Department
FROM pmik_raw_data r
LEFT JOIN pmik_member m ON r.corporate_id = m."ID(new)"
WHERE r.completed = 1
LIMIT 10
"""
df = pd.read_sql_query(query, conn)

# Q75/Q76 복수 선택 문항 조회
# 예시: "4 11 10" 응답에 대한 선택지 텍스트 조회
response_75 = "4 11 10"
option_numbers = response_75.split()  # ['4', '11', '10']

query = f"""
SELECT 비고, "선택(보기)" as option_text
FROM pmik_eos
WHERE "No." = 75.0 AND 비고 IN ({','.join(option_numbers)})
ORDER BY 비고
"""
df = pd.read_sql_query(query, conn)
print("Q75 선택한 옵션:")
print(df)

# 가장 많이 선택된 동기부여 요인 분석 (Q75)
query = """
SELECT
    e.비고 as option_number,
    e."선택(보기)" as option_text,
    COUNT(*) as selection_count
FROM pmik_raw_data r, pmik_eos e
WHERE r.completed = 1
    AND e."No." = 75.0
    AND (',' || REPLACE(r.r075, ' ', ',') || ',') LIKE ('%,' || e.비고 || ',%')
GROUP BY e.비고, e."선택(보기)"
ORDER BY selection_count DESC
"""
df = pd.read_sql_query(query, conn)

conn.close()
```

## 소스 Excel 파일

- `pmik_eos.xlsx` - EOS 문항 데이터
- `pmik_member.xlsx` - 직원 마스터 데이터
- `pmik_raw_data.xlsx` - 설문 응답 원시 데이터

이 파일들은 Excel-uploader 프로그램을 사용하여 SQLite 데이터베이스에 업로드됩니다.

## 일반적인 개발 명령어

### 데이터베이스 작업

```bash
# Python을 사용한 데이터베이스 테이블 확인
python -c "import sqlite3; conn = sqlite3.connect('PMIK_2025.db'); \
cursor = conn.cursor(); \
cursor.execute('SELECT name FROM sqlite_master WHERE type=\"table\"'); \
print([t[0] for t in cursor.fetchall()])"

# pandas로 데이터베이스 쿼리
python -c "import pandas as pd; import sqlite3; \
conn = sqlite3.connect('PMIK_2025.db'); \
df = pd.read_sql_query('SELECT * FROM pmik_eos LIMIT 5', conn); \
print(df)"
```

### Excel 파일 작업

Excel 파일 작업 시 Excel-uploader 참조:

```bash
# Excel-uploader 디렉토리로 이동
cd ../Excel-uploader

# 가상환경 활성화
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux

# Excel을 SQLite로 업로드
python upload.py <excel_file> <table_name> [db_path]

# 예시: PMIK 데이터베이스에 업로드
python upload.py ../PMIK-pilot/pmik_eos.xlsx "pmik_eos" ../PMIK-pilot/PMIK_2025.db
```

## 아키텍처 및 주요 개념

### Claude Code 분석 워크플로우

CLAUDE_CODE_ANALYSIS_USE_CASES.pdf 기반 분석 흐름:

1. **자연어 질문** - 사용자가 한글/영어로 질문
2. **데이터베이스 쿼리** - SQL 쿼리 생성 및 실행
3. **데이터 분석** - 결과 처리, 지표 계산
4. **웹 검색** (선택사항) - 업계 벤치마크, 모범 사례 검색
5. **인사이트 생성** - 내부 + 외부 데이터 결합
6. **실행 가능한 보고서** - 권장사항과 함께 결과 제시

### 분석 시나리오 (PDF에서)

**기본 분석:**
- 부서/월별 근무 시간
- 센터별 효율성 추이
- 직급별 근무 패턴
- 야간 근무 분석

**고급 분석:**
- 이상 징후 감지 및 근본 원인 분석
- 시장 데이터를 활용한 인건비 최적화
- 업계 트렌드를 반영한 채용 계획
- 경쟁사 벤치마킹

**의사결정 지원:**
- 유연 근무제 영향 분석
- 정책 변경에 대한 ROI 계산
- 전략적 인력 계획

### Excel-uploader와의 통합

Excel-uploader 프로젝트는 데이터 파이프라인을 제공합니다:

**핵심 구성요소:**
- `core/db_manager.py` - 청크 삽입을 지원하는 SQLite 작업
- `core/excel_loader.py` - 자동 병합 기능을 가진 다중 시트 Excel 로딩
- `main.py` - 데이터베이스 관리를 위한 GUI 애플리케이션

**주요 기능:**
- 다중 시트 Excel 지원
- 자동 데이터 타입 추론
- 진행 상황 추적
- 트랜잭션 관리
- Excel/CSV로 내보내기

## 데이터 분석 패턴

### 기본 쿼리

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# 모든 EOS 문항 조회
df = pd.read_sql_query("SELECT * FROM pmik_eos", conn)

# 카테고리별 조회
df = pd.read_sql_query("""
    SELECT 대분류, 중분류, 문항
    FROM pmik_eos
    WHERE 대분류 = 'Value'
""", conn)

conn.close()
```

### 날짜 범위 필터링

정수(20250101) 및 문자열('2025-01-01') 날짜 형식 처리:

```python
# 정수 날짜 형식 (YYYYMMDD)
WHERE CAST(date_column AS INTEGER) >= 20250101
  AND CAST(date_column AS INTEGER) <= 20251231

# 문자열 날짜 형식
WHERE date(date_column) >= '2025-01-01'
  AND date(date_column) <= '2025-12-31'
```

## 분석 스크립트

### 부서별 응답 현황 분석

```bash
python analyze_department_responses.py
```

**분석 내용:**
- 사업부별 응답률 (A&R, O&F, Sales)
- 부서 및 팀별 상세 응답 현황
- 완료/미완료/미응답 인원 현황
- 응답률 시각화 (프로그레스 바)

**주요 결과:**
- 전체 응답률: 95.0% (132/138명)
- O&F: 96.7% (29/30명)
- Sales: 96.3% (78/81명)
- A&R: 89.3% (25/28명)

### 근속기간별 응답률 분석

```bash
python analyze_tenure_responses.py
```

**분석 내용:**
- 근속기간 구간별 응답률 (1년 미만, 1-3년, 3-5년, 5-10년, 10년 이상)
- 완료자 vs 미완료자 평균 근속기간 비교
- 미완료/미응답자 상세 프로필
- 상관관계 분석

**주요 결과:**
- 5-10년 그룹: 100% 완료율
- 1년 미만 그룹: 96.6% 완료율
- 완료자 평균 근속: 2.8년
- 미완료자 평균 근속: 2.2년
- **인사이트:** 근속기간이 긴 직원의 응답률이 더 높음

## 중요 사항

### 문자 인코딩

- 데이터베이스 및 Excel 파일은 **한글(UTF-8)** 인코딩 사용
- 결과 표시 시 적절한 유니코드 처리 필요
- 컬럼명 및 데이터 값에 한글 문자 포함 가능

### 데이터 프라이버시

- 직원 데이터는 민감 정보 - 가능한 경우 집계 쿼리 사용
- 개인 식별 정보를 내보내기에 노출하지 마세요
- 분석 결과 공유 시 직원 ID 익명화

### 성능 고려사항

- PMIK_2025.db는 비교적 작은 크기 (~56KB)
- 더 큰 데이터셋의 경우 (PDF에서 언급된 7.6GB), 다음을 사용:
  - 인덱스가 있는 쿼리
  - 청크 처리 (배치당 5000행)
  - 디스플레이용 페이지네이션 (페이지당 50행)

### Excel-uploader 참조

사용자가 다음이 필요한 경우:
- 새 Excel 데이터 업로드 → [../Excel-uploader](../Excel-uploader) 참조
- 테이블 생성/관리 → Excel-uploader GUI 또는 core/db_manager.py 사용
- 쿼리 결과 내보내기 → pandas `.to_excel()` 또는 Excel-uploader 내보내기 기능 사용

## 일반적인 사용자 워크플로우

### 1. 데이터 업로드 (Excel-uploader를 통해)

```bash
cd ../Excel-uploader
venv\Scripts\python main.py  # GUI 실행
# 또는 명령줄:
venv\Scripts\python upload.py ../PMIK-pilot/new_data.xlsx "테이블명" ../PMIK-pilot/PMIK_2025.db
```

### 2. 데이터 분석 (PMIK-pilot에서)

```python
# 자연어 → SQL 쿼리 → 분석
# 예시: "부서별 월간 근무 시간을 보여줘"

import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')
query = '''
SELECT
    "Biz Unit." as business_unit,
    Department,
    COUNT(*) as employee_count
FROM pmik_member
GROUP BY "Biz Unit.", Department
ORDER BY "Biz Unit.", Department
'''
df = pd.read_sql_query(query, conn)
print(df.to_string())
conn.close()
```

### 3. 결과 내보내기

```python
# Excel로 저장
df.to_excel('analysis_results.xlsx', index=False, engine='openpyxl')

# CSV로 저장 (한글용 UTF-8 BOM 포함)
df.to_csv('analysis_results.csv', index=False, encoding='utf-8-sig')
```

## 참고 문서

- **CLAUDE_CODE_ANALYSIS_USE_CASES.pdf** - 완전한 사용 사례 및 분석 시나리오 (한글)
- **[README.md](README.md)** - 프로젝트 빠른 시작 가이드 (영문)
- **[Q75_Q76_structure_analysis.md](Q75_Q76_structure_analysis.md)** - 복수 선택 문항 구조 분석 (한글)
- **../Excel-uploader/README.md** - Excel 업로드 도구 문서
- **../Excel-uploader/COMPLETE.md** - 상세 기능 목록 및 구현 가이드

## Claude Code 작업 시

이 프로젝트에서 데이터를 분석할 때:

1. **질문 이해** - 자연어 요청 파싱
2. **SQL 쿼리 생성** - 올바른 한글 테이블명 대상 지정
3. **실행 및 분석** - pandas로 결과 처리
4. **필요 시 웹 검색** - 벤치마크용: "바이오 제약 업계 효율성 평균"
5. **인사이트 제공** - 데이터 + 업계 컨텍스트 결합
6. **결과 포맷** - 표, 차트, CSV 내보내기 사용

### 분석 요청 예시

> "최근 3개월 부서별 효율성을 분석하고 전년 대비 증감을 보여줘"

**Claude Code가 수행할 작업:**
1. 최근 3개월간 해당 테이블 쿼리
2. 부서별 효율성 계산
3. 작년 동기간 비교를 위한 쿼리
4. 전년 대비 변화 계산
5. 인사이트와 함께 요약 테이블 생성
6. 요청 시 CSV로 내보내기

### Q75, Q76 복수 선택 문항 분석 예시

> "직원들이 가장 많이 선택한 동기부여 요인은?"

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# Q75 선택지별 빈도 분석
query = """
SELECT
    e.비고 as option_number,
    e."선택(보기)" as option_text,
    COUNT(*) as selection_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pmik_raw_data WHERE completed = 1), 1) as percentage
FROM pmik_raw_data r, pmik_eos e
WHERE r.completed = 1
    AND e."No." = 75.0
    AND (',' || REPLACE(r.r075, ' ', ',') || ',') LIKE ('%,' || e.비고 || ',%')
GROUP BY e.비고, e."선택(보기)"
ORDER BY selection_count DESC
LIMIT 5
"""
df = pd.read_sql_query(query, conn)

print("Top 5 동기부여 요인:")
print(df.to_string(index=False))

conn.close()
```

**출력 예시:**
```
option_number                option_text  selection_count  percentage
            3      높은 금전적 보상 수준              85        64.4
           10      일과 개인생활의 조화              76        57.6
            2         조직문화 및 분위기              68        51.5
           11    근무 환경에 대한 만족              62        47.0
            1         회사의 성장 가능성              58        43.9
```

## 프로젝트 파일 구조

```
PMIK-pilot/
├── PMIK_2025.db                      # SQLite 데이터베이스
├── pmik_eos.xlsx                     # EOS 문항 마스터
├── pmik_member.xlsx                  # 직원 마스터 데이터
├── pmik_raw_data.xlsx                # 설문 응답 원시 데이터
├── CLAUDE.md                         # Claude Code 문서 (본 파일)
├── README.md                         # 프로젝트 README (영문)
├── Q75_Q76_structure_analysis.md    # Q75/Q76 구조 분석 (한글)
├── CLAUDE_CODE_ANALYSIS_USE_CASES.pdf  # 사용 사례 문서 (한글)
├── requirements.txt                  # Python 의존성
├── setup.bat                        # Windows 설정 스크립트
├── setup.sh                         # macOS/Linux 설정 스크립트
├── check_db.py                      # 데이터베이스 확인 스크립트
├── analyze_department_responses.py  # 부서별 응답 분석
├── analyze_tenure_responses.py      # 근속기간별 응답 분석
├── .gitignore                       # Git 제외 파일
└── venv/                            # 가상환경 (setup 후 생성)
```

## 문제 해결

### Python 버전 오류

Python 3.10이 설치되어 있는지 확인:

```bash
python --version
# 또는
python3 --version
```

Python 3.10이 없다면 [python.org](https://www.python.org/downloads/)에서 다운로드하세요.

### 모듈 없음 오류

먼저 가상환경을 활성화:

```bash
# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

그런 다음 의존성 재설치:

```bash
pip install -r requirements.txt
```

### 데이터베이스 없음 오류

프로젝트 디렉토리에 있는지 확인:

```bash
cd c:\Project\PMIK-pilot  # Windows
cd /path/to/PMIK-pilot     # macOS/Linux
```

### 한글 인코딩 오류

Windows 콘솔에서 한글 출력 문제가 있는 경우:

```python
import sys
sys.stdout.reconfigure(encoding='utf-8')
```

또는 결과를 파일로 저장:

```python
df.to_csv('output.csv', encoding='utf-8-sig')
df.to_excel('output.xlsx', engine='openpyxl')
```
