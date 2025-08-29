# SQL Project Execution Guide

This project contains SQL scripts for database initialization, optimization, CRUD operations, triggers, procedures, and data analysis.  
Please follow the sequence below to run the files correctly:

---
## 1. Initialization
Run the following script to import datasets and create initial tables:
- `init.sql`
This step sets up the database schema and loads the necessary data.
---
## 2. Indexes
Run:
- `indexes.sql`
This script creates indexes to optimize query performance.
This script performs **Task 2** and **Task 3** together with initialization.
---
## 3. CRUD Operations
Navigate to the **CRUD** subfolder and run the files inside.  
These scripts perform **Task 4** and **Task 5** (basic Create, Read, Update, Delete operations).
---
## 4. Triggers
Run:
- `flightTrigger.sql`
This script implements triggers in PL/SQL. The following triggers are included:
- **Before Insert Trigger** – validates inserted data.  
- **After Insert Trigger** – performs an action after insertion.  
- **Before Update Trigger** – validates updated data.  
- **After Update Trigger** – performs an action after update.  
- **Before Delete Trigger** – validates data before deletion.  
- **After Delete Trigger** – performs an action after deletion.  
This scripts performs **Task 6**.
---
## 5. Procedures
Run:
- `procedure.sql`
This script defines and runs stored procedures for specific operations.
---
## 6. Data Analysis
Finally, navigate to the **Data Analysis** subfolder and run the query files provided.  
These scripts are used for advanced query analysis and reporting.
These scripts perform **Task 7**.

---

## Execution Order Summary
1. `init.sql`  
2. `indexes.sql`  
3. Files inside `CRUD/`  
4. `flightTrigger.sql`  
5. `procedure.sql`  
6. Files inside `Data Analysis/`
