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

INSERT INTO Bookings (booking_id, date, table_number, customer_id) VALUES (1, '2022-10-10', 5, 1);
INSERT INTO Bookings (booking_id, date, table_number, customer_id) VALUES (2, '2022-11-12', 3, 3);
INSERT INTO Bookings (booking_id, date, table_number, customer_id) VALUES (3, '2022-10-11', 2, 2);
INSERT INTO Bookings (booking_id, date, table_number, customer_id) VALUES (4, '2022-10-13', 2, 1);

select * from bookings;

DELIMITER //
CREATE PROCEDURE CheckBooking(IN pDate DATE, IN pTableNumber INT)
BEGIN
    DECLARE TableStatus VARCHAR(50);
    SET TableStatus = (
        SELECT CASE WHEN COUNT(*) > 0 THEN CONCAT('Table ', pTableNumber, ' is already booked')
                    ELSE 'Table is available'
               END
        FROM Bookings
        WHERE Date = pDate AND Table_Number = pTableNumber
    );
    SELECT TableStatus AS Status;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS CheckBooking;

CALL CheckBooking('2022-10-10', 5);
CALL CheckBooking('2022-10-10', 7);

DELIMITER //

CREATE PROCEDURE AddValidBooking(IN pBookingDate DATE, IN pTableNumber INT)
BEGIN
    DECLARE TableStatus INT;
    DECLARE ErrorMessage VARCHAR(100);
    
    START TRANSACTION;
    
    -- Check if the table is already booked on the given date
    SELECT COUNT(*) INTO TableStatus
    FROM Bookings
    WHERE Date = pBookingDate AND Table_Number = pTableNumber;
    
    IF TableStatus > 0 THEN
        -- The table is already booked, rollback the transaction
        SET ErrorMessage = CONCAT('Table ', pTableNumber, ' is already booked - booking cancelled.');
        ROLLBACK;
    ELSE
        -- The table is available, proceed with the booking and commit the transaction
        INSERT INTO Bookings (Date, Table_Number)
        VALUES (pBookingDate, pTableNumber);
        COMMIT;
        SET ErrorMessage = 'Booking successful.';
    END IF;
    
    SELECT ErrorMessage AS Status;
    
END//

DELIMITER ;

DROP PROCEDURE IF EXISTS AddValidBooking;

select * from bookings;
CALL AddValidBooking('2022-10-10', 6);

DELIMITER //
CREATE PROCEDURE AddBooking(IN pBookingID INT, IN pCustomerID INT, IN pTableNumber INT, IN pBookingDate DATE)
BEGIN
    INSERT INTO Bookings (Booking_ID, date, table_number, Customer_ID)
    VALUES (pBookingID, pBookingDate, pTableNumber, pCustomerID);
    
    SELECT 'Booking added successfully.' AS Status;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS AddBooking;

Call AddBooking(6,2,7,'2022-10-10');

select * from bookings;

DELIMITER //

CREATE PROCEDURE UpdateBooking(IN pBookingID INT, IN pBookingDate DATE)
BEGIN
    UPDATE Bookings
    SET Date = pBookingDate
    WHERE Booking_ID = pBookingID;
    
    SELECT CONCAT('Booking ', pBookingID, ' is updated.') AS Status;
END//

DELIMITER ;

CALL UpdateBooking(6, '2022-11-12');

select * from bookings;

DELIMITER //

CREATE PROCEDURE CancelBooking(IN pBookingID INT)
BEGIN
    DECLARE bookingCount INT;
    
    SELECT COUNT(*) INTO bookingCount
    FROM Bookings
    WHERE Booking_ID = pBookingID;
    
    IF bookingCount > 0 THEN
        DELETE FROM Bookings
        WHERE Booking_ID = pBookingID;
        
        SELECT CONCAT('Booking ', pBookingID, ' is cancelled.') AS Status;
    ELSE
        SELECT 'Booking not found.' AS Status;
    END IF;
END//

DELIMITER ;

CALL CancelBooking(6);

select * from bookings;
