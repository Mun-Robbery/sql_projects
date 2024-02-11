--DROP DATABASE IF EXISTS Z_Phone
GO
--CREATE DATABASE Z_Phone
GO
USE Z_Phone

-- удаление объектов БД если они существуют чтобы заново создать

DROP VIEW IF EXISTS [dbo].[view_SuppliersStatus]
GO
DROP VIEW IF EXISTS [dbo].[view_InAvailable]
GO
DROP VIEW IF EXISTS [dbo].[view_discounts_products]
GO
DROP FUNCTION IF EXISTS [dbo].[f_chckProductRemain]
GO
DROP FUNCTION IF EXISTS [dbo].[f_SumProductRemain]
GO
DROP FUNCTION IF EXISTS [dbo].[f_createNewSaleId]
GO
DROP PROCEDURE IF EXISTS [dbo].[sp_customerOrders]
GO
DROP PROCEDURE IF EXISTS [dbo].[sp_InsertProductInSale]
GO
DROP PROCEDURE IF EXISTS [dbo].[sp_CreateSale]
GO
DROP PROCEDURE IF EXISTS [dbo].[sp_fillRemains]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sales_details]') AND type in (N'U'))
DROP TABLE [dbo].[sales_details]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sales]') AND type in (N'U'))
DROP TABLE [dbo].[sales]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shops_remains]') AND type in (N'U'))
DROP TABLE [dbo].[shops_remains]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[products_supplies]') AND type in (N'U'))
DROP TABLE [dbo].[products_supplies]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[products]') AND type in (N'U'))
DROP TABLE [dbo].[products]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shops]') AND type in (N'U'))
DROP TABLE [dbo].[shops]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[customers]') AND type in (N'U'))
DROP TABLE [dbo].[customers]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cities]') AND type in (N'U'))
DROP TABLE [dbo].[cities]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[employees]') AND type in (N'U'))
DROP TABLE [dbo].[employees]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[discounts]') AND type in (N'U'))
DROP TABLE [dbo].[discounts]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[suppliers]') AND type in (N'U'))
DROP TABLE [dbo].[suppliers]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lots]') AND type in (N'U'))
DROP TABLE [dbo].[lots]
GO

-- создание объектов БД

CREATE TABLE dbo.cities (CityId INT PRIMARY KEY,
						NAME NVARCHAR(255),
						PhoneCode NVARCHAR(255),
						TimeZone NVARCHAR(255))

CREATE TABLE dbo.customers (CustomerId INT PRIMARY KEY, 
						FirstName NVARCHAR(255), 
						LastName NVARCHAR(255),
						DateOfBirth DATE, 
						DateOfEntry DATE,
						CityId INT)


CREATE TABLE dbo.shops (ShopId INT PRIMARY KEY,
						CityId INT,
						DateOfEntry DATE,
						[Address] NVARCHAR(255))

CREATE TABLE dbo.employees (EmployeeId INT PRIMARY KEY,
							FirstName NVARCHAR(255),
							LastName NVARCHAR(255),
							DateOfBirth DATE,
							DateOfEntry DATE)


CREATE TABLE dbo.discounts (DiscountId INT PRIMARY KEY,
							[Description] NVARCHAR(MAX),
							[Percent] INT)

CREATE TABLE dbo.suppliers (SupplierId INT PRIMARY KEY,
							Name NVARCHAR(255),
							DateOfEntry DATE)

CREATE TABLE dbo.products (ProductId INT PRIMARY KEY,
						   LotId INT,
						   SupplierId INT,
						   Color NVARCHAR(55),
						   Price INT,
						   Memory INT,
						   DiscountId INT)

CREATE TABLE dbo.lots (LotId INT PRIMARY KEY,
					   Brand NVARCHAR(255),
					   Model NVARCHAR(255),
					   Camera INT,
					   Processor NVARCHAR(255),
					   Display FLOAT,
					   Corpus NVARCHAR(255))
						   

CREATE TABLE dbo.shops_remains (ShopId INT,
								ProductId INT,
								[Count] INT,
								PRIMARY KEY (ShopId, ProductId))

CREATE TABLE dbo.sales (SaleId INT PRIMARY KEY ,
						CustomerId INT,
						EmployeeId INT,
						ShopId INT,
						SaleDate DATETIME)


CREATE TABLE dbo.sales_details (SaleId INT,
								ProductId INT,
								[Count] INT,
								PRIMARY KEY (SaleId, ProductId))
GO

CREATE TABLE dbo.products_supplies (SupplyId INT,
									ProductId INT,
									SupplierId INT,
									count INT,
									[status] BIT,
									[datetime] DATETIME,
									PRIMARY KEY (SupplyId, ProductId))


-- создание внешних ключей
ALTER TABLE [dbo].[shops]  WITH CHECK ADD  CONSTRAINT [FK_shops_cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[cities] ([CityID])
GO
ALTER TABLE [dbo].[shops] CHECK CONSTRAINT [FK_shops_cities]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [FK_products_lots] FOREIGN KEY([LotId])
REFERENCES [dbo].[lots] ([LotID])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [FK_products_lots]
GO
ALTER TABLE [dbo].[shops_remains]  WITH CHECK ADD  CONSTRAINT [FK_shops_remains_products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[products] ([ProductId])
GO
ALTER TABLE [dbo].[shops_remains] CHECK CONSTRAINT [FK_shops_remains_products]
GO
ALTER TABLE [dbo].[sales_details]  WITH CHECK ADD  CONSTRAINT [FK_sales_details_sales] FOREIGN KEY([SaleId])
REFERENCES [dbo].[sales] ([SaleID])
GO
ALTER TABLE [dbo].[sales_details] CHECK CONSTRAINT [FK_sales_details_sales]
GO
ALTER TABLE [dbo].[sales_details]  WITH CHECK ADD  CONSTRAINT [FK_sales_details_products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[products] ([ProductId])
GO
ALTER TABLE [dbo].[sales_details] CHECK CONSTRAINT [FK_sales_details_products]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [FK_products_suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[suppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [FK_products_suppliers]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [FK_products_discounts] FOREIGN KEY([DiscountId])
REFERENCES [dbo].[discounts] ([DiscountId])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [FK_products_discounts]
GO
ALTER TABLE [dbo].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_customers] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[customers] ([CustomerId])
GO
ALTER TABLE [dbo].[sales] CHECK CONSTRAINT [FK_sales_customers]
GO
ALTER TABLE [dbo].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_employees] FOREIGN KEY([EmployeeId])
REFERENCES [dbo].[employees] ([EmployeeId])
GO
ALTER TABLE [dbo].[sales] CHECK CONSTRAINT [FK_sales_employees]
GO
ALTER TABLE [dbo].[sales]  WITH CHECK ADD  CONSTRAINT [FK_sales_shops] FOREIGN KEY([ShopId])
REFERENCES [dbo].[shops] ([ShopID])
GO
ALTER TABLE [dbo].[sales] CHECK CONSTRAINT [FK_sales_shops]
GO
ALTER TABLE [dbo].[shops_remains]  WITH CHECK ADD  CONSTRAINT [FK_shops_remains_shops] FOREIGN KEY([ShopId])
REFERENCES [dbo].[shops] ([ShopID])
GO
ALTER TABLE [dbo].[shops_remains] CHECK CONSTRAINT [FK_shops_remains_shops]
GO
ALTER TABLE [dbo].[customers]  WITH CHECK ADD  CONSTRAINT [FK_customers_cities] FOREIGN KEY([CityID])
REFERENCES [dbo].[cities] ([CityID])
GO
ALTER TABLE [dbo].[customers] CHECK CONSTRAINT [FK_customers_cities]
GO
ALTER TABLE [dbo].[products_supplies]  WITH CHECK ADD  CONSTRAINT [FK_products_supplies_suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[suppliers] ([SupplierId])
GO
ALTER TABLE [dbo].[products_supplies] CHECK CONSTRAINT [FK_products_supplies_suppliers]
GO
ALTER TABLE [dbo].[products_supplies]  WITH CHECK ADD  CONSTRAINT [FK_products_supplies_products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[products] ([ProductId])
GO
ALTER TABLE [dbo].[products_supplies] CHECK CONSTRAINT [FK_products_supplies_products]
GO

-- заполнение таблиц
INSERT INTO employees
VALUES (1, 'Егоров', 'Вадим', '1999-09-24', '2014-03-03'),
(2, 'Зарипов', 'Глеб', '2003-08-27', '2015-05-24'),
(3, 'Скоков', 'Матвей', '2003-11-13', '2015-10-13'),
(4, 'Доррохов', 'Иван', '2003-04-14', '2015-02-05')

INSERT INTO cities
VALUES (1, 'Москва', '495', 'UTC+3'),
(2, 'Санкт-Петербург', '812', 'UTC+3')

INSERT INTO suppliers
VALUES (1, 'Pro-Phone', '2007-05-12'),
(2, 'Best-Phone', '2008-12-14'),
(3, 'First-Sup', '2008-07-02')

INSERT INTO lots
VALUES (1, 'Apple', 'IPhone 12', 12, 'A14 Bionic', 6.1, 'Ceramic Shield'),
(2, 'Apple', 'IPhone 12 Pro', 12, 'A14 Bionic', 6.1, 'Ceramic Shield'),
(3, 'Apple', 'IPhone 12 Pro Max', 12, 'A14 Bionic', 6.7, 'Ceramic Shield'),
(4, 'Apple', 'IPhone 13', 12, 'A15 Bionic', 6.1, 'Ceramic Shield'),
(5, 'Apple', 'IPhone 13 Pro', 12, 'A15 Bionic', 6.1, 'Ceramic Shield'),
(6, 'Apple', 'IPhone 13 Pro Max', 12, 'A15 Bionic', 6.7, 'Ceramic Shield')

INSERT INTO discounts
VALUES (1, 'Сезонная скидка', 5),
(2, 'Категориальная скидка', 7),
(3, 'Восстановленный', 20)

INSERT INTO customers
VALUES (1, 'Паркер', 'Питер', '2003-12-07', '2015-10-27', 1),
(2, 'Кюри', 'Мария', '2003-09-11', '2015-11-29', 1),
(3, 'Мэри', 'Куин', '2004-10-28', '2015-09-16', 2),
(4, 'Сноу', 'Джон', '1995-10-25', '2015-05-14', 1),
(5, 'Анжи', 'Олег', '2003-04-07', '2015-02-24', 2),
(6, 'Вайт', 'Волтер', '1975-03-15', '2015-10-17', 1)

-- ShopId - центральный склад
INSERT INTO shops
VALUES 
(0, 1, '1991-07-03', 'ЦЕНТРАЛЬНЫЙ СКЛАД: Звездный бульвар, д 19'),
(1, 1, '2003-12-07', 'Проспект 60-летия октября 11'),
(2, 1, '2003-09-11', 'Ул. Плешеево Дом 18'),
(3, 2, '2004-10-28', 'Ул. Думская Дом 24'),
(4, 2, '1995-10-25', 'Ул. Пушкина Дом Колотушкина')


INSERT INTO products
VALUES (1, 1, 1, 'Blue', 60000, 64, 3),
(2, 1, 3, 'Black', 60000, 128, 3),
(3, 2, 2, 'Gold', 75000, 256, 1), 
(4, 2, 1, 'White', 80000, 128, 1),
(5, 1, 1, 'Silver', 65000, 64, NULL),
(6, 3, 3, 'Black', 90000, 256, 1),
(7, 4, 3, 'Red', 100000, 256, NULL),
(8, 5, 1, 'Purple',105000, 512, 2),
(9, 6, 3, 'White', 120000, 1024, NULL)

INSERT INTO sales
VALUES (1, 1, 1, 4, '2022-12-01'),
(2, 2, 1, 3, '2022-12-02'),
(3, 2, 2, 3, '2022-12-03'), 
(4, 3, 1, 1, '2022-12-03'),
(5, 4, 3, 1, '2022-12-04'),
(6, 5, 4, 2, '2022-12-04'),
(7, 6, 4, 4, '2022-12-05'),
(8, 5, 2, 2, '2022-12-05'),
(9, 4, 3, 4, '2022-12-06')

INSERT INTO sales_details
VALUES (1, 1, 1),
(1, 2, 1),
(2, 6, 1),
(3, 4, 2),
(4, 3, 1),
(5, 4, 3),
(6, 7, 1),
(7, 4, 1),
(7, 3, 1),
(8, 9, 2),
(9, 8, 1)

INSERT INTO shops_remains
VALUES 
	   (0, 1, 150),
	   (0, 2, 100),
	   (0, 3, 200),
	   (0, 4, 170),
	   (0, 5, 180),
	   (0, 6, 250),
	   (0, 7, 300),
	   (0, 8, 700),
	   (0, 9, 230),
	   (1, 1, 15),
	   (1, 2, 9),
	   (1, 3, 20),
	   (1, 4, 13),
	   (1, 5, 11),
	   (1, 6, 4),
	   (1, 7, 3),
	   (1, 8, 15),
	   (1, 9, 19),
	   (2, 1, 0),
	   (2, 2, 15),
	   (2, 3, 14),
	   (2, 4, 3),
	   (2, 5, 14),
	   (2, 6, 16),
	   (2, 7, 19),
	   (2, 8, 11),
	   (2, 9, 9),
	   (3, 1, 14),
	   (3, 2, 16),
	   (3, 3, 11),
	   (3, 4, 7),
	   (3, 5, 14),
	   (3, 6, 15),
	   (3, 7, 12),
	   (3, 8, 13),
	   (3, 9, 16),
	   (4, 1, 9),
	   (4, 2, 11),
	   (4, 3, 14),
	   (4, 4, 12),
	   (4, 5, 3),
	   (4, 6, 11),
	   (4, 7, 16),
	   (4, 8, 13),
	   (4, 9, 12)

	   	INSERT INTO products_supplies
		VALUES (1, 1, 1, 11, 'True', '1999-09-24')

GO




/* триггер на таблицу sales_details, который вычитает количество по товару в определенном магазине в shops_remains, 
срабатывает при покупке */
CREATE TRIGGER [dbo].[tr_changeProductCount]
ON [dbo].[sales_details]
AFTER INSERT 
AS 
	BEGIN 
		UPDATE shops_remains SET [count] = (SELECT [count] FROM shops_remains AS SR WHERE SR.ShopId = (SELECT s.ShopId FROM inserted AS i 
																										LEFT JOIN sales AS s ON s.SaleId = i.SaleId) AND
														SR.ProductId = (SELECT ProductId FROM inserted)) - (SELECT TOP 1 [count] FROM inserted) 

											WHERE ShopId = (SELECT s.ShopId FROM inserted AS i LEFT JOIN sales AS s ON s.SaleId = i.SaleId) AND
														ProductId = (SELECT ProductId FROM inserted)
	END
GO

ALTER TABLE [dbo].[sales_details] ENABLE TRIGGER [tr_changeProductCount]
GO

/* функция поиска товара на складах, возвращает в каких магазинах и 
какое колво опр товара осталось */
CREATE FUNCTION [dbo].[f_chckProductRemain] (
@prm_ProductId INT)
RETURNS TABLE AS
    
    RETURN (SELECT * FROM dbo.shops_remains WHERE ProductId = @prm_ProductId)
GO
-- функция возвращающая сумму остатков по продукту
CREATE FUNCTION [dbo].[f_SumProductRemain] (
@prm_ProductId INT)
RETURNS TABLE AS
    
    RETURN (SELECT SUM(COUNT) AS ProductCount FROM dbo.shops_remains WHERE ProductId = @prm_ProductId)
GO

-- процедура, создающая новый заказ
CREATE PROCEDURE [dbo].[sp_CreateSale]

	@prm_SaleId INT,
	@prm_CustomerId INT,
	@prm_EmployeeId INT,
	@prm_ShopId INT

	AS

	BEGIN

		INSERT INTO sales
		VALUES (@prm_SaleId, @prm_CustomerId, @prm_EmployeeId, @prm_ShopId, GETDATE())

	END

	
GO

--функция которая возвращает новый id для нового заказа, используется при вызове процедуры sp_CreateSale
CREATE FUNCTION [dbo].[f_createNewSaleId]
()
RETURNS INT
	BEGIN 
		RETURN (SELECT MAX(SaleId)+1 FROM sales)
	END
GO
-- процедура которая добавляет информацию по позициям заказа - какой продукт и какое количество купили
CREATE PROCEDURE [dbo].[sp_InsertProductInSale]

	@prm_SaleId INT,
	@prm_ProductId INT,
	@prm_Count INT

	AS

	BEGIN
		INSERT INTO sales_details
		VALUES (@prm_SaleId, @prm_ProductId, @prm_Count)
	END

GO

-- процедура, проходящаяся по таблице остатков для того чтобы проверить где колво меньше 10. Если находит, то отправляет заявку поставщику на покупку колво + 20
CREATE PROCEDURE [dbo].[sp_fillRemains]

AS 

		DROP TABLE IF EXISTS #remains
		SELECT ROW_NUMBER() OVER(ORDER BY SR.ShopId ASC) AS Row#, * INTO #remains FROM shops_remains AS SR WHERE SR.ShopId <> 0;
	
		DECLARE counts_cursor CURSOR FOR SELECT Row# FROM #remains;
		OPEN counts_cursor;

		DECLARE @row INT;

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF (SELECT [count] FROM #remains WHERE Row# = @row) < 10
				BEGIN
					INSERT INTO products_supplies
					VALUES ((SELECT MAX(SupplyId)+1 FROM products_supplies), (SELECT ProductId FROM #remains WHERE Row# = @row), 2, 20, 'False', GETDATE())
					
				END
				FETCH NEXT FROM counts_cursor INTO @row;
		END 


		CLOSE counts_cursor;
		DEALLOCATE counts_cursor;	
GO
/* триггер на таблицу shops_remains, который создает новую поставку если количество < 10 */

CREATE TRIGGER [dbo].[tr_AddCountInRemains]
ON [dbo].[shops_remains]
AFTER UPDATE 
AS 
	BEGIN 

					IF (SELECT TOP 1 [count] from inserted) < 10
						BEGIN
							INSERT INTO products_supplies
							VALUES ((SELECT MAX(SupplyId)+1 FROM products_supplies), (SELECT TOP 1 ProductId FROM inserted), 2, 20, 'False', GETDATE())
						END

	END
GO

ALTER TABLE [dbo].[shops_remains] ENABLE TRIGGER [tr_AddCountInRemains]
GO
-- триггер, добавляющий в магазин товары
CREATE TRIGGER [dbo].[tr_AddInStore]
ON [dbo].[products_supplies]
AFTER INSERT 
AS 
	BEGIN 
		
		UPDATE shops_remains SET [count] = (SELECT [count] FROM shops_remains 
												WHERE ShopId = 0 AND ProductId = (SELECT TOP 1 ProductId FROM inserted)) + (SELECT TOP 1 [count] FROM inserted) 
		WHERE ShopId = 0 AND ProductId = (SELECT ProductId FROM inserted)
	END
GO

ALTER TABLE [dbo].[products_supplies] ENABLE TRIGGER [tr_AddInStore]
GO
-- представление, отображающее цену учет ассортимента продукции
CREATE VIEW [dbo].[view_InAvailable]

AS

SELECT L.Brand, L.Model, P.Color, P.Price, S.Address, SR.[Count] FROM shops_remains AS SR
LEFT JOIN products AS P ON SR.ProductId = P.ProductId
LEFT JOIN shops AS S ON S.ShopId = SR.ShopId
LEFT JOIN Lots AS L ON L.LotId = P.LotId
WHERE count > 0
GO
-- представление, отображающее прейскурант с учетом скидок
CREATE VIEW [dbo].[view_discounts_products]

AS

SELECT L.Brand, L.Model, P.Color, p.price,(P.Price - P.Price * (ISNULL(d.[Percent], 0) * 0.01)) AS price_with_discount, d.description FROM products AS p
LEFT JOIN Discounts AS D ON D.DiscountId = p.discountId
LEFT JOIN Lots AS L ON L.LotId = P.LotId
GO
-- представление, отображающее статус выполнение поставки у поставщика. 1 - выполнено, 0 - в процессе
CREATE VIEW [dbo].[view_SuppliersStatus]

AS

SELECT S.Name, L.Brand, L.Model, P.Color, count, [status]
FROM products_supplies AS PS LEFT JOIN  suppliers AS S ON S.SupplierId = PS.SupplierId
LEFT JOIN products AS P ON p.ProductId = PS.ProductId LEFT JOIN Lots AS L ON L.LotId = P.LotId

GO
-- функция истории заказов клиента по имени и фамилии
CREATE PROCEDURE [dbo].[sp_customerOrders] (
@prm_Name VARCHAR(255),
@prm_Surname VARCHAR(255))
AS
    
    SELECT  Brand, Model, Count, SaleDate
	FROM sales as s
	JOIN sales_details as d 
	on s.SaleId = d.SaleId
	JOIN customers as c
	on s.CustomerId = c.CustomerId
	JOIN products as p
	on d.ProductId = p.ProductId
	JOIN lots as l
	on p.LotId = l.LotId
	WHERE LastName = @prm_Surname AND FirstName = @prm_Name

	IF @@ROWCOUNT < 1 RAISERROR('Пользователь не найден',16,0);
GO

select * from [dbo].[view_SuppliersStatus]

SELECT * FROM employees

SELECT * FROM cities

SELECT * FROM suppliers

SELECT * FROM lots

SELECT * FROM discounts

SELECT * FROM customers

SELECT * FROM shops

SELECT * FROM products

SELECT * FROM sales

SELECT * FROM sales_details

SELECT * FROM shops_remains



-- тестовое создание заказа 
  DECLARE @a INT = (SELECT [dbo].[f_createNewSaleId]())
  EXECUTE sp_CreateSale @a, 2, 2, 2 --формирование накладной

  EXECUTE sp_InsertProductInSale @a, 2, 3 --формирование позиции в накладной
  EXECUTE sp_InsertProductInSale @a, 3, 1 --формирование позиции в накладной
  EXECUTE sp_InsertProductInSale @a, 4, 1 --формирование позиции в накладной
  EXECUTE sp_InsertProductInSale @a, 1, 2 --формирование позиции в накладной

exec [dbo].[sp_customerOrders] 'Вайт', 'Волтер' 

--exec sp_fillRemains