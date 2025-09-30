--TASK 2.1
-- Create a new database for TransGlobalLogistics
CREATE DATABASE TransGlobalLogistics;
GO

-- Create a custom schema for the TransGlobalLogistics database
CREATE SCHEMA Logistics;
GO

-- Create the Customer table with the necessary fields and constraints
CREATE TABLE Logistics.Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(50) NOT NULL,
    CustomerAddress VARCHAR(50) NOT NULL,
    CustomerEmail VARCHAR(50) NOT NULL,
    CustomerPhone VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_CustomerPhone CHECK (CustomerPhone LIKE '%[0-9]%')
);
GO


-- Create the Warehouse table with its required fields
CREATE TABLE Logistics.Warehouse (
    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
    WarehouseName VARCHAR(50) NOT NULL,
    WarehouseAddress VARCHAR(50) NOT NULL,
	WarehouseInventory DECIMAL(10, 2) NOT NULL DEFAULT 0
);
GO


-- Create the Vehicle table with its required fields and constraints
CREATE TABLE Logistics.Vehicle (
    VehicleID INT IDENTITY(1,1) PRIMARY KEY,
    VehicleType VARCHAR(50) NOT NULL
);
GO


-- Create the Driver table with the necessary fields and constraints
CREATE TABLE Logistics.Driver (
    DriverID INT IDENTITY(1,1) PRIMARY KEY,
    DriverName VARCHAR(50) NOT NULL,
    DriverLicense VARCHAR(50) NOT NULL,
    CONSTRAINT CHK_DriverLicense CHECK (DriverLicense LIKE '[A-Za-z0-9%-]%' ) 
);
GO

-- Create the Shipment table with the relationships to the other tables
CREATE TABLE Logistics.Shipment (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OriginWarehouseID INT,
    DestinationWarehouseID INT,
    VehicleID INT,
    DriverID INT,
    CargoDescription VARCHAR(50) NOT NULL,
    CargoWeight DECIMAL(10, 2) NOT NULL,
    ShipmentStatus VARCHAR(50) NOT NULL DEFAULT 'In Transit',
    DepartureTime DATE NOT NULL, 
    EstimatedArrival DATE NOT NULL, 
    ActualArrival DATE, 
    FOREIGN KEY (CustomerID) REFERENCES Logistics.Customer(CustomerID),
    FOREIGN KEY (OriginWarehouseID) REFERENCES Logistics.Warehouse(WarehouseID),
    FOREIGN KEY (DestinationWarehouseID) REFERENCES Logistics.Warehouse(WarehouseID),
    FOREIGN KEY (VehicleID) REFERENCES Logistics.Vehicle(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Logistics.Driver(DriverID),
    CONSTRAINT CHK_CargoWeight CHECK (CargoWeight > 0)
);
GO





-- This ensures that the emails are unique for all of the customers
ALTER TABLE Logistics.Customer
ADD CONSTRAINT UQ_CustomerEmail UNIQUE (CustomerEmail);
GO


--TASK 2.2
-- Adds profiles for 10 customers into the Customer table
INSERT INTO Logistics.Customer (CustomerName, CustomerAddress, CustomerEmail, CustomerPhone) VALUES
('John Lucas', '123 Main Rd, Johannesburg, Gauteng', 'johnlucas@gmail.com', '078 468 7701'),
('Alicia Johnson', '456 Pine Ave, Cape Town, Western Cape', 'alicia.johnson@icloud.com', '076 413 9945'),
('David Strauss', '789 Oak Rd, Durban, KwaZulu-Natal', 'david.s@gmail.com', '082 763 0012'),
('Emily White', '101 Church St, Pretoria, Gauteng', 'emily.white@outlook.com', '072 971 0259'),
('Michael Douglas', '202 Beach Blvd, Port Elizabeth, Eastern Cape', 'michaeldouglas@gmail.com', '084 774 1249'),
('Laura White', '303 Nelson Mandela Dr, Bloemfontein, Free State', 'laurawhite012@gmail.com', '074 964 1287'),
('Chris Brown', '404 Victoria Rd, Polokwane, Limpopo', 'chrisbrown@icloud.com', '074 569 8810'),
('Patrick Star', '505 Voortrekker St, Nelspruit, Mpumalanga', 'patrickstar2002@outlook.com', '089 413 5560'),
('Robert Marais', '606 Voortrekker Rd, Kimberley, Northern Cape', 'robertmarais@outlook.com', '082 479 6651'),
('Enrique Martinez', '707 William Nicol Dr, Pretoria, Gauteng', 'enriquemartinez02@icloud.com', '074 889 1159');

SELECT * FROM Logistics.Customer;


-- Adds 15 different vehicle types into the Vehicle table 
INSERT INTO Logistics.Vehicle (VehicleType) VALUES
('Flatbed Truck'),
('Box Truck'),
('Refrigerated Truck'),
('Cargo Van'),
('Pickup Truck'),
('Tow Truck'),
('Dump Truck'),
('Container Truck'),
('Tank Truck'),
('Lorry'),
('Semi-trailer Truck'),
('Heavy Duty Truck'),
('Delivery Van'),
('Flatbed Trailer'),
('Box Trailer');

SELECT * FROM Logistics.Vehicle;


-- Adds 5 warehouse locations into the Warehouse table 
INSERT INTO Logistics.Warehouse (WarehouseName, WarehouseAddress) VALUES
('Johannesburg Warehouse', '123 Industrial Rd, Johannesburg, Gauteng'),
('Cape Town Warehouse', '456 Waterfront Rd, Cape Town, Western Cape'),
('Durban Distribution Center', '789 Umhlanga Blvd, Durban, KwaZulu-Natal'),
('Pretoria Logistics Hub', '101 Pretoria Main Rd, Pretoria, Gauteng'),
('Port Elizabeth Storage Facility', '202 Bay Rd, Port Elizabeth, Eastern Cape');

SELECT * FROM Logistics.Warehouse;


-- Adds 20 different drivers with different roles into the  Driver table
INSERT INTO Logistics.Driver (DriverName, DriverLicense) VALUES
('Linda Davis', 'AK10JPGP'),
('Johnny Lewis', 'WS89GHGP'),
('Lucas White', 'MK97LHGP'),
('Greg Lee', 'WE22SEEC'),
('Jack Black', 'QA85FHEC'),
('Tito Mario', 'AW45FGEC'),
('Dirk Lombard', 'AS12WEKZN'),
('William Thorn', 'XV79ZMKZN'),
('Liam Roberts', 'LK40WQKZN'),
('Misha Davids', 'AD39AKWP'),
('Nickolas Black', 'PN72GHWP'),
('Luca West', 'QT83HUWP'),
('Amelia Silver', 'AX44LKGP'),
('Rick Scott', 'QE41UIKZN'),
('Bennie Maxwell', 'RY06TYWP'),
('Sasha Petrova', 'DF74WAEC'),
('Elijah Michaelson', 'QZ46TGEC'),
('Elma Wait', 'AS41SAWP'),
('Sebastian Knight', 'SD10SWGP'),
('Wynhand Meyer', 'AQ89YOGP');

SELECT * FROM Logistics.Driver;



--Adds 30 shipments to the Shipment table 
INSERT INTO Logistics.Shipment (CustomerID, OriginWarehouseID, DestinationWarehouseID, VehicleID, DriverID, 
    CargoDescription, CargoWeight, ShipmentStatus, DepartureTime, EstimatedArrival, ActualArrival) 
	VALUES
(1, 1, 2, 1, 1, 'Electronics', 500.00, 'In Transit', '2025-01-12', '2025-01-16', NULL),
(2, 2, 3, 2, 2, 'Furniture', 1000.00, 'Delivered', '2025-02-02', '2025-02-04', '2025-02-03'),
(3, 3, 4, 3, 3, 'Clothing', 150.00, 'In Transit', '2025-03-03', '2025-03-05', NULL),
(4, 4, 5, 4, 4, 'Automotive', 650.00, 'In Transit', '2025-01-24', '2025-02-06', NULL),
(5, 5, 1, 5, 5, 'Automobiles', 2000.00, 'Delivered', '2025-02-05', '2025-02-17', '2025-02-19'),
(6, 1, 3, 6, 6, 'Books', 50.00, 'In Transit', '2025-02-06', '2025-02-08', NULL),
(7, 2, 4, 7, 7, 'Chemicals', 750.00, 'Pending', '2025-01-07', '2025-01-09', NULL),
(8, 3, 5, 8, 8, 'Furniture', 1200.00, 'In Transit', '2025-02-08', '2025-02-10', NULL),
(9, 4, 1, 9, 9, 'Clothing', 300.00, 'Delivered', '2025-03-09', '2025-03-11', '2025-03-11'),
(10, 5, 2, 10, 10, 'Electronics', 450.00, 'Delivered', '2025-03-10', '2025-03-12', '2025-03-14'),
(1, 1, 2, 11, 11, 'Books', 75.00, 'Pending', '2025-02-11', '2025-02-13', NULL),
(2, 2, 3, 12, 12, 'Automobiles', 3000.00, 'In Transit', '2025-01-12', '2025-01-14', NULL),
(3, 3, 4, 13, 13, 'Electronics', 500.00, 'Delivered', '2025-02-13', '2025-02-15', '2025-02-14'),
(4, 4, 5, 14, 14, 'Furniture', 1000.00, 'In Transit', '2025-03-14', '2025-03-16', NULL),
(5, 5, 1, 15, 15, 'Chemicals', 1200.00, 'In Transit', '2025-03-15', '2025-03-17', NULL),
(6, 1, 2, 1, 16, 'Automotive', 350.00, 'Pending', '2025-01-16', '2025-01-18', NULL),
(7, 2, 3, 2, 17, 'Books', 100.00, 'Delivered', '2025-02-17', '2025-02-19', '2025-02-20'),
(8, 3, 4, 3, 18, 'Clothing', 800.00, 'In Transit', '2025-03-18', '2025-03-20', NULL),
(9, 4, 5, 4, 19, 'Furniture', 2000.00, 'In Transit', '2025-01-19', '2025-01-21', NULL),
(10, 5, 1, 5, 20, 'Automobiles', 2500.00, 'Delivered', '2025-02-20', '2025-02-22', '2025-02-23'),
(1, 1, 3, 6, 1, 'Electronics', 500.00, 'Pending', '2025-03-21', '2025-03-23', NULL),
(2, 2, 4, 7, 2, 'Furniture', 1000.00, 'In Transit', '2025-02-22', '2025-02-24', NULL),
(3, 3, 5, 8, 3, 'Clothing', 300.00, 'In Transit', '2025-03-23', '2025-03-25', NULL),
(4, 4, 1, 9, 4, 'Automotive', 400.00, 'Delivered', '2025-01-24', '2025-01-26', '2025-01-25'),
(5, 5, 2, 10, 5, 'Automobiles', 3000.00, 'Delivered', '2025-03-25', '2025-03-27', '2025-03-29'),
(6, 1, 2, 11, 6, 'Books', 150.00, 'In Transit', '2025-02-24', '2025-02-26', NULL),
(7, 2, 3, 12, 7, 'Chemicals', 950.00, 'Delivered', '2025-03-04', '2025-03-06', '2025-03-06'),
(8, 3, 4, 13, 8, 'Automotive', 650.00, 'In Transit', '2025-03-05', '2025-03-07', NULL),
(9, 4, 5, 14, 9, 'Furniture', 1200.00, 'Pending', '2025-03-06', '2025-03-08', NULL),
(10, 5, 1, 15, 10, 'Automobiles', 1800.00, 'Delivered', '2025-03-07', '2025-03-09', '2025-03-09');

GO

SELECT * FROM Logistics.Shipment;



--TASK 2.3
--Query to track all active shipments for a specific customer
DECLARE @CustomerID INT;
SET @CustomerID = 6; 

SELECT ShipmentID, CustomerID, OriginWarehouseID, DestinationWarehouseID, VehicleID, DriverID, 
       CargoDescription, CargoWeight, ShipmentStatus, DepartureTime, EstimatedArrival, ActualArrival
FROM Logistics.Shipment
WHERE CustomerID = @CustomerID AND ShipmentStatus = 'In Transit';



-- Query to identify available vehicles at a particular warehouse
DECLARE @WarehouseID INT;
SET @WarehouseID = 4; 

SELECT v.VehicleID, v.VehicleType
FROM Logistics.Vehicle v
LEFT JOIN Logistics.Shipment s
  ON v.VehicleID = s.VehicleID 
 AND (s.OriginWarehouseID = @WarehouseID OR s.DestinationWarehouseID = @WarehouseID)
WHERE s.VehicleID IS NULL;




-- Query to generate a daily shipment schedule
DECLARE @ScheduledDate DATE;
SET @ScheduledDate = '2025-03-14'; 

SELECT ShipmentID, CustomerID, OriginWarehouseID, DestinationWarehouseID, VehicleID, DriverID, 
       CargoDescription, CargoWeight, ShipmentStatus, DepartureTime, EstimatedArrival
FROM Logistics.Shipment
WHERE DepartureTime >= @ScheduledDate AND DepartureTime < DATEADD(DAY, 1, @ScheduledDate);




-- Query to calculate average delivery times between specific locations
DECLARE @OriginWarehouseID INT, @DestinationWarehouseID INT;
SET @OriginWarehouseID = 5;
SET @DestinationWarehouseID = 1; 

SELECT AVG(DATEDIFF(DAY, DepartureTime, ActualArrival)) AS AverageDeliveryTime
FROM Logistics.Shipment
WHERE OriginWarehouseID = @OriginWarehouseID 
  AND DestinationWarehouseID = @DestinationWarehouseID
  AND ShipmentStatus = 'Delivered';




-- Query to identify the most efficient drivers based on on-time delivery percentage
WITH DriverPerformance AS (
    SELECT 
        D.DriverID,D.DriverName,
        COUNT(S.ShipmentID) AS TotalShipments,
        SUM(CASE WHEN S.ActualArrival IS NOT NULL AND S.ActualArrival <= S.EstimatedArrival THEN 1 ELSE 0 END) AS OnTimeShipments
    FROM 
        Logistics.Driver D
    LEFT JOIN 
        Logistics.Shipment S ON S.DriverID = D.DriverID
    GROUP BY 
        D.DriverID, D.DriverName
)
SELECT 
    DriverID, DriverName, TotalShipments, OnTimeShipments,
    (OnTimeShipments * 100 / NULLIF(TotalShipments, 0)) AS OnTimePercentage
FROM 
    DriverPerformance
WHERE 
    OnTimeShipments > 0  
ORDER BY 
    OnTimePercentage DESC;




