import sqlite3
import random
import time
from datetime import datetime

def randomDate(start, end):
  frmt = '%d-%m-%Y %H:%M:%S'
  stime = time.mktime(time.strptime(start, frmt))
  etime = time.mktime(time.strptime(end, frmt))
  ptime = stime + random.random() * (etime - stime)
  dt = datetime.fromtimestamp(time.mktime(time.localtime(ptime)))
  return dt

first_names = ['Иван', 'Петр', 'Андрей', 'Александр', 'Анатолий', 'Павел', 'Алексей', 'Борис', 'Илья', 'Денис', \
            'Кузьма', 'Владимир', 'Константин', 'Степан', 'Антон', 'Ашот', 'Кэмел', 'Никита']
last_names = ['Иванов', 'Смирнов', 'Кузнецов', 'Попов', 'Васильев', 'Петров', 'Соколов', 'Михайлов', 'Новиков', \
            'Федоров', 'Сидоров', 'Морозов', 'Зверев', 'Камалиев', 'Лагутин', 'Воробьев']
city = ['Москва', 'Петербург', 'Новгород', 'Рязань', 'Казань', 'Киров', 'Челябинск', 'Екатеринбург', 'Ижевск', \
        'Калининград', 'Якутск', 'Кукмор', 'Сочи', 'Крым', 'Вятские Поляны', 'Бугульма']

streets = ['Ленина', 'Мира', 'Зеленая', 'Заречная', 'Заречная', 'Набережная', 'Садовая', 'Новая', 'Советская', \
        'Лесная', 'Школьная', 'Молодежная', 'Центральная', 'Пионерская', 'Кирова', 'Береговая', 'Южная', 'Степная', \
        'Солнечная', 'Северная', 'Первомайская', 'Гагарина', 'Комсомольская', 'Октябрьская', 'Луговая', 'Полевая']

objects = ['Кодеин', 'Морфин', 'Наркотин', 'Папаверин', 'Тебаин', 'Тримеперидин', 'Ацетилсалициловая кислота', \
        'Ибупрофен', 'Диклофенак', 'Кетопрофен', 'Кеторолак', 'Парацетамол и Панадол', 'Клоназепам', 'Бензобарбитал', \
        'Сандиммун Неорал', 'Саквинавир', 'Даридорексант', 'Зероцид', 'Желатиноль', 'Алпразолам', 'Флузол', 'Флударабин']

def clear_table(conn, table):
  cur = conn.cursor()
  cur.execute("DELETE FROM " + table)
  conn.commit() # write changes to db
  cur.close()

def insert_many(conn, q, vals):
  cur = conn.cursor()
  cur.executemany(q, vals)
  cur.close()

def gen_customers(n):
  lst = []
  for id in range(n):
    name = random.choice(first_names) + ' ' + random.choice(last_names)
    adr = random.choice(city) + ", " + "ул. " + random.choice(streets) + ", " + "дом " + str(random.choice(range(1, 1000))) + ", " + "кв. " + str(random.choice(range(1, 100)))
    lst.append((id + 1, name, adr))  
  return lst 

def gen_benefits(n):
  lst = []
  for id in range(n):
    name = random.choice(objects)
    price = random.choice(range(500, 10000))
    # закономерность: товар с длинным описанием обычно дешевле
    if len(name) > 15:
      price -= random.choice(range(100, 500))
    producer = random.choice(city)
    lst.append((id + 1, name, price, producer))  
  return lst 

def gen_recipes(n, orders, benefits):
  lst = []
  for id in range(n):
    order_id = random.choice(orders)[0]
    benefit_id = random.choice(benefits)[0]
    # закономерность: длина товара зависит от номера льготы
    # льгота будет относиться к самым распространенным, если длина товара меньше обычного
    benefit_name = random.choice(benefits)[1]
    if len(benefit_name) <= 6:
        quantity = random.choice(range(1, 5))
    elif len(benefit_name) < 10:
        quantity = random.choice(range(6, 10))
    else:
        quantity = random.choice(range(11, 30))
    lst.append((id + 1, order_id, benefit_id, quantity))  
  return lst

def gen_orderStatus(n):
  lst = []
  for id in range(n):
    if id % 4 == 0:
        status = 200
    else:
        status = 400
    lst.append((id + 1, status))  
  return lst 

def gen_orders(n, customers, orderStatus):
  lst = []
  for id in range(n):
    cust_id = random.choice(customers)[0]
    amount = 1
    max_amt = amount + 4
    sale_time = str(randomDate("20-01-2018 12:30:00", "20-11-2022 04:50:34"))

    if sale_time[0:4] == '2020': # из-за ковида больше заказывали льготы в 2020
      max_amt += random.choice(range(5, 10))

    elif sale_time[0:4] == '2022': # из-за войны больше заказывали льготы в 2020
      max_amt += random.choice(range(10, 15))

    total_amount = random.choice(range(amount, max_amt))
    status_id = random.choice(orderStatus)[0]

    lst.append((id + 1, cust_id, total_amount, status_id, sale_time))  
  return lst

# def gen_test(n):
#   lst = []
#   for id in range(n):

#     sale_time = str(randomDate("20-01-2018 12:30:00", "20-11-2022 04:50:34"))

#     lst.append((sale_time, ))  
#   return lst

def main():
    conn = sqlite3.connect("llo.db")

    clear_table(conn, 'Customer')
    clear_table(conn, 'Benefit')
    clear_table(conn, 'OrderStatus')
    clear_table(conn, 'Orders')
    clear_table(conn, 'Recipe')
    # clear_table(conn, 'test')

    customers = gen_customers(100)
    # print(customers)

    benefits = gen_benefits(50)
    # print(benefits)

    orderStatus = gen_orderStatus(10000)
    # print(orderStatus)

    orders = gen_orders(10000, customers, orderStatus)
    # print(orders)

    recipes = gen_recipes(10000, orders, benefits)
    # print(recipes)

    # test = gen_test(2)
    # print(test)
    
    insert_many(conn, 'insert into Customer (CustomerID, Name, Address) values (?, ?, ?)', customers)
    insert_many(conn, 'insert into Benefit (BenefitID, Name, price, producer) values (?, ?, ?, ?)', benefits)
    insert_many(conn, 'insert into OrderStatus (OrderStatusID, StatusCode) values (?, ?)', orderStatus)
    insert_many(conn, 'insert into Orders (OrderID, CustomerID, TotalAmount, OrderStatusID, ReliseDateTime) values (?, ?, ?, ?, ?)', orders)
    insert_many(conn, 'insert into Recipe (RecipeID, OrderID, BenefitID, Quantity) values (?, ?, ?, ?)', recipes)
    # insert_many(conn, 'insert into test values (?)', test)

    conn.commit()
    conn.close()

if __name__ == "__main__":
  main()
