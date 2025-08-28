-- CRUD Operation
-- Update records in Flight table
ACCEPT v_flight_id NUMBER PROMPT 'Enter Flight ID to update: '
EXEC Show_Flight_Details(&v_flight_id);

EXEC Show_Airlines;
ACCEPT v_new_airline_id NUMBER PROMPT 'Enter new Airline ID (or 0 to keep current): '
ACCEPT v_new_flight_code CHAR PROMPT 'Enter new Flight Code (or press Enter to keep current): '

EXEC Show_Cities;
ACCEPT v_new_source_city_id NUMBER PROMPT 'Enter new Source City ID (or 0 to keep current): '
ACCEPT v_new_destination_city_id NUMBER PROMPT 'Enter new Destination City ID (or 0 to keep current): '

EXEC Show_Times;
ACCEPT v_new_departure_time_id NUMBER PROMPT 'Enter new Departure Time ID (or 0 to keep current): '
ACCEPT v_new_arrival_time_id NUMBER PROMPT 'Enter new Arrival Time ID (or 0 to keep current): '

EXEC Show_Stops;
ACCEPT v_new_stops_id NUMBER PROMPT 'Enter new Stops ID (or 0 to keep current): '

EXEC Show_Classes;
ACCEPT v_new_class_id NUMBER PROMPT 'Enter new Class ID (or 0 to keep current): '

ACCEPT v_new_duration NUMBER PROMPT 'Enter new Duration in hours (or 0 to keep current): '
ACCEPT v_new_days_left NUMBER PROMPT 'Enter new Days Left (or 0 to keep current): '
ACCEPT v_new_price NUMBER PROMPT 'Enter new Price in RM (or 0 to keep current): '

DECLARE
    v_flight_id               NUMBER := TO_NUMBER('&v_flight_id');
    v_new_flight_code         VARCHAR2(50) := NULLIF('&v_new_flight_code', '');
    v_new_airline_id          NUMBER := TO_NUMBER(NVL('&v_new_airline_id', '0'));
    v_new_source_city_id      NUMBER := TO_NUMBER(NVL('&v_new_source_city_id', '0'));
    v_new_destination_city_id NUMBER := TO_NUMBER(NVL('&v_new_destination_city_id', '0'));
    v_new_departure_time_id   NUMBER := TO_NUMBER(NVL('&v_new_departure_time_id', '0'));
    v_new_arrival_time_id     NUMBER := TO_NUMBER(NVL('&v_new_arrival_time_id', '0'));
    v_new_stops_id            NUMBER := TO_NUMBER(NVL('&v_new_stops_id', '0'));
    v_new_class_id            NUMBER := TO_NUMBER(NVL('&v_new_class_id', '0'));
    v_new_duration            NUMBER := TO_NUMBER(NVL('&v_new_duration', '0'));
    v_new_days_left           NUMBER := TO_NUMBER(NVL('&v_new_days_left', '0'));
    v_new_price               NUMBER := TO_NUMBER(NVL('&v_new_price', '0'));
    
    -- Current values
    v_current_flight_code         VARCHAR2(50);
    v_current_airline_id          NUMBER;
    v_current_source_city_id      NUMBER;
    v_current_destination_city_id NUMBER;
    v_current_departure_time_id   NUMBER;
    v_current_arrival_time_id     NUMBER;
    v_current_stops_id            NUMBER;
    v_current_class_id            NUMBER;
    v_current_duration            NUMBER;
    v_current_days_left           NUMBER;
    v_current_price               NUMBER;
    
    error_message VARCHAR2(512);
BEGIN
    SAVEPOINT update_flight;
    
    -- Get current values
    SELECT flight_code, airline_id, source_city_id, destination_city_id,
           departure_time_id, arrival_time_id, stops_id, class_id,
           duration, days_left, price
    INTO v_current_flight_code, v_current_airline_id, v_current_source_city_id,
         v_current_destination_city_id, v_current_departure_time_id, v_current_arrival_time_id,
         v_current_stops_id, v_current_class_id, v_current_duration, v_current_days_left, v_current_price
    FROM Flight
    WHERE flight_id = v_flight_id;
    
    -- Use current values if new values are not provided
    IF v_new_flight_code IS NULL OR TRIM(v_new_flight_code) = '' THEN
        v_new_flight_code := v_current_flight_code;
    END IF;
    
    IF v_new_airline_id = 0 THEN
        v_new_airline_id := v_current_airline_id;
    END IF;
    
    IF v_new_source_city_id = 0 THEN
        v_new_source_city_id := v_current_source_city_id;
    END IF;
    
    IF v_new_destination_city_id = 0 THEN
        v_new_destination_city_id := v_current_destination_city_id;
    END IF;
    
    IF v_new_departure_time_id = 0 THEN
        v_new_departure_time_id := v_current_departure_time_id;
    END IF;
    
    IF v_new_arrival_time_id = 0 THEN
        v_new_arrival_time_id := v_current_arrival_time_id;
    END IF;
    
    IF v_new_stops_id = 0 THEN
        v_new_stops_id := v_current_stops_id;
    END IF;
    
    IF v_new_class_id = 0 THEN
        v_new_class_id := v_current_class_id;
    END IF;
    
    IF v_new_duration = 0 THEN
        v_new_duration := v_current_duration;
    END IF;
    
    IF v_new_days_left = 0 THEN
        v_new_days_left := v_current_days_left;
    END IF;
    
    IF v_new_price = 0 THEN
        v_new_price := v_current_price;
    END IF;
    
    -- Update Flight record
    UPDATE Flight
    SET flight_code = v_new_flight_code,
        airline_id = v_new_airline_id,
        source_city_id = v_new_source_city_id,
        destination_city_id = v_new_destination_city_id,
        departure_time_id = v_new_departure_time_id,
        arrival_time_id = v_new_arrival_time_id,
        stops_id = v_new_stops_id,
        class_id = v_new_class_id,
        duration = v_new_duration,
        days_left = v_new_days_left,
        price = v_new_price
    WHERE flight_id = v_flight_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('UPDATE RESULTS:');
    DBMS_OUTPUT.PUT_LINE('✅ Flight updated successfully!');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO update_flight;
        error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('==========================================');
        DBMS_OUTPUT.PUT_LINE('UPDATE RESULTS:');
        DBMS_OUTPUT.PUT_LINE('⚠ An error occurred: ' || error_message);
        DBMS_OUTPUT.PUT_LINE('⚠ All changes have been rolled back.');
        DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

-- Show final flight count
SELECT COUNT(*) AS total_flights FROM Flight;