import sqlite3

def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)
    return conn

def simple_query(conn, q):
    cur = conn.cursor()
    cur.execute(q)
    rows = cur.fetchall()
    return rows[0][0]

def main():
    conn = create_connection("access.db")
    
    print('1) посетителей на сайте за месяц =', simple_query(conn, "select count(distinct id_bask) from Books;"))

    print('2) в среднем посетителей за час=', simple_query(conn, "SELECT avg(a.cnt) from ( SELECT strftime('%Y-%m-%d %H', query_date) as hr, count(distinct id_bask) as cnt from Books group by hr) as a;"))

    print("3) сколько посетителей сделало заказы =", simple_query(conn, "select count(distinct id_bask) from Books where request='order.phtml';"));
    print("4) сколько страниц просмотрел посетитель:")
    print(" в среднем = {}, максимум = {}, минимум = {}"\
      .format(simple_query(conn, "select avg(a.cnt) from ( select id_bask, count(request) as cnt from Books group by id_bask) as a;"),\
        simple_query(conn, "select max(a.cnt) from ( select id_bask, count(request) as cnt from Books group by id_bask) as a;"),\
        simple_query(conn, "select min(a.cnt) from ( select id_bask, count(request) as cnt from Books group by id_bask) as a;")\
      )\
    )
    print("5) cколько времени прошло с момента входа на сайт до оформления заказа:")
    print(" в среднем = {} минут, максимум = {} минут, минимум = {} минут"\
      .format(simple_query(conn, " select avg((julianday(b.query_date) - julianday(a.query_date))*1440) from (select * from Books where request='catalog.phtml' group by id_bask) as a join (select * from Books where request='order.phtml' group by id_bask) as b on a.id_bask=b.id_bask;"),\
        simple_query(conn, " select max((julianday(b.query_date) - julianday(a.query_date))*1440) from (select * from Books where request='catalog.phtml' group by id_bask) as a join (select * from Books where request='order.phtml' group by id_bask) as b on a.id_bask=b.id_bask;"),\
        simple_query(conn, " select min((julianday(b.query_date) - julianday(a.query_date))*1440) from (select * from Books where request='catalog.phtml' group by id_bask) as a join (select * from Books where request='order.phtml' group by id_bask) as b on a.id_bask=b.id_bask;")\
      )\
    )
    print("6) в среднем заказов оформляется за день =", simple_query(conn, "SELECT avg(a.cnt) from ( SELECT strftime('%Y-%m-%d', query_date) as dy, count(distinct id_bask) as cnt from Books where request='order.phtml' group by dy) as a;"));


if __name__ == "__main__":
  main()
