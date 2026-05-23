-- Team 5 [Wadha / Fatma]
-- Design Constraints

ALTER SESSION SET CURRENT_SCHEMA = ELECTRIC_VEHICLE1;


-- Add new foreign key columns to VEHICLE so it can reference the lookup tables
ALTER TABLE VEHICLE ADD model_id  NUMBER;
ALTER TABLE VEHICLE ADD ev_id     NUMBER;
ALTER TABLE VEHICLE ADD cafv_id   NUMBER;
ALTER TABLE VEHICLE ADD loc_id NUMBER;

--S7
-- Update VEHICLE so each row stores the correct lookup-table ID

UPDATE VEHICLE V
SET V.model_id = (
    SELECT M."id" FROM VEHICLE_MODEL M
    WHERE V.make = M.make AND V.model = M."model"
);

UPDATE VEHICLE V
SET V.ev_id = (
    SELECT T.ev_id FROM VEHICLE_TYPE T
    WHERE V.ev_type = T.electric_vehicle_type
);

UPDATE VEHICLE V
SET V.cafv_id = (
    SELECT S.cafv_id FROM STATUS S
    WHERE V.cafv_type = S.cafv_eligibility
);

UPDATE VEHICLE V
SET V.loc_id = (
    SELECT L.loc_id FROM LOCATION L
    WHERE V.city = L.city
      AND V.county = L.county
      AND V.state = L.state
);

--S8
-- Add foreign key constraints so VEHICLE references the lookup tables correctly
ALTER TABLE VEHICLE ADD CONSTRAINT vehicle_model_FK
    FOREIGN KEY (model_id) REFERENCES VEHICLE_MODEL("id");

ALTER TABLE VEHICLE ADD CONSTRAINT vehicle_ev_type_FK
    FOREIGN KEY (ev_id) REFERENCES VEHICLE_TYPE(ev_id);

ALTER TABLE VEHICLE ADD CONSTRAINT vehicle_status_FK
    FOREIGN KEY (cafv_id) REFERENCES STATUS(cafv_id);
    
ALTER TABLE VEHICLE ADD CONSTRAINT vehicle_location_FK
    FOREIGN KEY (loc_id) REFERENCES LOCATION(loc_id);
    
    
--S9
-- Remove the old repeated text columns after replacing them with IDs
ALTER TABLE VEHICLE DROP COLUMN make;
ALTER TABLE VEHICLE DROP COLUMN model;
ALTER TABLE VEHICLE DROP COLUMN ev_type;
ALTER TABLE VEHICLE DROP COLUMN cafv_type;
ALTER TABLE VEHICLE DROP COLUMN city;
ALTER TABLE VEHICLE DROP COLUMN county;
ALTER TABLE VEHICLE DROP COLUMN state;
ALTER TABLE VEHICLE DROP COLUMN electric_utility;

