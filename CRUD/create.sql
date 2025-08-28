-- CRUD Operation
-- Create records in FLIGHT table
-- Show Airlines
EXEC Show_Airlines;
ACCEPT v_airline_id NUMBER PROMPT 'Enter Airline ID: '
ACCEPT v_flight_code CHAR PROMPT 'Enter Flight Code: '

-- Show Cities
EXEC Show_Cities;
ACCEPT v_source_city_id NUMBER PROMPT 'Enter Source City ID: '
ACCEPT v_destination_city_id NUMBER PROMPT 'Enter Destination City ID: '

-- Show Times 
EXEC Show_Times;
ACCEPT v_departure_time_id NUMBER PROMPT 'Enter Departure Time ID: '
ACCEPT v_arrival_time_id NUMBER PROMPT 'Enter Arrival Time ID: '

-- Show Stops 
EXEC Show_Stops;
ACCEPT v_stops_id NUMBER PROMPT 'Enter Stops ID: '

-- Show Classes
EXEC Show_Classes;
ACCEPT v_class_id NUMBER PROMPT 'Enter Class ID: '

DECLARE
    v_flight_code         VARCHAR2(50) := '&v_flight_code';
    v_airline_id          NUMBER := &v_airline_id;
    v_source_city_id      NUMBER := &v_source_city_id;
    v_destination_city_id NUMBER := &v_destination_city_id;
    v_departure_time_id   NUMBER := &v_departure_time_id;
    v_arrival_time_id     NUMBER := &v_arrival_time_id;
    v_stops_id            NUMBER := &v_stops_id;
    v_class_id            NUMBER := &v_class_id;
    v_duration            NUMBER := &v_duration;
    v_days_left           NUMBER := &v_days_left;
    v_price               NUMBER := &v_price;
    error_message         VARCHAR2(512);
BEGIN
    SAVEPOINT s1;

    -- Validation 1: Source and Destination City cannot be the same
    IF v_source_city_id = v_destination_city_id THEN
        RAISE_APPLICATION_ERROR(-20001, '❌ Source City and Destination City cannot be the same.');
    END IF;

    -- Validation 2: Duration must be positive
    IF v_duration <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, '❌ Duration must be greater than 0 hours.');
    END IF;

    -- Validation 3: Price must be positive
    IF v_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, '❌ Price must be greater than 0 RM.');
    END IF;

    -- Insert Flight record
    INSERT INTO Flight (
        flight_code, airline_id, source_city_id,
        destination_city_id, departure_time_id, arrival_time_id,
        stops_id, class_id, duration,
        days_left, price
    ) VALUES (
        v_flight_code, v_airline_id, v_source_city_id,
        v_destination_city_id, v_departure_time_id, v_arrival_time_id,
        v_stops_id, v_class_id, v_duration,
        v_days_left, v_price
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE('RESULTS:');
    DBMS_OUTPUT.PUT_LINE('✅ Flight inserted successfully.');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO s1;
        error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('RESULTS:');
        DBMS_OUTPUT.PUT_LINE('⚠️ An error occurred: ' || error_message);
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
END;
/

SELECT COUNT(*) AS total_flights FROM Flight; 