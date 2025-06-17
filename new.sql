CREATE DATABASE BQP_db;
USE BQP_db;

CREATE TABLE Categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INT,
    description VARCHAR(200)
);

SELECT * FROM Categories ;

INSERT INTO Categories VALUES
	(1, 'Electronics', NULL, 'All electronic devices and accessories'),
	(2, 'Clothing', NULL, 'Fashion items for men, women and children'),
	(3, 'Home & Kitchen', NULL, 'Products for home improvement and kitchenware'),
	(4, 'Smartphones', 1, 'Mobile phones with smart features'),
	(5, 'Laptops', 1, 'Portable computers'),
	(6, 'Men\'s Fashion', 2, 'Clothing for men'),
	(7, 'Women\'s Fashion', 2, 'Clothing for women'),
	(8, 'Cookware', 3, 'Pots, pans and cooking utensils');

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

INSERT INTO Products VALUES
	(1, 'iPhone 15 Pro', 'Latest Apple smartphone with A17 Pro chip', 999.00, 50, 4),
	(2, 'Samsung Galaxy S23', 'Android flagship with 200MP camera', 799.99, 75, 4),
	(3, 'MacBook Pro 14"', 'Apple laptop with M2 Pro chip', 1999.00, 30, 5),
	(4, 'Dell XPS 15', 'Premium Windows laptop with OLED display', 1499.99, 40, 5),
	(5, 'Men\'s Casual Shirt', '100% cotton slim fit shirt', 29.99, 200, 6),
	(6, 'Women\'s Summer Dress', 'Lightweight floral print dress', 39.99, 150, 7),
	(7, 'Non-Stick Cookware Set', '10-piece ceramic non-stick set', 89.99, 80, 8),
	(8, 'Wireless Earbuds', 'Bluetooth 5.2 with 20hr battery', 49.99, 120, 1),
	(9, 'Smart Watch', 'Fitness tracking with heart rate monitor', 129.99, 90, 1),
	(10, 'Jeans - Classic Fit', 'Men\'s denim jeans with stretch', 59.99, 180, 6);

CREATE TABLE Customers(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE,
    address VARCHAR(200)
);

SELECT * FROM Customers ;

INSERT INTO Customers VALUES
	(1, 'John', 'Smith', 'john.smith@example.com', '555-0101', '123 Main St, Anytown, USA'),
	(2, 'Sarah', 'Johnson', 'sarah.j@example.com', '555-0102', '456 Oak Ave, Somewhere, USA'),
	(3, 'Michael', 'Brown', 'michael.b@example.com', '555-0103', '789 Pine Rd, Nowhere, USA'),
	(4, 'Emily', 'Davis', 'emily.d@example.com', '555-0104', '321 Elm Blvd, Anywhere, USA'),
	(5, 'David', 'Wilson', 'david.w@example.com', '555-0105', '654 Maple Ln, Everywhere, USA');

CREATE TABLE Orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10,2),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

SELECT * FROM Orders ;

INSERT INTO Orders VALUES
	(1, 1, '2023-10-15 09:30:00', 999.00, 'delivered'),
	(2, 2, '2023-10-16 14:15:00', 169.98, 'shipped'),
	(3, 3, '2023-10-17 11:45:00', 1999.00, 'processing'),
	(4, 1, '2023-10-18 16:20:00', 129.99, 'pending'),
	(5, 4, '2023-10-19 10:00:00', 229.97, 'shipped');

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

INSERT INTO Order_items VALUES
	(1, 1, 1, 1, 999.00),
	(2, 2, 8, 2, 49.99),
	(3, 2, 9, 1, 129.99),
	(4, 3, 3, 1, 1999.00),
	(5, 4, 9, 1, 129.99),
	(6, 5, 5, 3, 29.99),
	(7, 5, 6, 2, 39.99);

-- 1. List all products with their names and prices, sorted by price from highest to lowest?
SELECT product_id,product_name,price FROM Products
ORDER BY price DESC;

-- 2. Show all customers with their full names and email addresses?
SELECT customer_id, CONCAT(first_name,' ',last_name) AS Customer_name, email FROM Customers;

-- 3. Display all orders with their order dates and total amounts.
SELECT order_id,order_date,total_amount FROM Orders;

-- 4. Find all products in the 'Electronics' category?
SELECT p.*,c.category_name FROM Products p
JOIN Categories c ON p.category_id=c.category_id
WHERE c.category_name='Electronics';

-- 5. List all subcategories under the 'Clothing' parent category?
SELECT category_id,category_name,description FROM categories
WHERE parent_category_id IN (
	SELECT category_id FROM Categories
	WHERE category_name='Clothing');

-- 6. Show the count of products in each category.
SELECT ct.category_id,ct.category_name,COUNT(p.product_id) AS Total_Products 
FROM Categories ct
LEFT JOIN Products p
ON ct.category_id=p.category_id
GROUP BY ct.category_id,ct.category_name;

-- 7. Find products with less than 100 items in stock?
SELECT * FROM Products
WHERE stock_quantity <100;

-- 8. List products priced between $50 and $150?
SELECT * FROM Products
WHERE price BETWEEN 50 AND 150;

-- 9. Show the average price of products in each category.
SELECT ct.category_id,ct.category_name,ROUND(AVG(p.price),2) AS Average_price 
FROM Categories ct
LEFT JOIN Products p
ON ct.category_id=p.category_id
GROUP BY ct.category_id,ct.category_name;

-- 10. Display all orders made by customer 'John Smith'?
SELECT CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name, o.*
FROM Orders o
JOIN Customers c 
ON c.customer_id=o.customer_id
WHERE CONCAT(c.first_name,' ',c.last_name)='John Smith';

-- 11. Find customers who haven't placed any orders yet?
SELECT c.*,o.order_id AS Total_Orders FROM Customers c
LEFT JOIN Orders o
ON c.customer_id=o.customer_id
WHERE o.order_id IS NULL;

-- 12. Show the total amount spent by each customer?
SELECT  CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name,SUM(o.total_amount) AS Total_Spent FROM Customers c
JOIN Orders o
ON c.customer_id=o.customer_id
GROUP BY  CONCAT(c.first_name,' ',c.last_name);

-- 13. List all items in order #2 with their quantities and prices?
SELECT p.product_name, oi.* 
FROM Order_items oi
JOIN Products p 
ON p.product_id=oi.product_id
JOIN Orders o
ON o.order_id=oi.order_id
WHERE  o.order_id=2;

-- 14. Find orders that contain more than 2 items?
SELECT o.*, SUM(oi.quantity) AS Total_items FROM Orders o
JOIN Order_items oi
ON o.order_id=oi.order_id
GROUP BY o.order_id
HAVING SUM(oi.quantity) >2;

-- 15. Show the most frequently ordered product (by quantity)?
SELECT p.product_id,p.product_name,SUM(oi.quantity) AS Total_Quantity
FROM Products p
JOIN Order_items oi 
ON oi.product_id=p.product_id
GROUP BY p.product_id,oi.quantity
ORDER BY Total_Quantity DESC
LIMIT 5;

-- 16. Calculate the total revenue generated from each product category?
SELECT ct.category_id,ct.category_name,SUM(oi.quantity*oi.unit_price) AS Total_Revenue 
FROM Categories ct
JOIN Products p 
ON ct.category_id=p.category_id
JOIN Order_items oi 
ON oi.product_id=p.product_id
GROUP BY ct.category_id,ct.category_name
ORDER BY ct.category_id,Total_Revenue ;

-- 17. Find customers who have spent more than $500 in total?
SELECT  CONCAT(c.first_name,' ',c.last_name) AS Cutomer_Name, SUM(o.total_amount) AS Total_Spend 
FROM Customers c
JOIN Orders o 
ON c.customer_id=o.customer_id
GROUP BY  CONCAT(c.first_name,' ',c.last_name) 
HAVING SUM(o.total_amount) >500.00;

-- 18. Show the month with the highest number of orders?
SELECT 
	MONTH(order_date) AS Month,
    MONTHNAME(order_date) AS Month_Name,
    COUNT(*) AS Total_Orders FROM Orders
GROUP BY Month, Month_Name
ORDER BY Total_Orders DESC
LIMIT 1;