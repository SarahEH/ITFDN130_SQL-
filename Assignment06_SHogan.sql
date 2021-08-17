--*************************************************************************--
-- Title: Assignment06
-- Author: SarahHogan
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-15,SarahHogan,Created File based on Assignment 6 document from Randall Root
--**************************************************************************--

Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SarahHogan')
	 Begin 
	  Alter Database [Assignment06DB_SarahHogan] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SarahHogan;
	 End
	Create Database Assignment06DB_SarahHogan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SarahHogan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

---- Show the Current data in the Categories, Products, and Inventories Tables
--Select * From Categories;
--go
--Select * From Products;
--go
--Select * From Employees;
--go
--Select * From Inventories;
--go

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/*
Basic framework for views is:
	Create View <view name>
	With Schemabinding
	As
		Select <complete statement>
	From dbo.<table name>
*/

Create View vCategories
With Schemabinding 
As
	Select CategoryID
	, CategoryName
From dbo.Categories;
go

Create View vProducts
With Schemabinding 
As
	Select ProductID
	, ProductName
	, CategoryID
	, UnitPrice
From dbo.Products;
go

Create View vEmployees
With Schemabinding 
As
	Select EmployeeID
	, EmployeeFirstName
	, EmployeeLastName
	, ManagerID
From dbo.Employees;
go

Create View vInventories
With Schemabinding 
As
	Select [InventoryID]
	, [InventoryDate]
	, [EmployeeID]
	, [ProductID]
	, [Count] --using square brackets in this script to protect 'count' as column name, not command
From dbo.Inventories;
go

Select * from vCategories;
Select * from vProducts;
Select * from vEmployees;
Select * from vInventories;
go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Basic structure will be to deny permissions from the table, and grant permissions to the view

Deny Select on Categories to Public;
Grant Select on vCategories to Public;
go

Deny Select on Products to Public;
Grant Select on vProducts to Public;
go

Deny Select on Employees to Public;
Grant Select on vEmployees to Public;
go

Deny Select on Inventories to Public;
Grant Select on vInventories to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

/*
--Copy from Assignment 05, Question #1
Select c.CategoryName, p.ProductName, p.UnitPrice
From Categories c
	Join Products p
	on c.CategoryID = p.CategoryID
Order by CategoryName, ProductName;
*/

--Wrap in a create view, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View vProductsbyCategories
As
	Select Top 100000000
	c.CategoryName, p.ProductName, p.UnitPrice
	From vCategories c
		Join vProducts p
		on c.CategoryID = p.CategoryID
	Order by CategoryName, ProductName;
go

Select * from vProductsbyCategories;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

/*
--Copy from Assignment 05, question 2
Select P.[ProductName], I.[InventoryDate], I.[Count]
From Products P
Inner Join Inventories I 
  on P.[ProductID] = I.[ProductID]
Order by P.[ProductName], I.[InventoryDate], I.[Count];
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View [vInventoriesByProductsByDates]
As
	Select Top 100000000
	P.[ProductName], I.[InventoryDate], I.[Count]
	From vProducts P
	Inner Join vInventories I 
	  on P.[ProductID] = I.[ProductID]
	Order by P.[ProductName], I.[InventoryDate], I.[Count];
go

Select * from vInventoriesByProductsByDates;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

/*
--Copy in script from Assignment 05, Question #3
Select distinct(I.InventoryDate), concat(E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName
From Inventories I
Inner Join Employees E
  on I.EmployeeID = E.EmployeeID
Order by I.InventoryDate;
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View vInventoriesByEmployeesByDates
As
	Select Distinct Top 100000000 --little bit of trial & error to get distinct before top
	I.InventoryDate
	, concat(E.EmployeeFirstName,' ',E.EmployeeLastName) as EmployeeName
	From vInventories I
	Inner Join vEmployees E
	  on I.EmployeeID = E.EmployeeID
	Order by I.InventoryDate;
go

Select * From vInventoriesByEmployeesByDates;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

/*
--Copy in script from Assignment05, question #4
--ONLY USING SQUARE BRACKETS BECAUSE OF 'COUNT' AS COLUMN NAME, NOT COMMAND
Select C.[CategoryName], P.[ProductName], I.[InventoryDate], I.[Count]
From Categories C
Inner Join Products P 
  on C.CategoryID = P.CategoryID
Inner Join Inventories I
  on P.ProductID = I.ProductID
Order by C.[CategoryName], P.[ProductName], I.[InventoryDate], I.[Count];
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View [vInventoriesByProductsByCategories]
As
	Select Top 100000000
	C.[CategoryName]
	, P.[ProductName]
	, I.[InventoryDate]
	, I.[Count]
	From vCategories C
	Inner Join vProducts P 
	  on C.CategoryID = P.CategoryID
	Inner Join vInventories I
	  on P.ProductID = I.ProductID
	Order by C.[CategoryName], P.[ProductName], I.[InventoryDate], I.[Count];
go

Select * From [vInventoriesByProductsByCategories];
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

/*
--Copy in script from Assignment05, question #5
--ONLY USING SQUARE BRACKETS BECAUSE OF 'COUNT' AS COLUMN NAME, NOT COMMAND
Select C.[CategoryName], P.[ProductName], I.[InventoryDate], I.[Count], 
  concat(E.[EmployeeFirstName],' ',E.[EmployeeLastName]) as [EmployeeName]
From Categories C
Inner Join Products P 
  on C.CategoryID = P.CategoryID
Inner Join Inventories I
  on P.ProductID = I.ProductID
Inner Join Employees E
  on I.EmployeeID = E.EmployeeID
Order by I.[InventoryDate], C.[CategoryName], P.[ProductName], E.[EmployeeFirstName], E.[EmployeeLastName];
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View [vInventoriesByProductsByEmployees]
As
	Select Top 100000000
	C.[CategoryName]
	, P.[ProductName]
	, I.[InventoryDate]
	, I.[Count]
	, concat(E.[EmployeeFirstName],' ',E.[EmployeeLastName]) as [EmployeeName]
	From vCategories C
	Inner Join vProducts P 
	  on C.CategoryID = P.CategoryID
	Inner Join vInventories I
	  on P.ProductID = I.ProductID
	Inner Join vEmployees E
	  on I.EmployeeID = E.EmployeeID
	Order by I.[InventoryDate], C.[CategoryName], P.[ProductName], E.[EmployeeFirstName], E.[EmployeeLastName];
go

Select * from vInventoriesByProductsByEmployees;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
/*
--Copy script from Assignment 05, question #6
--ONLY USING SQUARE BRACKETS BECAUSE OF 'COUNT' AS COLUMN NAME, NOT COMMAND
Select C.[CategoryName], P.[ProductName], I.[InventoryDate], I.[Count], 
  concat(E.[EmployeeFirstName],' ',E.[EmployeeLastName]) as [EmployeeName]
From Categories C
Inner Join Products P 
  on C.CategoryID = P.CategoryID
Inner Join Inventories I
  on P.ProductID = I.ProductID
Inner Join Employees E
  on I.EmployeeID = E.EmployeeID
Where P.[ProductID] in (
	Select P.[ProductID]
	From Products
	Where P.[ProductName] in ('Chai', 'Chang'))
Order by I.[InventoryDate], C.[CategoryName], P.[ProductName], E.[EmployeeFirstName], E.[EmployeeLastName];
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View [vInventoriesForChaiAndChangByEmployees]
As
	Select Top 100000000
	C.[CategoryName]
	, P.[ProductName]
	, I.[InventoryDate]
	, I.[Count]
	, concat(E.[EmployeeFirstName],' ',E.[EmployeeLastName]) as [EmployeeName]
	From vCategories C
	Inner Join vProducts P 
	  on C.CategoryID = P.CategoryID
	Inner Join vInventories I
	  on P.ProductID = I.ProductID
	Inner Join vEmployees E
	  on I.EmployeeID = E.EmployeeID
	Where P.[ProductID] in (
		Select P.[ProductID]
		From vProducts P
		Where P.[ProductName] in ('Chai', 'Chang'))
	Order by I.[InventoryDate], C.[CategoryName], P.[ProductName], E.[EmployeeFirstName], E.[EmployeeLastName];
go

Select * From vInventoriesForChaiAndChangByEmployees; 
go



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

/*
--Copy script from Assignment 05, question #6
Select concat(M.EmployeeFirstName,' ', M.EmployeeLastName) as Manager, 
  concat(E.EmployeeFirstName,' ', E.EmployeeLastName) as Employee
From Employees E
Inner Join Employees M
  on E.ManagerID = M.EmployeeID
Order by Manager, Employee;
go
*/

--Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View vEmployeesByManager
As
	Select Top 100000000
	concat(M.EmployeeFirstName,' ', M.EmployeeLastName) as Manager
	, concat(E.EmployeeFirstName,' ', E.EmployeeLastName) as Employee
	From vEmployees E
	Inner Join vEmployees M
	  on E.ManagerID = M.EmployeeID
	Order by Manager, Employee;
go

Select * from vEmployeesByManager;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan
/*
--Step 1: Examine root tables
Select * From Categories
Select * From Products
Select * From Inventories
Select * From Employees

--Step 2 - make a giant select with all column names and joins on ID LINKS
Select 
c.CategoryID, c.CategoryName --from categories
, p.ProductID, p.ProductName, p.UnitPrice --from products
, i.InventoryID, i.InventoryDate, i.Count --from inventories
, e.EmployeeID, concat(e.EmployeeFirstName,' ', e.EmployeeLastName) as Employee --from employees
, m.Manager -- from manager view
From vCategories c
	Join vProducts p on c.CategoryID = p.CategoryID
	Join vInventories i on p.ProductID = i.ProductID
	Join vEmployees e on i.EmployeeID = e.EmployeeID
	Join vEmployeesByManager m on concat(e.EmployeeFirstName,' ', e.EmployeeLastName) = m.Employee;
go
*/
--Step 3: Wrap in a 'create view' statement, include additional 'TOP ###' syntax for order by to work
--FINAL ANSWER:
Create View vInventoriesByProductsByCategoriesByEmployees
As
	Select Top 100000000
	c.CategoryID, c.CategoryName --from categories
	, p.ProductID, p.ProductName, p.UnitPrice --from products
	, i.InventoryID, i.InventoryDate, i.Count --from inventories
	, e.EmployeeID, concat(e.EmployeeFirstName,' ', e.EmployeeLastName) as Employee --from employees
	, m.Manager -- from manager view
	From vCategories c
		Join vProducts p on c.CategoryID = p.CategoryID
		Join vInventories i on p.ProductID = i.ProductID
		Join vEmployees e on i.EmployeeID = e.EmployeeID
		Join vEmployeesByManager m on concat(e.EmployeeFirstName,' ', e.EmployeeLastName) = m.Employee
	Order by 1, 2, 3, 4;
go

Select * From vInventoriesByProductsByCategoriesByEmployees;
go


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/