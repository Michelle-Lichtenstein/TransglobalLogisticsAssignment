--TASK 3.1
USE TransGlobalLogistics;
GO

-- This creates the table for the shipment logs
CREATE TABLE Logistics.ShipmentStatusLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,   
    ShipmentID INT NOT NULL,                
    StatusChangedTo VARCHAR(50) NOT NULL,   
    ChangeDate DATETIME NOT NULL            
);
GO



-- Stored Procedure = sp_CreateNewShipment - Creates a new shipment record with comprehensive validation
CREATE PROCEDURE sp_CreateNewShipment
    @CustomerID INT,
    @OriginWarehouseID INT,
    @DestinationWarehouseID INT,
    @VehicleID INT,
    @DriverID INT,
    @CargoDescription VARCHAR(50),
    @CargoWeight DECIMAL(10, 2),
    @DepartureTime DATE,
    @EstimatedArrival DATE
AS
BEGIN

    -- Begin transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- This validates the Cargo Weight which must be greater than 0
        IF @CargoWeight <= 0
        BEGIN
            RAISERROR('The Cargo Weight must be greater than 0', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Checks if the vehicle is already assigned to another shipment
        IF EXISTS (SELECT 1 FROM Logistics.Shipment WHERE VehicleID = @VehicleID AND ShipmentStatus = 'In Transit')
        BEGIN
            RAISERROR('The vehicle is already assigned to another active shipment', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        -- This inserts the shipment record
        INSERT INTO Logistics.Shipment
        (
            CustomerID, OriginWarehouseID, DestinationWarehouseID,
            VehicleID, DriverID, CargoDescription, CargoWeight,
            ShipmentStatus, DepartureTime, EstimatedArrival
        )
        VALUES
        (
            @CustomerID, @OriginWarehouseID, @DestinationWarehouseID,
            @VehicleID, @DriverID, @CargoDescription, @CargoWeight,
            'In Transit', @DepartureTime, @EstimatedArrival
        );

        -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        -- Rollback transaction in case of an error
        ROLLBACK TRANSACTION;

        -- This throws an error message if there is errors
        THROW;

    END CATCH
END;
GO


--Store Procedure =  sp_AssignVehicleToShipment - Assigns available vehicles to pending shipments
CREATE PROCEDURE sp_AssignVehicleToShipment
    @ShipmentID INT,
    @VehicleID INT
AS
BEGIN
    -- Begin transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- This checks if the shipment exists as well as if it is in a pending state
        IF NOT EXISTS (SELECT 1 FROM Logistics.Shipment WHERE ShipmentID = @ShipmentID AND ShipmentStatus = 'Pending')
        BEGIN
            RAISERROR('The Shipment was not found or its already been processed', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- This checks if the vehicle is already assigned to another active shipment
        IF EXISTS (SELECT 1 FROM Logistics.Shipment WHERE VehicleID = @VehicleID AND ShipmentStatus = 'In Transit')
        BEGIN
            RAISERROR('The vehicle is already assigned to another active shipment', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update the shipment with the vehicle assignment
        UPDATE Logistics.Shipment
        SET VehicleID = @VehicleID, ShipmentStatus = 'In Transit'
        WHERE ShipmentID = @ShipmentID;
        
		 -- Commit the transaction if everything is successful
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        
		-- Rollback transaction in case of an error
        ROLLBACK TRANSACTION;
        
		-- This throws an error message if there is errors
        THROW;
    END CATCH
END;
GO



-- Stored Procedure = sp_UpdateShipmentStatus - Updates shipment status with appropriate logging
CREATE PROCEDURE sp_UpdateShipmentStatus
    @ShipmentID INT,
    @NewStatus VARCHAR(50),
    @ActualArrival DATE = NULL
AS
BEGIN
    -- Begin transaction
    BEGIN TRANSACTION;

    BEGIN TRY
        -- This checks if the shipment exists
        IF NOT EXISTS (SELECT 1 FROM Logistics.Shipment WHERE ShipmentID = @ShipmentID)
        BEGIN
            RAISERROR('The Shipment was not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- This updates the shipments status and actual arrival date if it was provided
        UPDATE Logistics.Shipment
        SET ShipmentStatus = @NewStatus, ActualArrival = @ActualArrival
        WHERE ShipmentID = @ShipmentID;

        -- This inserts a log record into the shipment log table
        INSERT INTO Logistics.ShipmentStatusLog (ShipmentID, StatusChangedTo, ChangeDate)
        VALUES (@ShipmentID, @NewStatus, GETDATE());
     
		-- Commit the transaction if everything is successful
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        
		-- Rollback transaction in case of an error
        ROLLBACK TRANSACTION;
      
	  -- This throws an error message if there is errors
        THROW;
    END CATCH
END;
GO


--TASK 3.2
-- Trigger to update vehicle availability status when assigned to or released from shipments
CREATE TRIGGER Logistics.trg_UpdateVehicleAvailability
ON Logistics.Shipment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- This sets the vehicles to 'In Use' when assigned to a shipment
        UPDATE Logistics.Vehicle
        SET VehicleType = 'In Use'
        WHERE VehicleID IN (SELECT VehicleID FROM inserted);

        -- This sets the vehicles back to 'Available' when shipment is marked as 'Delivered'
        UPDATE Logistics.Vehicle
        SET VehicleType = 'Available'
        WHERE VehicleID IN (SELECT VehicleID FROM inserted)
              AND EXISTS (
                  SELECT 1 FROM inserted 
                  WHERE inserted.VehicleID = Logistics.Vehicle.VehicleID
                  AND inserted.ShipmentStatus = 'Delivered'
              );
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;


--The tables that are needed for the AuditShipmentStatusChange and ShipmentStatusAuditLog.
CREATE TABLE Logistics.ShipmentStatusAuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentID INT,
    OldStatus VARCHAR(50),
    NewStatus VARCHAR(50),
    ChangeDate DATETIME
);
GO

CREATE TABLE Logistics.Audit_ShipmentStatusChange (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentID INT NOT NULL,
    OldStatus VARCHAR(50) NOT NULL,
    NewStatus VARCHAR(50) NOT NULL,
    ChangeTime DATETIME NOT NULL,
    FOREIGN KEY (ShipmentID) REFERENCES Logistics.Shipment(ShipmentID)
);
GO


-- Trigger to audit shipment status changes in the Shipment table
CREATE TRIGGER trg_AuditShipmentStatusChange
ON Logistics.Shipment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ShipmentID INT, @OldStatus VARCHAR(50), @NewStatus VARCHAR(50), @ChangeTime DATETIME;

    -- This retrieves the shipment details from the inserted and deleted records
    SELECT @ShipmentID = ShipmentID, @OldStatus = ShipmentStatus
    FROM DELETED;
    SELECT @NewStatus = ShipmentStatus
    FROM INSERTED;

    -- This checks if the status has actually changed
    IF @OldStatus <> @NewStatus
    BEGIN
        SET @ChangeTime = GETDATE();       
        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Logistics.Audit_ShipmentStatusChange (ShipmentID, OldStatus, NewStatus, ChangeTime)
            VALUES (@ShipmentID, @OldStatus, @NewStatus, @ChangeTime);

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT ERROR_MESSAGE();
        END CATCH;
    END
END;
GO



-- Trigger to update warehouse inventory levels based on shipment status changes
CREATE TRIGGER trg_UpdateWarehouseInventory
ON Logistics.Shipment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WarehouseID INT, @CargoWeight DECIMAL(10, 2), @ShipmentStatus VARCHAR(50);

    -- This retrieves the warehouse and the shipment details from the inserted/updated record
    SELECT @WarehouseID = OriginWarehouseID, @CargoWeight = CargoWeight, @ShipmentStatus = ShipmentStatus
    FROM INSERTED;

    -- Begin transaction
    BEGIN TRY
        BEGIN TRANSACTION;

        -- This decrements the inventory when shipment is in transit
        IF @ShipmentStatus = 'In Transit'
        BEGIN
            UPDATE Logistics.Warehouse
            SET WarehouseInventory = WarehouseInventory - @CargoWeight
            WHERE WarehouseID = @WarehouseID;
        END
        -- This increments the inventory when shipment is delivered or canceled
        ELSE IF @ShipmentStatus IN ('Delivered', 'Canceled')
        BEGIN
            UPDATE Logistics.Warehouse
            SET WarehouseInventory = WarehouseInventory + @CargoWeight
            WHERE WarehouseID = @WarehouseID;
        END

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        -- This handles the error as well as the rollback
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO



-- TASK 3.3
-- 1. Function to calculate the estimated delivery time based on distance and vehicle type
DROP FUNCTION IF EXISTS Logistics.fn_CalculateEstimatedDeliveryTime;
GO
CREATE FUNCTION Logistics.fn_CalculateEstimatedDeliveryTime 
(
    @DistanceKm DECIMAL(10,2),  -- Distance to be traveled in kilometers
    @VehicleType VARCHAR(50)     -- Type of vehicle used for the transportation
)
RETURNS INT
AS
BEGIN
    -- This declares the vehicle's average speed in km per hour
    DECLARE @AvgSpeed INT;  

    -- This assigns the average speed based on the vehicle type
    SET @AvgSpeed = 
        CASE 
            WHEN @VehicleType = 'Flatbed' THEN 65      
            WHEN @VehicleType = 'Tow Truck' THEN 80    
            WHEN @VehicleType = 'Delivery Van' THEN 75  
            ELSE 70  -- Default speed for unknown vehicle types
        END;

    -- This line calculates the estimated delivery time in hours 
    RETURN CEILING(@DistanceKm / NULLIF(@AvgSpeed, 0));
END;
GO



-- This section tests the function by calculating the estimated delivery time for the different vehicles types.
SELECT Logistics.fn_CalculateEstimatedDeliveryTime(500, 'Flatbed') AS EstimatedDeliveryTimeFlatbed;
SELECT Logistics.fn_CalculateEstimatedDeliveryTime(500, 'Tow Truck') AS EstimatedDeliveryTimeTowTruck;
SELECT Logistics.fn_CalculateEstimatedDeliveryTime(500, 'Delivery Van') AS EstimatedDeliveryTimeVan;
SELECT Logistics.fn_CalculateEstimatedDeliveryTime(500, 'Unknown Vehicle') AS EstimatedDeliveryTimeDefault;
GO




-- 2. Table-valued function to retrieve optimal route options between two warehouses
CREATE FUNCTION Logistics.GetOptimalRoutes
(
    @OriginWarehouseID INT,         
    @DestinationWarehouseID INT     
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        S.ShipmentID, S.OriginWarehouseID,                              
        W1.WarehouseName AS OriginWarehouseName,          
        S.DestinationWarehouseID,                         
        W2.WarehouseName AS DestinationWarehouseName,     
        S.VehicleID, V.VehicleType,S.DriverID,  
        D.DriverName, S.DepartureTime, 
        S.EstimatedArrival, S.ActualArrival, 
        CASE 

		-- If actual arrival time is available
            WHEN S.ActualArrival IS NOT NULL THEN  
			
		-- This calculates transit time based on the actual arrival date
                DATEDIFF(DAY, S.DepartureTime, S.ActualArrival)  
            ELSE
                DATEDIFF(DAY, S.DepartureTime, S.EstimatedArrival) 

		-- This is the calculated transit time in days
        END AS TransitTime                               
    FROM 
        Logistics.Shipment S                             
    INNER JOIN 
        Logistics.Warehouse W1 ON S.OriginWarehouseID = W1.WarehouseID  
    INNER JOIN 
        Logistics.Warehouse W2 ON S.DestinationWarehouseID = W2.WarehouseID 
    INNER JOIN 
        Logistics.Vehicle V ON S.VehicleID = V.VehicleID  
    INNER JOIN 
        Logistics.Driver D ON S.DriverID = D.DriverID   
    WHERE 

		-- Filter the data for the given origin as well as destination warehouse ID
        S.OriginWarehouseID = @OriginWarehouseID         
        AND S.DestinationWarehouseID = @DestinationWarehouseID 
);
GO

-- Test for WarehouseID 2 to WarehouseID 3
SELECT * 
FROM Logistics.GetOptimalRoutes(2, 3)
ORDER BY TransitTime ASC;

GO




-- 3. Function to calculate fuel consumption estimates based on distance and vehicle type
CREATE FUNCTION Logistics.fn_CalculateFuelConsumption 
(
    @DistanceKm DECIMAL(10,2),  -- This line displays the distance that is going to be traveled in kilometers
    @VehicleType VARCHAR(50)     -- This line displays the type of vehicle that is going to be used for transportation
)
RETURNS DECIMAL(10,2)  --This returns the estimated fuel consumption in liters
AS
BEGIN
    DECLARE @FuelEfficiency DECIMAL(10,2); 

    -- This section assigns fuel efficiency based on vehicle type
    SET @FuelEfficiency = 
        CASE 
            WHEN @VehicleType = 'Flatbed' THEN 4.5       
            WHEN @VehicleType = 'Tow Truck' THEN 7.0     
            WHEN @VehicleType = 'Delivery Van' THEN 20.0 
            ELSE 5.0  -- This is the default efficiency for the unknown vehicle types
        END;

    -- This line calculates the fuel consumption in liters
    RETURN (@DistanceKm / NULLIF(@FuelEfficiency, 0));
END;
GO


--This section tests the function by calculating the fuel consumpion for the different vehicle types.
SELECT Logistics.fn_CalculateFuelConsumption(100, 'Flatbed') AS FuelConsumption;

SELECT Logistics.fn_CalculateFuelConsumption(100, 'Tow Truck') AS FuelConsumption;

SELECT Logistics.fn_CalculateFuelConsumption(100, 'Delivery Van') AS FuelConsumption;
     
SELECT Logistics.fn_CalculateFuelConsumption(100, 'Unknown Vehicle') AS FuelConsumption;





