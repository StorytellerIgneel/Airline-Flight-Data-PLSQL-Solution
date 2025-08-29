-- Trigger tables
CREATE TABLE flightlog (
    flight_id           NUMBER,
    flight_code         VARCHAR2(50),
    airline_id          NUMBER,
    source_city_id      NUMBER,
    destination_city_id NUMBER,
    departure_time_id   NUMBER,
    arrival_time_id     NUMBER,
    stops_id            NUMBER,
    class_id            NUMBER,
    duration            NUMBER,
    days_left           NUMBER,
    price               NUMBER,
    uname               VARCHAR2(30),
    log_timestamp       TIMESTAMP DEFAULT SYSTIMESTAMP
);
CREATE TABLE flightaudit (
    audit_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id   NUMBER,
    airline_id  NUMBER,
    flight_code VARCHAR2(20),
    deleted_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Before Insert/Update Trigger 
CREATE OR REPLACE TRIGGER flight_before_insert_update
BEFORE INSERT OR UPDATE ON Flight
FOR EACH ROW
DECLARE
    v_dummy NUMBER;
BEGIN
    -- Basic validation
    IF :NEW.source_city_id = :NEW.destination_city_id THEN
        RAISE_APPLICATION_ERROR(-20001, '❌ Source City and Destination City cannot be the same.');
    END IF;

    IF :NEW.duration <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '❌ Duration must be greater than 0 hours.');
    END IF;

    IF :NEW.price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '❌ Price must be greater than 0 RM.');
    END IF;

    IF :NEW.days_left < 0 THEN
        RAISE_APPLICATION_ERROR(-20004, '❌ Days left cannot be negative.');
    END IF;

    -- ID validation
    BEGIN SELECT 1 INTO v_dummy FROM Airline WHERE airline_id = :NEW.airline_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, '❌ Airline ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM City WHERE city_id = :NEW.source_city_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, '❌ Source City ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM City WHERE city_id = :NEW.destination_city_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, '❌ Destination City ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM Time WHERE time_id = :NEW.departure_time_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, '❌ Departure Time ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM Time WHERE time_id = :NEW.arrival_time_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, '❌ Arrival Time ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM Stop WHERE stop_id = :NEW.stops_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, '❌ Stop ID does not exist.');
    END;

    BEGIN SELECT 1 INTO v_dummy FROM Class WHERE class_id = :NEW.class_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, '❌ Class ID does not exist.');
    END;
END;
/

-- After Insert/Update Trigger
CREATE OR REPLACE TRIGGER flight_after_insert_update
AFTER INSERT OR UPDATE ON Flight
FOR EACH ROW
DECLARE
    v_username           VARCHAR2(30);
    v_airline_name       VARCHAR2(100);
    v_source_city_name   VARCHAR2(100);
    v_dest_city_name     VARCHAR2(100);
    v_departure_time_val VARCHAR2(100);
    v_arrival_time_val   VARCHAR2(100);
    v_stop_count         VARCHAR2(50);
    v_class_name         VARCHAR2(50);
BEGIN
    SELECT USER INTO v_username FROM dual;

    BEGIN SELECT airline_name INTO v_airline_name FROM Airline WHERE airline_id = :NEW.airline_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_airline_name := 'Unknown Airline'; END;

    BEGIN SELECT city_name INTO v_source_city_name FROM City WHERE city_id = :NEW.source_city_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_source_city_name := 'Unknown City'; END;

    BEGIN SELECT city_name INTO v_dest_city_name FROM City WHERE city_id = :NEW.destination_city_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_dest_city_name := 'Unknown City'; END;

    BEGIN SELECT time_category INTO v_departure_time_val FROM Time WHERE time_id = :NEW.departure_time_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_departure_time_val := 'Unknown Time'; END;

    BEGIN SELECT time_category INTO v_arrival_time_val FROM Time WHERE time_id = :NEW.arrival_time_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_arrival_time_val := 'Unknown Time'; END;

    BEGIN SELECT stop_count INTO v_stop_count FROM Stop WHERE stop_id = :NEW.stops_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_stop_count := 'Unknown Stop'; END;

    BEGIN SELECT class_name INTO v_class_name FROM Class WHERE class_id = :NEW.class_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_class_name := 'Unknown Class'; END;

    -- Insert into flightlog
    INSERT INTO flightlog (
        flight_id, flight_code, airline_id, source_city_id, destination_city_id,
        departure_time_id, arrival_time_id, stops_id, class_id,
        duration, days_left, price, uname
    ) VALUES (
        :NEW.flight_id, :NEW.flight_code, :NEW.airline_id, :NEW.source_city_id, :NEW.destination_city_id,
        :NEW.departure_time_id, :NEW.arrival_time_id, :NEW.stops_id, :NEW.class_id,
        :NEW.duration, :NEW.days_left, :NEW.price, v_username
    );

    -- Display flightlog
    DBMS_OUTPUT.PUT_LINE('==========================================');
    IF INSERTING THEN
        DBMS_OUTPUT.PUT_LINE('✈️ New Flight Logged ✈️');
    ELSIF UPDATING THEN
        DBMS_OUTPUT.PUT_LINE('✈️ Flight Update Logged ✈️');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Flight ID        : ' || :NEW.flight_id);
    DBMS_OUTPUT.PUT_LINE('Flight Code      : ' || :NEW.flight_code);
    DBMS_OUTPUT.PUT_LINE('Airline          : ' || v_airline_name);
    DBMS_OUTPUT.PUT_LINE('Route            : ' || v_source_city_name || ' → ' || v_dest_city_name);
    DBMS_OUTPUT.PUT_LINE('Departure Time   : ' || v_departure_time_val);
    DBMS_OUTPUT.PUT_LINE('Arrival Time     : ' || v_arrival_time_val);
    DBMS_OUTPUT.PUT_LINE('Stops            : ' || v_stop_count);
    DBMS_OUTPUT.PUT_LINE('Class            : ' || v_class_name);
    DBMS_OUTPUT.PUT_LINE('Duration (hours) : ' || :NEW.duration);
    DBMS_OUTPUT.PUT_LINE('Days Left        : ' || :NEW.days_left);
    DBMS_OUTPUT.PUT_LINE('Price (USD)      : ' || :NEW.price);
    DBMS_OUTPUT.PUT_LINE('Logged by        : ' || v_username);
    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

-- Before Delete Trigger
CREATE OR REPLACE TRIGGER flight_before_delete
BEFORE DELETE ON Flight
FOR EACH ROW
BEGIN
    IF :OLD.flight_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20021, '❌ Cannot delete: FLIGHT_ID is NULL.');
    ELSIF :OLD.flight_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20022, '❌ Cannot delete: Invalid FLIGHT_ID (must be > 0).');
    END IF;

    IF NVL(:OLD.days_left,0) <=1 THEN
        RAISE_APPLICATION_ERROR(-20023,'❌ Cannot delete: Flight occurs within 1 days.');
    END IF;
END;
/

-- After Trigger Delete
CREATE OR REPLACE TRIGGER flight_after_delete
AFTER DELETE ON Flight
FOR EACH ROW
DECLARE
    v_username VARCHAR2(30);
BEGIN
    SELECT USER INTO v_username FROM dual;

    INSERT INTO flightaudit (
        flight_id,
        airline_id,
        flight_code,
        deleted_at
    ) VALUES (
        :OLD.flight_id,
        :OLD.airline_id,
        :OLD.flight_code,
        SYSTIMESTAMP
    );

    DBMS_OUTPUT.PUT_LINE('======================================');
    DBMS_OUTPUT.PUT_LINE('🗑 Flight Deleted and Logged 🗑');
    DBMS_OUTPUT.PUT_LINE('Flight ID   : ' || :OLD.flight_id);
    DBMS_OUTPUT.PUT_LINE('Flight Code : ' || :OLD.flight_code);
    DBMS_OUTPUT.PUT_LINE('Deleted by  : ' || v_username);
    DBMS_OUTPUT.PUT_LINE('Timestamp   : ' || SYSTIMESTAMP);
    DBMS_OUTPUT.PUT_LINE('======================================');
END;
/

