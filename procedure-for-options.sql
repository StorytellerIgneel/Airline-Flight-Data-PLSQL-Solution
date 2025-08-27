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
