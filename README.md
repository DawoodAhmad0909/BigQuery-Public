# BigQuery Public Dataset
## Overview
#### Database name:BQP_db
This project involves designing and querying a relational database for an e-commerce platform named BQP_db. The database includes core entities such as Categories, Products, Customers, Orders, and Order_items. These interconnected tables store data about products and their categories, customer information, and order transactions, forming a comprehensive backend for an online store.
## Objectives 
### 1. Database Design:
Define normalized tables for various components of the e-commerce domain.
Implement relationships using primary and foreign keys.
### 2. Data Insertion:
Populate each table with representative sample data for testing and analysis.
### 3. Data Retrieval and Analysis:
Execute SQL queries to:
###### •Retrieve product listings with pricing.
###### •Display customer details and their order history.
###### •Explore category hierarchies (e.g., subcategories).
###### •Analyze product inventory and sales.
###### •Identify top-performing products and high-spending customers.
###### •Detect inactive customers and order trends.
###### •Calculate total revenue and category-wise contributions.
## Database Creation
```sql
CREATE DATABASE BQP_db;
USE BQP_db;
```
## Tables Creation
### Table: Categories 
```sql
CREATE TABLE Categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INT,
    description VARCHAR(200)
);

SELECT * FROM Categories ;
```
### Table:Products
```sql
CREATE TABLE Products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

SELECT * FROM Products ;
```
### Table: Customers
```sql
CREATE TABLE Customers(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE,
    address VARCHAR(200)
);

SELECT * FROM Customers ;
```
### Table:Orders
```sql
CREATE TABLE Orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

SELECT * FROM Orders ;
```
### Table: Order_items
```sql
CREATE TABLE Order_items(
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

SELECT * FROM Order_items ;
```
#### 1. List all products with their names and prices, sorted by price from highest to lowest?
```sql
SELECT product_id,product_name,price FROM Products
ORDER BY price DESC;
```
#### 2. Show all customers with their full names and email addresses?
```sql
SELECT customer_id, CONCAT(first_name,' ',last_name) AS Customer_name, email FROM Customers;
```
#### 3. Display all orders with their order dates and total amounts.
```sql
SELECT order_id,order_date,total_amount FROM Orders;
```
#### 4. Find all products in the 'Electronics' category?
```sql
SELECT p.*,c.category_name FROM Products p
JOIN Categories c ON p.category_id=c.category_id
WHERE c.category_name='Electronics';
```
#### 5. List all subcategories under the 'Clothing' parent category?
```sql
SELECT category_id,category_name,description FROM categories
WHERE parent_category_id IN (
        SELECT category_id FROM Categories
        WHERE category_name='Clothing');
```
#### 6. Show the count of products in each category.
```sql
SELECT ct.category_id,ct.category_name,COUNT(p.product_id) AS Total_Products 
FROM Categories ct
LEFT JOIN Products p
ON ct.category_id=p.category_id
GROUP BY ct.category_id,ct.category_name;
```
#### 7. Find products with less than 100 items in stock?
```sql
SELECT * FROM Products
WHERE stock_quantity <100;
```
#### 8. List products priced between $50 and $150.
```sql
SELECT * FROM Products
WHERE price BETWEEN 50 AND 150;
```
#### 9. Show the average price of products in each category.
```sql
SELECT ct.category_id,ct.category_name,ROUND(AVG(p.price),2) AS Average_price 
FROM Categories ct
LEFT JOIN Products p
ON ct.category_id=p.category_id
GROUP BY ct.category_id,ct.category_name;
```
#### 10. Display all orders made by customer 'John Smith'?
```sql
SELECT CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name, o.*
FROM Orders o
JOIN Customers c 
ON c.customer_id=o.customer_id
WHERE CONCAT(c.first_name,' ',c.last_name)='John Smith';
```
#### 11. Find customers who haven't placed any orders yet?
```sql
SELECT c.*,o.order_id AS Total_Orders FROM Customers c
LEFT JOIN Orders o
ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;
```
#### 12. Show the total amount spent by each customer?
```sql
SELECT  CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name,SUM(o.total_amount) AS Total_Spent FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY  CONCAT(c.first_name,' ',c.last_name);
```
#### 13. List all items in order #2 with their quantities and prices?
```sql
SELECT p.product_name, oi.* 
FROM Order_items oi
JOIN Products p 
ON p.product_id=oi.product_id
JOIN Orders o
ON o.order_id=oi.order_id
WHERE  o.order_id=2;
```
#### 14. Find orders that contain more than 2 items?
```sql
SELECT o.*, SUM(oi.quantity) AS Total_items FROM Orders o
JOIN Order_items oi
ON o.order_id=oi.order_id
GROUP BY o.order_id
HAVING SUM(oi.quantity) >2;
```
#### 15. Show the most frequently ordered product (by quantity)?
```sql
SELECT p.product_id,p.product_name,SUM(oi.quantity) AS Total_Quantity
FROM Products p
JOIN Order_items oi 
ON oi.product_id=p.product_id
GROUP BY p.product_id,oi.quantity
ORDER BY Total_Quantity DESC
LIMIT 5;
```
#### 16. Calculate the total revenue generated from each product category?
```sql
SELECT ct.category_id,ct.category_name,SUM(oi.quantity*oi.unit_price) AS Total_Revenue 
FROM Categories ct
JOIN Products p 
ON ct.category_id=p.category_id
JOIN Order_items oi 
ON oi.product_id=p.product_id
GROUP BY ct.category_id,ct.category_name
ORDER BY ct.category_id,Total_Revenue ;
```
#### 17. Find customers who have spent more than $500 in total?
```sql
SELECT  CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name, SUM(o.total_amount) AS Total_Spend 
FROM Customers c
JOIN Orders o 
ON c.customer_id=o.customer_id
GROUP BY  CONCAT(c.first_name,' ',c.last_name) 
HAVING SUM(o.total_amount) >500.00;
```
#### 18. Show the month with the highest number of orders?
```sql
SELECT 
        MONTH(order_date) AS Month,
    MONTHNAME(order_date) AS Month_Name,
    COUNT(*) AS Total_Orders FROM Orders
GROUP BY Month, Month_Name
ORDER BY Total_Orders DESC
LIMIT 1;
```
## Conclusion
The project successfully demonstrates how a well-structured relational database can be used to manage and analyze the operations of an e-commerce system. Through comprehensive SQL queries, valuable insights were derived, including sales trends, customer behavior, inventory status, and revenue performance. These analytics not only validate the robustness of the database schema but also provide a foundation for future enhancements such as integration with a web application, automation of reports, or real-time dashboards for business intelligence.


