# Electric Vehicle Population Database Project

## Overview

This project is a database design and analysis project built around the **Electric Vehicle Population Data** dataset from Washington State. The dataset contains electric vehicle registration information such as vehicle make, model, model year, EV type, CAFV eligibility, electric range, location, electric utility provider, and census information.

The main goal of this project is to transform one large raw vehicle dataset into a cleaner relational database design. The project normalizes repeated values into lookup tables, adds primary and foreign key constraints, handles many-to-many utility relationships, and runs analytical SQL queries to understand electric vehicle adoption patterns.

## Dataset

The dataset used in this project is:

[Electric Vehicle Population Data - Washington State Open Data](https://data.wa.gov/Transportation/Electric-Vehicle-Population-Data/f6w7-q2d2/about_data)


The dataset includes fields such as:

- VIN prefix
- County
- City
- State
- Postal Code
- Model Year
- Make
- Model
- Electric Vehicle Type
- Clean Alternative Fuel Vehicle eligibility
- Electric Range
- Legislative District
- DOL Vehicle ID
- Vehicle Location
- Electric Utility
- 2020 Census Tract

## Project Purpose

This project studies electric vehicle registrations and asks larger data questions, such as:

1. Is EV ownership widespread, or concentrated in specific counties?
2. Are plug-in hybrid vehicles truly effective in terms of electric range?
3. Which electric utility providers serve the highest number of EVs?
4. Is the clean vehicle incentive program keeping up with the EV market?
5. Where does the dataset have missing or incomplete information?

## Technologies Used

- **Oracle SQL / PL/SQL**
- **Oracle SQL Developer**
- **CSV data import**
- **Relational database design**
- **SQL views**
- **SQL analytical queries**
- **EXPLAIN PLAN** for query performance analysis

## Project Files

| File | Purpose |
|---|---|
| `Vehicle_bigTable.sql` | Initial generated SQL file for the large raw `VEHICLE` table. It contains the `CREATE TABLE VEHICLE` statement and many `INSERT INTO VEHICLE` rows created from the CSV import/export. Run this after creating the schema if you are loading data using SQL insert statements instead of manual CSV import. |
| `physical.sql` | Creates the database user, grants privileges, and sets the schema. |
| `transformation.sql` | Creates lookup tables, inserts distinct values, and builds the many-to-many utility bridge table. |
| `constarint.sql` | Adds foreign key columns, fills them from lookup tables, creates foreign key constraints, and removes repeated text columns. |
| `Result.sql` | Contains the final analytical SQL queries used to answer the project questions. |


## Database Design

The project starts with one large raw table called `VEHICLE`. After transformation, repeated values are separated into lookup tables to reduce redundancy and improve data organization.

### Main Table

#### `VEHICLE`

Stores the main vehicle registration records. The project begins with this large raw table before normalization. If using the generated file shown in the project folder, `Vehicle_bigTable.sql` creates this table and inserts the original vehicle records.

The raw table includes columns such as:

- `VIN_1_10`
- `COUNTY`
- `CITY`
- `STATE`
- `POSTAL_CODE`
- `MODEL_YEAR`
- `MAKE`
- `MODEL`
- `EV_TYPE`
- `CAFV_TYPE`
- `ELECTRIC_RANGE`
- `LEGISLATIVE_DISTRICT`
- `DOL_VEHICLE_ID`
- `VEHICLE_LOCATION`
- `ELECTRIC_UTILITY`
- `CENSUS_TRACT_2020`

After transformation, the table keeps the core vehicle data and references the lookup tables using foreign keys.

Important final fields include:

- `dol_vehicle_id` as the primary key
- `model_year`
- `electric_range`
- `postal_code`
- `vehicle_location`
- `legislative_district`
- `census_tract_2020`
- foreign keys to model, EV type, CAFV status, and location tables

### Lookup Tables

#### `VEHICLE_MODEL`

Stores each unique make and model combination.

Fields:

- `id`
- `make`
- `model`

#### `VEHICLE_TYPE`

Stores electric vehicle type values.

Examples:

- Battery Electric Vehicle (BEV)
- Plug-in Hybrid Electric Vehicle (PHEV)

Fields:

- `ev_id`
- `electric_vehicle_type`

#### `STATUS`

Stores Clean Alternative Fuel Vehicle eligibility values.

Fields:

- `cafv_id`
- `cafv_eligibility`

#### `LOCATION`

Stores location information.

Fields:

- `loc_id`
- `city`
- `county`
- `state`

#### `ELECTRIC_UTILITY`

Stores unique electric utility provider names.

Fields:

- `ut_id`
- `electric_utility_name`

#### `SERVED_BY`

Bridge table that connects vehicles to electric utilities.

This table is needed because one vehicle record may list multiple utilities, and one utility can serve many vehicles.

Fields:

- `ut_id`
- `dol_vehicle_id`

## Relationship Summary

- One vehicle belongs to one vehicle model.
- One vehicle has one EV type.
- One vehicle has one CAFV eligibility status.
- One vehicle is linked to one location.
- One vehicle can be served by multiple electric utilities.
- One electric utility can serve many vehicles.

## Setup Instructions

### 1. Open Oracle SQL Developer

Connect to your Oracle database.

### 2. Run the physical setup script

Run:

```sql
@physical.sql
```

This script creates the user and grants the required privileges.

### 3. Load the main `VEHICLE` table

You can load the raw dataset in one of two ways.

#### Option A: Run the generated big table script

If you have the generated SQL file named `Vehicle_bigTable.sql`, run it after `physical.sql`:

```sql
@Vehicle_bigTable.sql
```

This file creates the raw `VEHICLE` table and inserts the vehicle records using `INSERT INTO VEHICLE` statements.

#### Option B: Import the CSV manually

You can also import the dataset CSV into a table named:

```text
VEHICLE
```

The imported columns should match the project naming style used in the SQL scripts. Based on the generated `Vehicle_bigTable.sql`, the expected column names are:

| CSV Column | Database Column |
|---|---|
| VIN (1-10) | `VIN_1_10` |
| County | `COUNTY` |
| City | `CITY` |
| State | `STATE` |
| Postal Code | `POSTAL_CODE` |
| Model Year | `MODEL_YEAR` |
| Make | `MAKE` |
| Model | `MODEL` |
| Electric Vehicle Type | `EV_TYPE` |
| Clean Alternative Fuel Vehicle (CAFV) Eligibility | `CAFV_TYPE` |
| Electric Range | `ELECTRIC_RANGE` |
| Legislative District | `LEGISLATIVE_DISTRICT` |
| DOL Vehicle ID | `DOL_VEHICLE_ID` |
| Vehicle Location | `VEHICLE_LOCATION` |
| Electric Utility | `ELECTRIC_UTILITY` |
| 2020 Census Tract | `CENSUS_TRACT_2020` |

### 4. Run the transformation script

Run:

```sql
@transformation.sql
```

This script:

- Adds a primary key to `VEHICLE`
- Creates lookup tables
- Inserts distinct values into lookup tables
- Splits electric utility names when multiple utilities are stored in one field
- Fills the `SERVED_BY` bridge table

### 5. Run the constraint script

Run:

```sql
@constarint.sql
```

This script:

- Adds foreign key ID columns to `VEHICLE`
- Updates those IDs using lookup table matches
- Adds foreign key constraints
- Drops repeated text columns after normalization

### 6. Run the result queries

Run:

```sql
@Result.sql
```

This script contains the final analytical queries.


## Analytical Queries

The final report includes five main analytical queries.

### 1. EV Ownership by County

Counts EVs by county to identify where EV adoption is highest.

### 2. EV Type and Electric Range

Compares EV types by average, minimum, and maximum electric range.

### 3. Utility Provider Demand

Finds the top electric utilities serving the largest number of EVs.

### 4. CAFV Eligibility Distribution

Calculates how many vehicles fall into each CAFV eligibility category and their percentage of the dataset.

### 5. Missing Data Check

Counts missing values in important columns such as:

- Location ID
- EV type
- CAFV status
- Vehicle location
- Legislative district
- Census tract

## Data Transformation Highlights

One important part of this project is handling the `electric_utility` field. Some records contain more than one utility provider in the same field, separated by symbols such as `|` or `||`.

The project handles this by:

1. Replacing `||` with `|`
2. Splitting the utility string into separate names
3. Inserting each unique utility into `ELECTRIC_UTILITY`
4. Linking each vehicle to the correct utility through `SERVED_BY`

This creates a cleaner many-to-many relationship instead of keeping repeated text inside the main vehicle table.

## Constraints Used

The project applies several relational database constraints:

- Primary key on `VEHICLE(dol_vehicle_id)`
- Primary keys on all lookup tables
- Unique constraint on make/model combinations
- Unique constraint on EV type values
- Unique constraint on CAFV status values
- Unique constraint on location combinations
- Unique constraint on electric utility names
- Foreign keys from `VEHICLE` to lookup tables
- Foreign keys from `SERVED_BY` to `VEHICLE` and `ELECTRIC_UTILITY`


## Limitations

- The raw `VEHICLE` table must exist before running the transformation scripts. This can be done either by importing the CSV manually or by running `Vehicle_bigTable.sql`.
- Some field names must match the SQL scripts exactly.
- Some records may contain missing location, district, census, or eligibility data.
- The project currently focuses on SQL analysis, not a full application interface.
- The schema name should be checked before running all scripts.

## Future Improvements

Possible future improvements include:

- Add indexes on frequently searched columns such as `model_year`, `loc_id`, `ev_id`, and `cafv_id`.
- Build a dashboard to visualize EV adoption by county and utility provider.
- Add stored procedures for repeated analysis tasks.
- Add triggers to validate data before insert or update.
- Automate CSV loading instead of importing manually.
- Add more advanced analytics, such as EV growth by year and CAFV eligibility trends over time.

