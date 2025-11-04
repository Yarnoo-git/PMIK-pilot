import sqlite3

conn = sqlite3.connect('PMIK_2025.db')
cursor = conn.cursor()

# Get tables
cursor.execute('SELECT name FROM sqlite_master WHERE type="table"')
tables = cursor.fetchall()

print('Tables:')
for t in tables:
    print(f'  - {t[0]}')

print('\nSchema:')
for t in tables:
    print(f'\n{t[0]}:')
    cursor.execute(f'PRAGMA table_info({t[0]})')
    for col in cursor.fetchall():
        print(f'  {col[1]} ({col[2]})')

conn.close()
