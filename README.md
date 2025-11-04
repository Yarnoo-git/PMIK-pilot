# PMIK-pilot

PMIK-pilot is a Python 3.10-based proof-of-concept implementation for HR data analysis using Claude Code with SQLite and web search capabilities.

## Quick Start

### Prerequisites

- **Python 3.10** (Required)
- Windows, macOS, or Linux

### Installation

**Windows:**
```batch
setup.bat
```

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

### Activate Virtual Environment

**Windows:**
```batch
venv\Scripts\activate
```

**macOS/Linux:**
```bash
source venv/bin/activate
```

### Verify Installation

```bash
python check_db.py
```

## Project Structure

```
PMIK-pilot/
├── PMIK_2025.db              # SQLite database
├── pmik_eos.xlsx             # EOS question bank
├── pmik_member.xlsx          # Employee master data
├── pmik_raw_data.xlsx        # Survey responses
├── CLAUDE.md                 # Claude Code documentation
├── requirements.txt          # Python dependencies
├── setup.bat                 # Windows setup script
├── setup.sh                  # macOS/Linux setup script
├── check_db.py               # Database verification script
└── venv/                     # Virtual environment (created by setup)
```

## Database Structure

### Tables

1. **pmik_eos** (99 rows, 7 columns)
   - EOS survey question bank
   - 77 unique questions (Q1~Q77)
   - Q75, Q76: Multiple-choice questions (12 options each)

2. **pmik_member** (139 rows, 15 columns)
   - Employee master data
   - Job titles, departments, tenure information

3. **pmik_raw_data** (138 rows, 126 columns)
   - Survey responses (95.7% completion rate)
   - Likert scale responses (r001~r077)
   - Open-ended responses (r078~r099)

## Usage Examples

### Basic Database Query

```python
import sqlite3
import pandas as pd

conn = sqlite3.connect('PMIK_2025.db')

# Get all EOS questions
df = pd.read_sql_query("SELECT * FROM pmik_eos", conn)

# Get completed responses
df = pd.read_sql_query("""
    SELECT * FROM pmik_raw_data
    WHERE completed = 1
""", conn)

conn.close()
```

### Department Response Analysis

```bash
python analyze_department_responses.py
```

### Tenure-based Response Analysis

```bash
python analyze_tenure_responses.py
```

## Python Dependencies

- **pandas** >= 2.0.0 - Data manipulation and analysis
- **openpyxl** >= 3.1.0 - Excel file handling
- **sqlite3** - Database operations (built-in)

## Related Projects

- [Excel-uploader](../Excel-uploader) - Python GUI for uploading Excel files to SQLite

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Comprehensive guide for Claude Code
- **[Q75_Q76_structure_analysis.md](Q75_Q76_structure_analysis.md)** - Multiple-choice question structure
- **CLAUDE_CODE_ANALYSIS_USE_CASES.pdf** - Use cases and scenarios (Korean)

## Deactivate Virtual Environment

When you're done working:

```bash
deactivate
```

## Troubleshooting

### Python Version Error

Make sure Python 3.10 is installed:

```bash
python --version
# or
python3 --version
```

### Module Not Found Error

Activate the virtual environment first:

```bash
# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

Then reinstall dependencies:

```bash
pip install -r requirements.txt
```

### Database Not Found Error

Ensure you're in the project directory:

```bash
cd c:\Project\PMIK-pilot  # Windows
cd /path/to/PMIK-pilot     # macOS/Linux
```

## License

Internal use only.
