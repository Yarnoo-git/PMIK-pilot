# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PMIK-pilot is a Python 3.10-based proof-of-concept implementation for HR data analysis using Claude Code with SQLite and web search capabilities. This project demonstrates the use cases outlined in [CLAUDE_CODE_ANALYSIS_USE_CASES.pdf](CLAUDE_CODE_ANALYSIS_USE_CASES.pdf).

**Purpose:** Enable natural language HR data analysis by combining:
- SQLite database queries for internal data
- Web search for industry benchmarks and best practices
- AI-powered insights and recommendations

**Related Project:** [Excel-uploader](../Excel-uploader) - A Python GUI application for uploading Excel files to SQLite databases

## Technology Stack

- **Python Version:** 3.10 (Required)
- **Database:** SQLite 3
- **Data Format:** Excel files (.xlsx) with Korean encoding support
- **Key Libraries:**
  - `sqlite3` - Database operations (built-in)
  - `pandas` >= 2.0.0 - Data manipulation
  - `openpyxl` >= 3.1.0 - Excel file handling

## Environment Setup

### Initial Setup

**Windows:**
```batch
setup.bat
```

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

This will:
1. Verify Python 3.10 installation
2. Create virtual environment (`venv/`)
3. Install dependencies from `requirements.txt`

### Activate Virtual Environment

**Windows:**
```batch
venv\Scripts\activate
```

**macOS/Linux:**
```bash
source venv/bin/activate
```

### Verify Setup

```bash
python check_db.py
```

### Deactivate Virtual Environment

```bash
deactivate
```

**Important:** Always activate the virtual environment before running Python scripts in this project.

## Database Structure

### Primary Database: PMIK_2025.db

This SQLite database contains EOS (Employee Opinion Survey) data.

**Tables:**

1. **`pmik_eos`** (99 rows, 7 columns)
   - Source: pmik_eos.xlsx
   - Purpose: EOS survey question bank
   - Structure: 77 unique questions (Q1~Q77), with Q75 and Q76 having 12 rows each for multiple-choice options
   - Columns:
     - `대분류` (TEXT) - Major category (e.g., "Value", "비전/전략", "기타")
     - `중분류` (TEXT) - Middle category (e.g., "가치인식", "이해도", "동기부여 및 저해 요인")
     - `소분류` (TEXT) - Sub category (e.g., "자기인식", "공유도", "동기부여 요인")
     - `No.` (REAL) - Question number (1.0~77.0)
     - `문항` (TEXT) - Survey question text
     - `선택(보기)` (TEXT) - Answer options
       - Q1~Q74: 5-point Likert scale (①전혀 그렇지 않다 ~ ⑤매우 그렇다)
       - Q75, Q76: Multiple-choice options (12 options each, select 3)
       - Q77: Open-ended question
     - `비고` (TEXT) - Remarks/notes
       - For Q75, Q76: Option number (1~12) for response mapping

   **Special Questions:**
   - **Q75** (12 rows): "업무 몰입 동기부여 요인" - Select 3 out of 12 motivating factors
     - Each row has same `No.` (75.0) and `문항`, but different `선택(보기)` and `비고` (1~12)
     - Maps to `pmik_raw_data.r075` (e.g., "4 11 10" means options 4, 11, 10)
   - **Q76** (12 rows): "업무 몰입 저해 요인" - Select 3 out of 12 hindering factors
     - Each row has same `No.` (76.0) and `문항`, but different `선택(보기)` and `비고` (1~12)
     - Maps to `pmik_raw_data.r076` (e.g., "1 6 7" means options 1, 6, 7)

2. **`pmik_member`** (139 rows, 15 columns)
   - Source: pmik_member.xlsx
   - Purpose: Employee master data for survey participants
   - Columns:
     - `ID(new)` (TEXT) - Employee ID (e.g., "KR0005")
     - `Name(Kor.)` (TEXT) - Name in Korean
     - `Contract` (TEXT) - Contract type (정규직/계약직)
     - `Temperory` (REAL) - Temporary status
     - `Job Title` (TEXT) - Job grade (B2, E1, S3, etc.)
     - `입사일` (TIMESTAMP) - Hire date
     - `근속기간` (TEXT) - Tenure period (e.g., "7년 5개월")
     - `Email` (TEXT) - Email address
     - `근로시간` (INTEGER) - Weekly work hours
     - `Biz Unit.` (TEXT) - Business unit
     - `Department` (TEXT) - Department name
     - `Team` (TEXT) - Team name
     - `Unnamed: 12~14` - Reserved/metadata columns

3. **`pmik_raw_data`** (138 rows, 126 columns)
   - Source: pmik_raw_data.xlsx
   - Purpose: EOS survey responses (raw data)
   - Response rate: 95.7% (132/138 completed)
   - Column groups:
     - **Basic info** (27 columns): id, surveys_id, name, corporate_id, email, rank, etc1 (business unit), etc2 (team), created_at, completed_at, completed
     - **Response columns** (99 columns): r001~r099
       - r001~r077: Likert scale responses (1-5)
       - r078~r100: Open-ended and demographic questions
   - Key columns:
     - `id` (INTEGER) - Response ID
     - `name` (TEXT) - Respondent name
     - `corporate_id` (TEXT) - Employee ID (links to pmik_member)
     - `email` (TEXT) - Email address
     - `rank` (TEXT) - Job grade (B1, B2, B3, S2, S3, E1, E2)
     - `etc1` (TEXT) - Business unit (Sales, O&F, A&R)
     - `etc2` (TEXT) - Team/Department
     - `completed` (INTEGER) - Completion status (1=completed, 0=in progress)
     - `r001~r077` (REAL) - Likert scale answers (1-5)
   - Response distribution:
     - 5점 (매우 그렇다): 1,269 responses (12.7%)
     - 4점 (그렇다): 3,370 responses (33.8%)
     - 3점 (보통): 3,029 responses (30.4%)
     - 2점 (그렇지 않다): 1,468 responses (14.7%)
     - 1점 (전혀 그렇지 않다): 632 responses (6.3%)

**Querying Examples:**

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# Query EOS questions by category
df = pd.read_sql_query("SELECT * FROM pmik_eos WHERE 대분류 = 'Value'", conn)

# Query all members
df = pd.read_sql_query("SELECT * FROM pmik_member", conn)

# Query members by department
df = pd.read_sql_query("SELECT * FROM pmik_member WHERE Department = 'Sales'", conn)

# Query raw survey responses
df = pd.read_sql_query("SELECT * FROM pmik_raw_data WHERE completed = 1", conn)

# Join responses with employee data
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

# Query Q75/Q76 multiple-choice options
# Example: Get text for response "4 11 10"
response_75 = "4 11 10"
option_numbers = response_75.split()  # ['4', '11', '10']

query = f"""
SELECT 비고, "선택(보기)" as option_text
FROM pmik_eos
WHERE "No." = 75.0 AND 비고 IN ({','.join(option_numbers)})
ORDER BY 비고
"""
df = pd.read_sql_query(query, conn)
print("Q75 selected options:")
print(df)

# Analyze most common motivating factors (Q75)
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

### Source Excel Files

- `pmik_eos.xlsx` - EOS work data export
- `pmik_member.xlsx` - Member/employee data export

These files are uploaded to the SQLite database using the Excel-uploader program.

## Common Development Commands

### Database Operations

```bash
# Check database tables using Python
python -c "import sqlite3; conn = sqlite3.connect('PMIK_2025.db'); \
cursor = conn.cursor(); \
cursor.execute('SELECT name FROM sqlite_master WHERE type=\"table\"'); \
print([t[0] for t in cursor.fetchall()])"

# Query database with pandas
python -c "import pandas as pd; import sqlite3; \
conn = sqlite3.connect('PMIK_2025.db'); \
df = pd.read_sql_query('SELECT * FROM \"EOS 근무\" LIMIT 5', conn); \
print(df)"
```

### Excel File Operations

When working with Excel files, use the Excel-uploader reference:

```bash
# Navigate to Excel-uploader directory
cd ../Excel-uploader

# Activate virtual environment
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux

# Upload Excel to SQLite
python upload.py <excel_file> <table_name> [db_path]

# Example: Upload to PMIK database
python upload.py ../PMIK-pilot/pmik_eos.xlsx "EOS 근무" ../PMIK-pilot/PMIK_2025.db
```

## Architecture & Key Concepts

### Claude Code Analysis Workflow

Based on CLAUDE_CODE_ANALYSIS_USE_CASES.pdf, the analysis flow is:

1. **Natural Language Question** - User asks in Korean/English
2. **Database Query** - Generate and execute SQL queries
3. **Data Analysis** - Process results, calculate metrics
4. **Web Search** (Optional) - Fetch industry benchmarks, best practices
5. **Insight Generation** - Combine internal + external data
6. **Actionable Report** - Present findings with recommendations

### Analysis Scenarios (from PDF)

**Basic Analysis:**
- Work hours by department/month
- Efficiency trends by center
- Work patterns by job grade
- Night shift analysis

**Advanced Analysis:**
- Anomaly detection with root cause analysis
- Labor cost optimization with market data
- Recruitment planning with industry trends
- Benchmarking against competitors

**Decision Support:**
- Flexible work schedule impact analysis
- ROI calculations for policy changes
- Strategic workforce planning

### Database Schema Patterns

Expected table structures (based on use cases):

**daily_analysis_results table:**
- `employee_id` - Employee identifier
- `analysis_date` - Date of work record
- `center_name` - Department/center name
- `team_name` - Team name
- `actual_work_hours` - Actual hours worked
- `claimed_work_hours` - Claimed hours
- `efficiency_ratio` - Efficiency percentage
- `confidence_score` - Data reliability score
- `meeting_minutes` - Meeting time
- `rest_minutes` - Break time
- `shift_type` - Work shift (day/night)
- `equipment_minutes` - Equipment usage time

**employees table:**
- `employee_id` - Employee identifier
- `employee_name` - Employee name
- `job_grade` - Job level/position
- `department` - Department
- `hire_date` - Hire date

### Integration with Excel-uploader

The Excel-uploader project provides the data pipeline:

**Core Components:**
- `core/db_manager.py` - SQLite operations with chunked inserts
- `core/excel_loader.py` - Multi-sheet Excel loading with auto-merge
- `main.py` - GUI application for database management

**Key Features:**
- Multi-sheet Excel support
- Automatic datatype inference
- Progress tracking
- Transaction management
- Export to Excel/CSV

## Data Analysis Patterns

### Basic Queries

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# Query all EOS questions
df = pd.read_sql_query("SELECT * FROM eos_questions", conn)

# Query by category
df = pd.read_sql_query("""
    SELECT 대분류, 중분류, 문항
    FROM eos_questions
    WHERE 대분류 = 'Value'
""", conn)

# Query members (excluding header row)
df = pd.read_sql_query("""
    SELECT * FROM members
    WHERE "Unnamed: 0" != 'ID(new)'
""", conn)

conn.close()
```

### Efficiency Analysis Template

```python
# Calculate efficiency by department
query = '''
SELECT
    부서명 as department,
    COUNT(DISTINCT 사원번호) as employee_count,
    ROUND(AVG(실제근무시간), 2) as avg_work_hours,
    ROUND(AVG(효율성비율) * 100, 2) as avg_efficiency
FROM "EOS 근무"
WHERE 분석일자 >= date('now', '-30 days')
GROUP BY 부서명
ORDER BY avg_efficiency DESC
'''
```

### Date Range Filtering

Handle both integer (20250101) and string ('2025-01-01') date formats:

```python
# For integer date format (YYYYMMDD)
WHERE CAST(date_column AS INTEGER) >= 20250101
  AND CAST(date_column AS INTEGER) <= 20251231

# For string date format
WHERE date(date_column) >= '2025-01-01'
  AND date(date_column) <= '2025-12-31'
```

## Important Notes

### Character Encoding

- Database and Excel files use **Korean (UTF-8)** encoding
- When displaying results, ensure proper Unicode handling
- Column names and data values may contain Korean characters

### Data Privacy

- Employee data is sensitive - use aggregated queries when possible
- Do not expose personal identifiable information in exports
- When sharing analysis results, anonymize employee IDs

### Performance Considerations

- PMIK_2025.db is relatively small (~56KB)
- For larger datasets (as mentioned in PDF: 7.6GB), use:
  - Indexed queries
  - Chunked processing (5000 rows/batch)
  - Pagination for display (50 rows/page)

### Excel-uploader Reference

When users need to:
- Upload new Excel data → Reference [../Excel-uploader](../Excel-uploader)
- Create/manage tables → Use Excel-uploader GUI or core/db_manager.py
- Export query results → Use pandas `.to_excel()` or Excel-uploader export feature

## Typical User Workflows

### 1. Data Upload (via Excel-uploader)

```bash
cd ../Excel-uploader
venv\Scripts\python main.py  # Launch GUI
# Or command line:
venv\Scripts\python upload.py ../PMIK-pilot/new_data.xlsx "Table Name" ../PMIK-pilot/PMIK_2025.db
```

### 2. Data Analysis (in PMIK-pilot)

```python
# Natural language → SQL query → Analysis
# Example: "Show me monthly work hours by department"

import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')
query = '''
SELECT
    strftime('%Y-%m', 분석일자) as month,
    부서명 as department,
    SUM(실제근무시간) as total_hours
FROM "EOS 근무"
GROUP BY month, department
ORDER BY month DESC, total_hours DESC
'''
df = pd.read_sql_query(query, conn)
print(df.to_string())
conn.close()
```

### 3. Export Results

```python
# Save to Excel
df.to_excel('analysis_results.xlsx', index=False, engine='openpyxl')

# Save to CSV (with UTF-8 BOM for Korean)
df.to_csv('analysis_results.csv', index=False, encoding='utf-8-sig')
```

## Reference Documents

- **CLAUDE_CODE_ANALYSIS_USE_CASES.pdf** - Complete use cases and analysis scenarios (Korean)
- **../Excel-uploader/README.md** - Excel upload tool documentation
- **../Excel-uploader/COMPLETE.md** - Detailed feature list and implementation guide

## Working with Claude Code

When analyzing data in this project:

1. **Understand the question** - Parse natural language requests
2. **Generate SQL queries** - Target the correct Korean table names
3. **Execute and analyze** - Process results with pandas
4. **Web search if needed** - For benchmarks: "바이오 제약 업계 효율성 평균"
5. **Provide insights** - Combine data + industry context
6. **Format output** - Use tables, charts, CSV exports

### Example Analysis Request

> "최근 3개월 부서별 효율성을 분석하고 전년 대비 증감을 보여줘"
> (Analyze department efficiency for the last 3 months and show year-over-year changes)

**Claude Code should:**
1. Query `EOS 근무` table for recent 3 months
2. Calculate efficiency by department
3. Query same period last year for comparison
4. Calculate YoY changes
5. Generate summary table with insights
6. Export to CSV if requested
