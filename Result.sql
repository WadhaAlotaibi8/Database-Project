-- Team 5 [Wadha / Fatma]
-- Project Results 


ALTER SESSION SET CURRENT_SCHEMA = ELECTRIC_VEHICLE1;

-- 1. Is EV ownership truly widespread, or is it limited to wealthy areas?
SELECT
    L.county,
    COUNT(*) AS total_ev
FROM VEHICLE V
JOIN LOCATION L
    ON V.loc_id = L.loc_id
WHERE L.county IS NOT NULL
GROUP BY L.county
ORDER BY total_ev DESC;


-- 2. Are plug-in hybrids actually green, or just marketed as green?
SELECT T.electric_vehicle_type, COUNT(*) AS total_vehicles,
       AVG(V.electric_range)AS avg_range_miles,
       MIN(V.electric_range)AS min_range,
       MAX(V.electric_range) AS max_range
FROM VEHICLE V
JOIN VEHICLE_TYPE T ON V.ev_id = T.ev_id
WHERE V.electric_range > 0
GROUP BY T.electric_vehicle_type
ORDER BY avg_range_miles DESC;


-- 3. Which electricity providers are about to be overwhelmed by charging demand?
SELECT E.electric_utility_name,
       COUNT(*) AS total_vehicles_served
FROM SERVED_BY S
JOIN ELECTRIC_UTILITY E ON S.ut_id = E.ut_id
GROUP BY E.electric_utility_name
ORDER BY total_vehicles_served DESC
FETCH FIRST 10 ROWS ONLY;


-- 4. Has the state's clean vehicle incentive program fallen behind the market?
SELECT S.cafv_eligibility,COUNT(*) AS total_vehicles,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2)    AS percentage
FROM VEHICLE V
JOIN STATUS S ON V.cafv_id = S.cafv_id
GROUP BY S.cafv_eligibility
ORDER BY total_vehicles DESC;



-- 5. Where does the state's own data go blind and why does it matter?
SELECT
    COUNT(*) AS total_records,
    COUNT(*) - COUNT(loc_id) AS missing_location,
    COUNT(*) - COUNT(ev_id) AS missing_ev_type,
    COUNT(*) - COUNT(cafv_id) AS missing_cafv_status,
    COUNT(*) - COUNT(vehicle_location) AS missing_geo_point,
    COUNT(*) - COUNT(legislative_district) AS missing_district,
    COUNT(*) - COUNT(census_tract_2020) AS missing_census_tract
FROM VEHICLE;












