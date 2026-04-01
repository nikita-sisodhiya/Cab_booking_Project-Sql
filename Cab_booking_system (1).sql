Create database cab_booking


-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    RegistrationDate DATE DEFAULT GETDATE()
);

-- Drivers Table
CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    Rating DECIMAL(3,2) CHECK (Rating BETWEEN 0 AND 5)
);

-- Cabs Table
CREATE TABLE Cabs (
    CabID INT PRIMARY KEY IDENTITY(1,1),
    CabNumber VARCHAR(20) UNIQUE NOT NULL,
    CabModel NVARCHAR(50),
    CabType NVARCHAR(20) CHECK (CabType IN ('Mini', 'Sedan', 'SUV', 'Luxury')),
    DriverID INT UNIQUE,
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    CabID INT NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    PickupLocation NVARCHAR(200) NOT NULL,
    DropLocation NVARCHAR(200) NOT NULL,
    Status NVARCHAR(20) CHECK (Status IN ('Booked', 'Ongoing', 'Completed', 'Cancelled')) DEFAULT 'Booked',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);

-- Trip Details Table
CREATE TABLE TripDetails (
    TripID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT UNIQUE NOT NULL,
    TripStartTime DATETIME,
    TripEndTime DATETIME,
    DistanceKM DECIMAL(5,2),
    Fare DECIMAL(10,2),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Feedback Table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments NVARCHAR(500),
    FeedbackDate DATE DEFAULT GETDATE(),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
-- Customers
INSERT INTO Customers (Name, Phone, Email) VALUES
('Amit Sharma', '9876543210', 'amit@example.com'),
('Priya Singh', '9123456780', 'priya@example.com'),
('Rahul Verma', '9988776655', 'rahul@example.com');

-- Drivers
INSERT INTO Drivers (Name, Phone, LicenseNumber, Rating) VALUES
('Suresh Kumar', '9898989898', 'DL-1234', 4.5),
('Anil Mehta', '9797979797', 'DL-5678', 4.2),
('Vikram Chauhan', '9696969696', 'DL-9101', 4.8);

-- Cabs
INSERT INTO Cabs (CabNumber, CabModel, CabType, DriverID) VALUES
('UP14AB1234', 'Hyundai i10', 'Mini', 1),
('DL8CAF5678', 'Honda City', 'Sedan', 2),
('HR26CD9101', 'Toyota Innova', 'SUV', 3);

-- Bookings
INSERT INTO Bookings (CustomerID, CabID, PickupLocation, DropLocation, Status) VALUES
(1, 1, 'Noida Sector 15', 'Connaught Place', 'Completed'),
(2, 2, 'Saket', 'Gurgaon Cyber City', 'Ongoing'),
(3, 3, 'Dwarka', 'IGI Airport', 'Booked');

-- Trip Details
INSERT INTO TripDetails (BookingID, TripStartTime, TripEndTime, DistanceKM, Fare) VALUES
(1, '2025-08-10 10:00', '2025-08-10 10:45', 15.5, 350.00),
(2, '2025-08-12 09:30', NULL, 8.0, NULL);

-- Feedback
INSERT INTO Feedback (BookingID, Rating, Comments) VALUES
(1, 5, 'Very good service.');

--View all bookings with customer & driver details
SELECT b.BookingID, c.Name AS CustomerName, d.Name AS DriverName, cb.CabType,
       b.PickupLocation, b.DropLocation, b.Status, td.Fare
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Cabs cb ON b.CabID = cb.CabID
JOIN Drivers d ON cb.DriverID = d.DriverID
LEFT JOIN TripDetails td ON b.BookingID = td.BookingID;

-- Find top-rated drivers
SELECT Name, Rating 
FROM Drivers
WHERE Rating >= 4.5;

--Get total revenue
SELECT SUM(Fare) AS TotalRevenue
FROM TripDetails
WHERE Fare IS NOT NULL;

--List all ongoing trips
SELECT b.BookingID, c.Name, cb.CabNumber, td.DistanceKM
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Cabs cb ON b.CabID = cb.CabID
LEFT JOIN TripDetails td ON b.BookingID = td.BookingID
WHERE b.Status = 'Ongoing';
-----------------------------
-- 5. Cancelled booking percentage
-----------------------------
SELECT 
    (CAST(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS CancelledPercentage
FROM Bookings;

-----------------------------
-- 6. Longest trip by distance
-----------------------------
SELECT TOP 1 
    td.TripID, td.DistanceKM
FROM TripDetails td
ORDER BY td.DistanceKM DESC;

-----------------------------
-- 7. Average trip duration in minutes
-----------------------------
SELECT 
    AVG(DATEDIFF(MINUTE, TripStartTime, TripEndTime)) AS AvgTripMinutes
FROM TripDetails
WHERE TripStartTime IS NOT NULL AND TripEndTime IS NOT NULL;

-----------------------------
-- 8. Most popular pickup location
-----------------------------
SELECT TOP 1 PickupLocation, COUNT(*) AS TotalPickups
FROM Bookings
GROUP BY PickupLocation
ORDER BY TotalPickups DESC;

------------------------------------
-- 9. How to get all customers who have made bookings?
-------------------------------------
SELECT DISTINCT c.Name
FROM Customers c
JOIN Bookings b ON c.CustomerID = b.CustomerID;

---------------------------------------
-- 10. Find total number of bookings for each customer
----------------------------------------
SELECT c.Name, COUNT(b.BookingID) AS TotalBookings
FROM Customers c
LEFT JOIN Bookings b ON c.CustomerID = b.CustomerID
GROUP BY c.Name;

---------------------------------
-- 11. Get all completed trips with fare details
---------------------------------
SELECT b.BookingID, t.Fare
FROM Bookings b
JOIN TripDetails t ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed';

-------------------------------
-- 12. Find drivers with rating greater than 4
--------------------------------
SELECT Name, Rating
FROM Drivers
WHERE Rating > 4;

--------------------------------------
-- 13. Get total revenue generated from all trips
---------------------------------------

SELECT SUM(Fare) AS TotalRevenue
FROM TripDetails;

----------------------------------
-- 14. Find the most frequently used cab
----------------------------------

SELECT CabID, COUNT(*) AS TotalBookings
FROM Bookings
GROUP BY CabID
ORDER BY TotalBookings DESC;

------------------------------------------------
-- 15. Get booking details along with customer and cab info
----------------------------------------------

SELECT b.BookingID, c.Name AS CustomerName, cb.CabNumber
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Cabs cb ON b.CabID = cb.CabID;







