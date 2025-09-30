# TransGlobalLogistics Assignment

This project builds a complete SQL Server database solution for **TransGlobalLogistics**, a logistics and shipping company. It covers database creation, data population, shipment management, and advanced database features such as stored procedures, triggers, and functions. The goal is to simulate a realistic logistics environment where data integrity, shipment tracking, and operational efficiency are managed via SQL Server.


## Phase 2: Database Implementation

### Tables Created

| Table        | Purpose                                                                 |
|--------------|------------------------------------------------------------------------ |
| `Customer`   | Stores customer details with unique emails and phone validation.        |
| `Warehouse`  | Stores warehouse information and tracks inventory levels.               |
| `Vehicle`    | Stores different vehicle types used for shipments.                      |
| `Driver`     | Stores driver details with license validation.                          |
| `Shipment`   | Tracks shipments, linking customers, warehouses, vehicles, and drivers. |

### Sample Data

- **Customers:** 10 profiles  
- **Vehicles:** 15 types  
- **Warehouses:** 5 locations  
- **Drivers:** 20 drivers  
- **Shipments:** 30 entries with varying statuses


### Sample Queries

Some examples included in the scripts:

| Query Purpose                                | Description                                                                |
|--------------------------------------------- |--------------------------------------------------------------------------- |
| Track active shipments                       | Retrieve shipments with status `In Transit` for a specific customer        |
| Available vehicles at warehouse              | Identify vehicles not currently assigned to shipments at a given warehouse |
| Daily shipment schedule                      | List all shipments departing on a specific date                            |
| Average delivery times                       | Calculate average delivery days between warehouses                         |
| Most efficient drivers                       | Identify drivers with the highest on-time delivery percentage              |


## Phase 3: Advanced Database Features

### Stored Procedures

| Procedure Name                  | Purpose                                                         |
|---------------------------------|-----------------------------------------------------------------|
| `sp_CreateNewShipment`          | Creates a new shipment with validation and transaction handling |
| `sp_AssignVehicleToShipment`    | Assigns vehicles to pending shipments                           |
| `sp_UpdateShipmentStatus`       | Updates shipment status and logs changes                        |

### Triggers

| Trigger Name                     | Purpose                                                     |
|--------------------------------- |-------------------------------------------------------------|
| `trg_UpdateVehicleAvailability`  | Updates vehicle status when assigned/released from shipment |
| `trg_AuditShipmentStatusChange`  | Audits all shipment status changes                          |
| `trg_UpdateWarehouseInventory`   | Adjusts warehouse inventory based on shipment status        |

### Functions

| Function Name                        | Purpose                                                                  |
|--------------------------------------|--------------------------------------------------------------------------|
| `fn_CalculateEstimatedDeliveryTime`  | Estimates delivery time based on distance and vehicle type               |
| `GetOptimalRoutes`                   | Returns optimal shipment routes between two warehouses                   |
| `fn_CalculateFuelConsumption`        | Calculates estimated fuel consumption based on distance and vehicle type |



## Requirements

- Microsoft SQL Server 2016 or newer  
- SQL Server Management Studio (SSMS) or equivalent SQL client  
- Basic understanding of SQL tables, queries, procedures, triggers, and functions  
- Optional: Folder for auditing logs if using triggers


## How to Run

Clone the repository:

```sql
git clone https://github.com/Michelle-Lichtenstein/TransGlobalLogistics.git
```

- Open TransGlobalLogistics_Script.sql in SQL Server Management Studio (SSMS).
- Run the script in order: Phase 2 → Phase 3.
- Verify tables are created and sample data is inserted correctly.
- Test stored procedures, triggers, and functions using the provided sample queries.
- Track shipments, check vehicle availability, and verify shipment audits and warehouse inventory updates.

## About the Project

This project simulates a complete logistics database environment in SQL Server. It demonstrates:

- Relational database design with proper constraints and relationships  
- Data integrity and validation through constraints and triggers  
- Automation using stored procedures for shipment management  
- Auditing and logging of shipment status changes  
- Calculations for delivery times, fuel consumption, and optimal routing

It is suitable for learning advanced SQL Server features in a real-world logistics context.

---

## Author

**Michelle Lichtenstein** – SQL Server Developer  
**Project:** TransGlobalLogistics Database Simulation
