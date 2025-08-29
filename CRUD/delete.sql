-- CRUD Operation
-- Delete records in Flight table
ACCEPT v_flight_id NUMBER PROMPT 'Enter Flight ID to delete: '

EXEC Show_Flight_Details(&v_flight_id);
ACCEPT v_confirm CHAR PROMPT 'Are you sure you want to delete this flight? (Y/N): '

DECLARE
    v_flight_id   NUMBER := TO_NUMBER('&v_flight_id');
    v_confirm_raw VARCHAR2(200) := TRIM('&v_confirm');
    v_confirm     CHAR(1) := CASE WHEN v_confirm_raw IS NULL THEN 'N'
                                  ELSE UPPER(SUBSTR(v_confirm_raw,1,1)) END;

    v_current_flight_code   VARCHAR2(50);
    v_current_airline_id    NUMBER;
    v_current_source_city   NUMBER;
    v_current_destination   NUMBER;
    v_current_departure     NUMBER;
    v_current_arrival       NUMBER;
    v_current_stops_id      NUMBER;
    v_current_class_id      NUMBER;
    v_current_duration      NUMBER;
    v_current_days_left     NUMBER;
    v_current_price         NUMBER;

    error_message VARCHAR2(512);
BEGIN
    SAVEPOINT delete_flight;

    SELECT flight_code, airline_id, source_city_id, destination_city_id,
           departure_time_id, arrival_time_id, stops_id, class_id,
           duration, days_left, price
    INTO v_current_flight_code, v_current_airline_id, v_current_source_city,
         v_current_destination, v_current_departure, v_current_arrival,
         v_current_stops_id, v_current_class_id, v_current_duration,
         v_current_days_left, v_current_price
    FROM Flight
    WHERE flight_id = v_flight_id;

    -- Confirm delete
    IF v_confirm = 'Y' THEN
        DELETE FROM Flight WHERE flight_id = v_flight_id;
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('=========================================');
        DBMS_OUTPUT.PUT_LINE('DELETE RESULTS:');
        DBMS_OUTPUT.PUT_LINE('✅ Flight deleted successfully!');
        DBMS_OUTPUT.PUT_LINE('Flight ID     : ' || v_flight_id);
        DBMS_OUTPUT.PUT_LINE('Flight Code   : ' || v_current_flight_code);
        DBMS_OUTPUT.PUT_LINE('Airline ID    : ' || v_current_airline_id);
        DBMS_OUTPUT.PUT_LINE('=========================================');

    ELSE
        ROLLBACK TO delete_flight;
        DBMS_OUTPUT.PUT_LINE('=========================================');
        DBMS_OUTPUT.PUT_LINE('DELETE RESULTS:');
        DBMS_OUTPUT.PUT_LINE('❌ Deletion cancelled by user.');
        DBMS_OUTPUT.PUT_LINE('=========================================');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO delete_flight;
        DBMS_OUTPUT.PUT_LINE('=========================================');
        DBMS_OUTPUT.PUT_LINE('DELETE RESULTS:');
        DBMS_OUTPUT.PUT_LINE('⚠ Oracle Error: Flight ID ' || v_flight_id || ' not found.');
        DBMS_OUTPUT.PUT_LINE('⚠ No records deleted.');
        DBMS_OUTPUT.PUT_LINE('=========================================');

    WHEN OTHERS THEN
        ROLLBACK TO delete_flight;
        error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('=========================================');
        DBMS_OUTPUT.PUT_LINE('DELETE RESULTS:');
        DBMS_OUTPUT.PUT_LINE('⚠ An error occurred: ' || error_message);
        DBMS_OUTPUT.PUT_LINE('⚠ All changes have been rolled back.');
        DBMS_OUTPUT.PUT_LINE('=========================================');
END;
/