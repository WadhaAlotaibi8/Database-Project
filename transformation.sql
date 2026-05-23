-- Team 5 [Wadha / Fatma]
-- Data Transformation

ALTER SESSION SET CURRENT_SCHEMA = ELECTRIC_VEHICLE1;

-- Add primary key to VEHICLE
ALTER TABLE VEHICLE
    ADD CONSTRAINT vehicle_PK PRIMARY KEY (dol_vehicle_id);
    
--S4
-- create the lookup tables 
-- 1)Vehicle_Model lookup table
CREATE TABLE VEHICLE_MODEL (
    "id" NUMBER GENERATED ALWAYS AS IDENTITY,
    make VARCHAR2(26) NOT NULL,
    "model" VARCHAR2(30) NOT NULL,
    
    CONSTRAINT vehicle_model_PK PRIMARY KEY ("id"),
    CONSTRAINT vehicle_model_UQ UNIQUE (make, "model")
);


-- 2)Vehical_Type lookup table
CREATE TABLE VEHICLE_TYPE (
    ev_id               NUMBER GENERATED ALWAYS AS IDENTITY,
    electric_vehicle_type VARCHAR2(40) NOT NULL,
    
    CONSTRAINT vehical_type_PK PRIMARY KEY (ev_id),
    CONSTRAINT vehical_type_UQ UNIQUE (electric_vehicle_type)
);

-- 3) Status lookup table
CREATE TABLE STATUS (
    cafv_id             NUMBER GENERATED ALWAYS AS IDENTITY,
    cafv_eligibility    VARCHAR2(65) NOT NULL,
    CONSTRAINT status_PK PRIMARY KEY (cafv_id),
    CONSTRAINT status_UQ UNIQUE (cafv_eligibility)
);

-- 4) Location lookup table
CREATE TABLE LOCATION (
    loc_id NUMBER GENERATED ALWAYS AS IDENTITY,
    city VARCHAR2(30) NOT NULL,
    county VARCHAR2(26),
    state CHAR(2) NOT NULL,
    
    CONSTRAINT location_PK PRIMARY KEY (loc_id),
    CONSTRAINT location_UK UNIQUE (city, county, state)
);


-- 5) Electric_Utility lookup table
CREATE TABLE ELECTRIC_UTILITY (
    ut_id NUMBER GENERATED ALWAYS AS IDENTITY,
    electric_utility_name VARCHAR2(128) NOT NULL,
    
    CONSTRAINT electric_utility_PK PRIMARY KEY (ut_id),
    CONSTRAINT electric_utility_UK UNIQUE (electric_utility_name)
);

-- 6) Served_by table
-- bridge table for M:N relation between vehicle and electric utility
CREATE TABLE SERVED_BY (
    ut_id NUMBER NOT NULL,
    dol_vehicle_id NUMBER NOT NULL,
    
    CONSTRAINT served_by_PK PRIMARY KEY (ut_id, dol_vehicle_id),
    CONSTRAINT served_by_utility_FK
        FOREIGN KEY (ut_id) REFERENCES ELECTRIC_UTILITY(ut_id),
    CONSTRAINT served_by_vehicle_FK
        FOREIGN KEY (dol_vehicle_id) REFERENCES VEHICLE(dol_vehicle_id)
);

--S5 
-- Fill the lookup tables using values from the original VEHICLE table

-- insert into Vehicle_model
INSERT INTO VEHICLE_MODEL 
    (make, "model")
SELECT DISTINCT make, model
    FROM VEHICLE;

-- insert into Vehicle_type
INSERT INTO VEHICLE_TYPE
    (electric_vehicle_type)
SELECT DISTINCT ev_type 
    FROM VEHICLE
        WHERE ev_type IS NOT NULL;

-- insert into status
INSERT INTO STATUS 
    (cafv_eligibility)
SELECT DISTINCT cafv_type 
    FROM VEHICLE
        WHERE cafv_type IS NOT NULL;

-- insert into location        
INSERT INTO LOCATION
    (city, county, state)
SELECT DISTINCT city, county, state
FROM VEHICLE
    WHERE city IS NOT NULL
      AND state IS NOT NULL; 

-- insert into electric_utility
/* 
    In the VEHICLE table (the big table), some rows have multiple 
    utilities combination in the same field. 
    so, we split those names so each utility is 
    on its own. Then, we give each one a unique ID and insert it 
    into the ELECTRIC_UTILITY lookup table.
*/
SET SERVEROUTPUT ON;
DECLARE
    v_utility      VARCHAR2(128); 
    v_utility_name VARCHAR2(60); 
    v_pos          NUMBER;
    v_exists       NUMBER;
    v_counter      NUMBER := 0;
    v_rows_scanned NUMBER := 0;
BEGIN

    FOR rec IN (
        SELECT DISTINCT electric_utility 
        FROM VEHICLE 
        WHERE electric_utility IS NOT NULL
    ) LOOP
        
        v_rows_scanned := v_rows_scanned + 1;
        
        -- change || to |
        v_utility := REPLACE(rec.electric_utility, '||', '|');
        
        -- Add a pipe so the last name is always found
        IF SUBSTR(v_utility, -1) != '|' THEN
            v_utility := v_utility || '|';
        END IF;

        WHILE INSTR(v_utility, '|') > 0 LOOP
            v_pos := INSTR(v_utility, '|');
            v_utility_name := TRIM(SUBSTR(v_utility, 1, v_pos - 1));

            IF v_utility_name IS NOT NULL THEN
                -- Check for duplicates
                SELECT COUNT(*) INTO v_exists 
                FROM ELECTRIC_UTILITY 
                WHERE electric_utility_name = v_utility_name;

                IF v_exists = 0 THEN
                    INSERT INTO ELECTRIC_UTILITY (electric_utility_name)
                    VALUES (v_utility_name);
                    v_counter := v_counter + 1;
                END IF;
            END IF;

            -- Move the string forward. 
            v_utility := SUBSTR(v_utility, v_pos + 1);
            
            EXIT WHEN v_utility IS NULL OR LENGTH(v_utility) = 0;
            
        END LOOP;
    END LOOP;
END;
/
        
-- insert into served_by
/* 
    Check each vehicle in the vehicle table (big table) to see which utilities it has.
    some vehicles have multiple utilities, we split them and match 
    each name with its ID from the electric_utility table.
    Then, we insert each utility into its own row for that same vehicle.
    This links Vehicle table to the electric_utility lookup table. 
    (Many utlity serves many vehicle, many vehicles served by many utilities)
*/
SET SERVEROUTPUT ON;
DECLARE
    v_utility      VARCHAR2(128); 
    v_utility_name VARCHAR2(60); 
    v_pos          NUMBER;
    v_ut_id        NUMBER;
    v_counter      NUMBER := 0;
    
    CURSOR c_vehicles IS 
        SELECT DOL_VEHICLE_ID, electric_utility 
        FROM VEHICLE 
        WHERE electric_utility IS NOT NULL;
BEGIN
    FOR rec IN c_vehicles LOOP
    
        -- change || to |
        v_utility := REPLACE(rec.electric_utility, '||', '|');
        v_utility := v_utility || '|';

        -- Split the string 
        WHILE INSTR(v_utility, '|') > 0 LOOP
            v_pos := INSTR(v_utility, '|');
            v_utility_name := TRIM(SUBSTR(v_utility, 1, v_pos - 1));

            IF v_utility_name IS NOT NULL THEN
                -- Find the ID from your electric_utility table
                BEGIN
                    SELECT UT_ID INTO v_ut_id 
                    FROM ELECTRIC_UTILITY 
                    WHERE electric_utility_name = v_utility_name;

                    -- Insert into the served_by table
                    INSERT INTO SERVED_BY (DOL_VEHICLE_ID, UT_ID)
                    VALUES (rec.DOL_VEHICLE_ID, v_ut_id);
                    
                    v_counter := v_counter + 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL; 
                END;
            END IF;

            v_utility := SUBSTR(v_utility, v_pos + 1);
        END LOOP;
    END LOOP;
END;
/

