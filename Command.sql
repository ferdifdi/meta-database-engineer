CREATE VIEW OrdersView AS
SELECT Order_ID, Quantity, Total_Cost
FROM LittleLemonDB.Orders
WHERE Quantity > 2;
SHOW DATABASES;
Select * from OrdersView;
Select * from Orders;
Select * from LittleLemonDB.Orders;

SELECT c.customer_id, c.customer_name, o.order_id, o.total_cost, m.menu_name, mi.course_name
FROM Customer_Details AS c
JOIN Orders AS o ON c.customer_id = o.customer_id
JOIN Menu AS m ON o.menu_id = m.menu_id
JOIN Menu_Items AS mi ON m.menu_item_id = mi.menu_item_id
WHERE o.total_cost > 150
ORDER BY o.total_cost ASC;

SELECT menu_name
FROM Menu
WHERE menu_id = ANY (
    SELECT menu_id
    FROM Orders
    GROUP BY menu_id
    HAVING COUNT(*) > 2
);

DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    DECLARE max_quantity INT;
    SELECT MAX(quantity) INTO max_quantity
    FROM Orders;
    SELECT max_quantity AS 'Maximum Quantity';
END // 
DELIMITER ;

CALL GetMaxQuantity();

DELIMITER //
CREATE PROCEDURE GetOrderDetail(IN CustomerID INT)
BEGIN
    SET @query = 'SELECT order_id, quantity, total_cost FROM Orders WHERE customer_id = ?';
    SET @param = CustomerID;
    PREPARE stmt FROM @query;
    EXECUTE stmt USING @param;
    DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS GetMaxQuantity;
DROP PROCEDURE IF EXISTS GetOrderDetail;

-- SET @id = 1;
-- EXECUTE GetOrderDetail USING @id;

CALL GetOrderDetail(1);

DELIMITER //
CREATE PROCEDURE CancelOrder(IN OrderID INT)
BEGIN
    DELETE FROM Orders WHERE order_id = OrderID;
END//
DELIMITER ;

CALL CancelOrder(1);
