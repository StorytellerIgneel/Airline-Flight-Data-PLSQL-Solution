-- IMPORTANT!! Must run this file first!!!
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Procedures for showing available options before user input
-- Show Airlines
CREATE OR REPLACE PROCEDURE Show_Airlines IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Available Airlines:');
    FOR rec IN (SELECT airline_id, airline_name FROM Airline) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.airline_id || ' | Name: ' || rec.airline_name);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/


-- Show Cities
CREATE OR REPLACE PROCEDURE Show_Cities IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Available Cities:');
    FOR rec IN (SELECT city_id, city_name FROM City) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.city_id || ' | Name: ' || rec.city_name);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Show Stops
CREATE OR REPLACE PROCEDURE Show_Stops IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Available Stops:');
    FOR rec IN (SELECT stop_id, stop_count FROM Stop) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.stop_id || ' | Stops: ' || rec.stop_count);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Show Classes
CREATE OR REPLACE PROCEDURE Show_Classes IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Available Classes:');
    FOR rec IN (SELECT class_id, class_name FROM Class) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.class_id || ' | Class: ' || rec.class_name);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Show Time Categories
CREATE OR REPLACE PROCEDURE Show_Times IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Available Time Categories:');
    FOR rec IN (SELECT time_id, time_category FROM Time) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.time_id || ' | Time: ' || rec.time_category);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

CREATE OR REPLACE PROCEDURE Show_Flight_Details(p_flight_id IN NUMBER) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('✈️ Current Flight Details ✈️');
    DBMS_OUTPUT.PUT_LINE('==========================================');

    FOR rec IN (
        SELECT f.flight_id, f.flight_code, 
               f.airline_id, a.airline_name,
               f.source_city_id, sc.city_name as source_city,
               f.destination_city_id, dc.city_name as dest_city,
               f.departure_time_id, dt.time_category as dep_time,
               f.arrival_time_id, at.time_category as arr_time,
               f.stops_id, s.stop_count,
               f.class_id, c.class_name,
               f.duration, f.days_left, f.price
        FROM Flight f
        JOIN Airline a ON f.airline_id = a.airline_id
        JOIN City sc ON f.source_city_id = sc.city_id
        JOIN City dc ON f.destination_city_id = dc.city_id
        JOIN Time dt ON f.departure_time_id = dt.time_id
        JOIN Time at ON f.arrival_time_id = at.time_id
        JOIN Stop s ON f.stops_id = s.stop_id
        JOIN Class c ON f.class_id = c.class_id
        WHERE f.flight_id = p_flight_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Flight ID        : ' || rec.flight_id);
        DBMS_OUTPUT.PUT_LINE('Flight Code      : ' || rec.flight_code);
        DBMS_OUTPUT.PUT_LINE('Airline          : ' || rec.airline_name);
        DBMS_OUTPUT.PUT_LINE('Route            : ' || rec.source_city || ' → ' || rec.dest_city);
        DBMS_OUTPUT.PUT_LINE('Departure Time   : ' || rec.dep_time);
        DBMS_OUTPUT.PUT_LINE('Arrival Time     : ' || rec.arr_time);
        DBMS_OUTPUT.PUT_LINE('Stops            : ' || rec.stop_count);
        DBMS_OUTPUT.PUT_LINE('Class            : ' || rec.class_name);
        DBMS_OUTPUT.PUT_LINE('Duration (hours) : ' || rec.duration);
        DBMS_OUTPUT.PUT_LINE('Days Left        : ' || rec.days_left);
        DBMS_OUTPUT.PUT_LINE('Price (USD)      : ' || rec.price);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
