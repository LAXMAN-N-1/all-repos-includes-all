import sys
with open("env_check.txt", "w") as f:
    try:
        import psycopg2
        f.write("psycopg2: OK\n")
    except ImportError as e:
        f.write(f"psycopg2: FAIL - {e}\n")
    
    try:
        import alembic
        f.write("alembic: OK\n")
    except ImportError as e:
        f.write(f"alembic: FAIL - {e}\n")
