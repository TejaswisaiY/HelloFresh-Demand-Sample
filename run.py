"""Run every query in sql/ against the CSV data and write results/ ."""
import csv, glob, os, sqlite3

here = os.path.dirname(os.path.abspath(__file__))
con = sqlite3.connect(":memory:")
con.execute("CREATE TABLE hf_quarterly (year INTEGER, q INTEGER, quarter TEXT, orders_m REAL, revenue_eur_m REAL, marketing_pct REAL, note TEXT)")
con.execute("CREATE TABLE hf_sources (quarter TEXT, metric TEXT, value REAL, source TEXT, url TEXT)")
for table in ("hf_quarterly", "hf_sources"):
    with open(os.path.join(here, "data", table + ".csv"), newline="", encoding="utf-8") as f:
        rows = list(csv.reader(f))[1:]
    rows = [[None if v == "" else v for v in r] for r in rows]
    con.executemany(f"INSERT INTO {table} VALUES ({','.join('?' * len(rows[0]))})", rows)

os.makedirs(os.path.join(here, "results"), exist_ok=True)
for path in sorted(glob.glob(os.path.join(here, "sql", "*.sql"))):
    name = os.path.splitext(os.path.basename(path))[0]
    cur = con.execute(open(path, encoding="utf-8").read())
    out = cur.fetchall()
    with open(os.path.join(here, "results", name + ".csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow([d[0] for d in cur.description]); w.writerows(out)
    print(f"{name}: {len(out)} row(s)")
