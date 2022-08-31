# Витрина RFM

**Необходимо создать витрину данных для RFM-классификации пользователей приложения. Заказчик — компания, которая разрабатывает приложение по доставке еды.
Что такое RFM
RFM (от англ. Recency, Frequency, Monetary Value) — способ сегментации клиентов, при котором анализируют их лояльность: как часто, на какие суммы и когда в последний раз тот или иной клиент покупал что-то. На основе этого выбирают клиентские категории, на которые стоит направить маркетинговые усилия.
Каждого клиента оценивают по трём факторам:
Recency (пер. «давность») — сколько времени прошло с момента последнего заказа.
Frequency (пер. «частота») — количество заказов.
Monetary Value (пер. «денежная ценность») — сумма затрат клиента.**

## 1.1. Выясню требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом  выясним у заказчика детали. Запросим недостающую информацию у заказчика и сформулируем DOD.

{Создать витрину dm_rfm_segments на основе представлений из production созданых в analysis.
данные за 2022 год по заказам со статусом closed со следующими столбцами user_id, recency, frequency, monetary)value. 
Фактор Recency измеряется по последнему заказу. Распределить клиентов по шкале от одного до пяти.
Фактор Frequency оценивается по количеству заказов. Распределить клиентов по шкале от одного до пяти
Фактор Monetary Value оценивается по потраченной сумме. Распределить клиентов по шкале от одного до пяти}

## 1.2. Изучу структуру исходных данных.

Полключивщись к базе данных и изучил структуру таблиц.

Зафиксирую, какие поля буду использовать для расчета витрины.

-----------

{user_id,order_id,payment,order_ts,status}


# 1.3. Качество данных

## Оценю, насколько качественные данные хранятся в источнике.
* Качество данных проверил с помощь запросов через dbeaver 
* Значений NULL нет
* Дублирующих значений нет

## Укажу, какие инструменты обеспечивают качество данных в источнике.
На примере двух таблиц из схемы production 

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.Products | id  | int NOT NULL PRIMARY KEY  | Обеспечивает уникальность записей о пользователях и отстутсвие значений NULL, задаёт формат типичного выбора для целых чисел| 
|production.Products  |"name"| varchar(2048) NOT NULL|Обеспечивает отстутсвие значений NULL, задаёт строковый тип дпнных|
|production.Products  |price| numeric(19, 5) NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric))|Задаёт вещественный тип с заданным масшатабом и точностью, не null, значение по умолчанию 0, с проверкой на положительность и приведением к numeric|
|production.Products|Products|ALTER TABLE production.orderitems OWNER TO jovyan|Назначает владельцем пользователя|
|production.Products|Products|GRANT ALL ON TABLE production.orderitems TO jovyan|Наделяет всеми правми пользователя|
|production.orderitems| id | int4 NOT NULL GENERATED ALWAYS AS IDENTITY  | Обеспечивает уникальность записей о пользователях и отстутсвие значений NULL, авоматически генерируется при создании добавляя все время еденицу к предыдущему значению, задаёт формат типичного выбора для целых чисел с ограничением по памяти|
|production.orderitems|product_id|int4 UNIQUE NOT NULL|Обеспечивает уникальность записей и отсутствие NULL значений, целочисленность|
|production.orderitems|"name"| varchar(2048) NOT NULL|Обеспечивает отсутствие NULL значений строковый тип данных|
|production.orderitems|price| numeric(19, 5) NOT NULL DEFAULT 0 CHECK ((price >= (0)::numeric))| значение по умолчанию,вещественный тип числа  с заданым масштабом и точностью значения, обеспечивает отсутствие NULL значений, больше или равно 0 дополнительное приведение к numeric|
|production.orderitems|discount |numeric(19, 5) NOT NULL DEFAULT 0 CHECK (((discount >= (0)::numeric) AND (discount <= price))|Вещественный тип числа с заданным масшатабом и точностью, не NULL, значение по умолчанию 0, всегда больше или равно 0 и меньше или равно цене|
|production.orderitems|quantity| int4 NOT NULL CHECK ((quantity > 0))|цулочисленное 4 байта, не NULL, с проверкой на положительность|
|production.orderitems|orderitems|ALTER TABLE production.orderitems OWNER TO jovyan|Назначает владельцем пользователя|
|production.orderitems|orderitems|GRANT ALL ON TABLE production.orderitems TO jovyan|Наделяет всеми правми пользователя|


## 1.4. Подготовлю витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделаю VIEW для таблиц из базы production.

Нас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), я решаю сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишу SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполню их. 
Код создания VIEW.

```SQL
create view analysis.orderitems as
     select *
     from production.orderitems;
create view analysis.orders as
     select *
     from production.orders;
create view analysis.orderstatuses as
     select *
     from production.orderstatuses;
create view analysis.products as
     select *
     from production.products;   
create view analysis.users as
     select *
     from production.users;  
```

### 1.4.2. Напишу DDL-запрос для создания витрины.

Далее мне необходимо создать витрину. Напишу CREATE TABLE запрос и выполню его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE analysis.dm_rfm_segments (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5),
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5),
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
 );
```

### 1.4.3. Напишу SQL запрос для заполнения витрины

Наконец, реализую расчет витрины на языке SQL и заполню таблицу, созданную в предыдущем пункте.

Код запроса.

```SQL
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
select u.id,
       ntile(5) over (order by sum(payment)) as monetary_value
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;
insert into analysis.tmp_rfm_frequency (user_id, frequency) 
select u.id, 
       ntile(5) over (order by count(order_id)) as frequency 
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;

insert into analysis.tmp_rfm_recency (user_id, recency)
SELECT u.id,
       NTILE(5) OVER (ORDER BY (CURRENT_DATE - date_trunc('day', max(order_ts)))) as recency
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;

insert into dm_rfm_segments (user_id, recency, frequency, monetary_value)
select r.user_id,
       recency,
       frequency,
       monetary_value 
from analysis.tmp_rfm_recency as r full outer join analysis.tmp_rfm_frequency as f on r.user_id  = f.user_id
full outer join analysis.tmp_rfm_monetary_value as m on r.user_id  = m.user_id


```

|user_id|recency|frequency|monetary_value|
|-------|-------|---------|--------------|
|0      |5      |3        |4             |
|1      |2      |3        |3             |
|2      |4      |3        |5             |
|3      |4      |3        |3             |
|4      |2      |3        |3             |
|5      |2      |5        |5             |
|6      |5      |3        |5             |
|7      |2      |2        |2             |
|8      |5      |2        |3             |
|9      |5      |3        |2             |
## Результат

**Уточнив требования разработали выгрузку из созданных представлений для витрины RFM**
