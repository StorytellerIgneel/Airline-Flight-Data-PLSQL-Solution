-- CRUD Operation
-- Create records in Flight table
EXEC Show_Airlines;
ACCEPT v_airline_id NUMBER PROMPT 'Enter Airline ID: '
ACCEPT v_flight_code CHAR PROMPT 'Enter Flight Code: '

EXEC Show_Cities;
ACCEPT v_source_city_id NUMBER PROMPT 'Enter Source City ID: '
ACCEPT v_destination_city_id NUMBER PROMPT 'Enter Destination City ID: '

EXEC Show_Times;
ACCEPT v_departure_time_id NUMBER PROMPT 'Enter Departure Time ID: '
ACCEPT v_arrival_time_id NUMBER PROMPT 'Enter Arrival Time ID: '

EXEC Show_Stops;
ACCEPT v_stop_id NUMBER PROMPT 'Enter Stops ID: '

EXEC Show_Classes;
ACCEPT v_class_id NUMBER PROMPT 'Enter Class ID: '

ACCEPT v_duration NUMBER PROMPT 'Enter Duration (hours): '
ACCEPT v_days_left NUMBER PROMPT 'Enter Days Left: '
ACCEPT v_price NUMBER PROMPT 'Enter Price (RM): '

DECLARE
    v_flight_code         VARCHAR2(50) := '&v_flight_code';
    v_airline_id          NUMBER := &v_airline_id;
    v_source_city_id      NUMBER := &v_source_city_id;
    v_destination_city_id NUMBER := &v_destination_city_id;
    v_departure_time_id   NUMBER := &v_departure_time_id;
    v_arrival_time_id     NUMBER := &v_arrival_time_id;
    v_stop_id             NUMBER := &v_stop_id;
    v_class_id            NUMBER := &v_class_id;
    v_duration            NUMBER := &v_duration;
    v_days_left           NUMBER := &v_days_left;
    v_price               NUMBER := &v_price;
BEGIN   
    SAVEPOINT insert_flight;

    -- Insert Flight record
    INSERT INTO Flight (
        flight_code, airline_id, source_city_id, destination_city_id,
        departure_time_id, arrival_time_id, stops_id, class_id,
        duration, days_left, price
    ) VALUES (
        v_flight_code, v_airline_id, v_source_city_id, v_destination_city_id,
        v_departure_time_id, v_arrival_time_id, v_stop_id, v_class_id,
        v_duration, v_days_left, v_price
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('=========================================');
    DBMS_OUTPUT.PUT_LINE('INSERT RESULTS:');
    DBMS_OUTPUT.PUT_LINE('✅ Flight inserted successfully!');
    DBMS_OUTPUT.PUT_LINE('=========================================');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO insert_flight;
        error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('=========================================');
        DBMS_OUTPUT.PUT_LINE('INSERT RESULTS:');
        DBMS_OUTPUT.PUT_LINE('⚠ Error inserting flight: ' || error_message);
        DBMS_OUTPUT.PUT_LINE('⚠ All changes have been rolled back.');
        DBMS_OUTPUT.PUT_LINE('=========================================');
END;
/


-- Check total flights
SELECT COUNT(*) AS total_flights FROM Flight;
SELECT * FROM flightlog;