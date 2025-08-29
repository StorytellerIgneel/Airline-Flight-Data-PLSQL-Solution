EXEC SHOW_AIRLINES;
ACCEPT airline_id1 NUMBER PROMPT 'Enter the first Airline ID: '
ACCEPT airline_id2 NUMBER PROMPT 'Enter the second Airline ID: '

DECLARE
    v_airline_id1 NUMBER := &airline_id1;
    v_airline_id2 NUMBER := &airline_id2;

    v_revenue1 NUMBER := 0;
    v_revenue2 NUMBER := 0;

    v_flight_count1 NUMBER := 0;
    v_flight_count2 NUMBER := 0;

    v_avg_revenue1 NUMBER := 0;
    v_avg_revenue2 NUMBER := 0;

    v_airline_name1 VARCHAR2(100);
    v_airline_name2 VARCHAR2(100);

BEGIN
    SELECT airline_name INTO v_airline_name1
    FROM Airline
    WHERE airline_id = v_airline_id1;

    SELECT airline_name INTO v_airline_name2
    FROM Airline
    WHERE airline_id = v_airline_id2;

    SELECT SUM(f.price), COUNT(f.flight_id)
    INTO v_revenue1, v_flight_count1
    FROM Flight f
    WHERE f.airline_id = v_airline_id1;

    IF v_flight_count1 > 0 THEN
        v_avg_revenue1 := v_revenue1 / v_flight_count1;
    ELSE
        v_avg_revenue1 := 0;
    END IF;

    SELECT SUM(f.price), COUNT(f.flight_id)
    INTO v_revenue2, v_flight_count2
    FROM Flight f
    WHERE f.airline_id = v_airline_id2;

    IF v_flight_count2 > 0 THEN
        v_avg_revenue2 := v_revenue2 / v_flight_count2;
    ELSE
        v_avg_revenue2 := 0;
    END IF;

    DBMS_OUTPUT.PUT_LINE(RPAD('Attribute', 26) || ' | ' || RPAD('Airline ID: ' || v_airline_id1 || ' ' || v_airline_name1, 30) || ' | ' || RPAD('Airline ID: ' || v_airline_id2 || ' ' || v_airline_name2, 31)||'|');
    DBMS_OUTPUT.PUT_LINE('---------------------------|--------------------------------|--------------------------------|');
    DBMS_OUTPUT.PUT_LINE(RPAD('Revenue', 26) || ' | ' || RPAD('$' || TO_CHAR(v_revenue1, '999,999,999,999.00'), 30) || ' | ' || RPAD('$' || TO_CHAR(v_revenue2, '999,999,999,999.00'), 31)||'|');
    
    DBMS_OUTPUT.PUT_LINE(RPAD('Total Flights', 26) || ' | ' || RPAD(TO_CHAR(v_flight_count1), 30) || ' | ' || RPAD(TO_CHAR(v_flight_count2), 31)||'|');
    
    DBMS_OUTPUT.PUT_LINE(RPAD('Average Revenue per Flight', 26) || ' | ' || RPAD('$' || TO_CHAR(v_avg_revenue1, '999,999,999.00'), 30) || ' | ' || RPAD('$' || TO_CHAR(v_avg_revenue2, '999,999,999.00'), 31)||'|');
    
    DBMS_OUTPUT.PUT_LINE('---------------------------|--------------------------------|--------------------------------|');
END;
/
