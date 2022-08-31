# 1.3. Качество данных

## Оценю, насколько качественные данные хранятся в источнике.
Качество данных проверил с помощь запросов через dbeaver 
Значений NULL нет
Дублирующих значений нет


## Укажу, какие инструменты обеспечивают качество данных в источнике.
На примере двух таблиц из схемы production products и orderitems

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