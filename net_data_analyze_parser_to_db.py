#^"[0-9]+";
import sqlite3
import csv

from net_data_analyze_selecter import create_connection as cc, \
    simple_query as sq

def swap_date(date):
    x = date.split('-')
    return x[2] + '-' + x[1] + '-' + x[0]

def main():
    conn = cc('access.db')
    cur = conn.cursor()

    with open('govno.csv', 'r') as data:
        dr = csv.DictReader(data)
        to_db = [(i['id_bask'],swap_date(i['query_date'].split()[0]) + ' ' + i['query_date'].split()[1], i['request'], i['id_book']) for i in dr]
    
    cur.executemany("INSERT INTO Books (id_bask, query_date, request, id_book) VALUES (?, ?, ?, ?);", to_db)
    conn.commit()
    conn.close()

if __name__ == "__main__":
  main()