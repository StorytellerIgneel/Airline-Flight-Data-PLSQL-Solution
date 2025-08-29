EXEC SHOW_TIMES;

ACCEPT dep_time_1_id CHAR PROMPT 'Enter Departure Time Slot ID for Option 1: '
ACCEPT arr_time_1_id CHAR PROMPT 'Enter Arrival Time Slot ID for Option 1: '
ACCEPT dep_time_2_id CHAR PROMPT 'Enter Departure Time Slot ID for Option 2: '
ACCEPT arr_time_2_id CHAR PROMPT 'Enter Arrival Time Slot ID for Option 2: '

DECLARE
    v_dep_time_1_name VARCHAR2(50);
    v_arr_time_1_name VARCHAR2(50);
    v_dep_time_2_name VARCHAR2(50);
    v_arr_time_2_name VARCHAR2(50);
    v_time_option_1_name VARCHAR2(100);
    v_time_option_2_name VARCHAR2(100);
    -- Declare variables for average prices
    v_avg_price_business_1 NUMBER;
    v_avg_price_economy_1 NUMBER;
    v_avg_price_business_2 NUMBER;
    v_avg_price_economy_2 NUMBER;
BEGIN
    -- Get departure time name for Option 1
    SELECT time_category
    INTO v_dep_time_1_name
    FROM Time
    WHERE time_id = TO_NUMBER('&dep_time_1_id');
    
    -- Get arrival time name for Option 1
    SELECT time_category
    INTO v_arr_time_1_name
    FROM Time
    WHERE time_id = TO_NUMBER('&arr_time_1_id');
    
    v_time_option_1_name := v_dep_time_1_name || ' -> ' || v_arr_time_1_name;

    -- Get departure time name for Option 2
    SELECT time_category
    INTO v_dep_time_2_name
    FROM Time
    WHERE time_id = TO_NUMBER('&dep_time_2_id');
    
    -- Get arrival time name for Option 2
    SELECT time_category
    INTO v_arr_time_2_name
    FROM Time
    WHERE time_id = TO_NUMBER('&arr_time_2_id');
    
    v_time_option_2_name := v_dep_time_2_name || ' -> ' || v_arr_time_2_name;

    BEGIN
        -- Business Class Average Price for Option 1
        SELECT NVL(AVG(f.price), 0)
        INTO v_avg_price_business_1
        FROM Flight f
        JOIN Class c ON f.class_id = c.class_id
        WHERE f.departure_time_id = TO_NUMBER('&dep_time_1_id')
          AND f.arrival_time_id = TO_NUMBER('&arr_time_1_id')
          AND UPPER(c.class_name) = 'BUSINESS';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_avg_price_business_1 := 0;
    END;

    BEGIN
        -- Economy Class Average Price for Option 1
        SELECT NVL(AVG(f.price), 0)
        INTO v_avg_price_economy_1
        FROM Flight f
        JOIN Class c ON f.class_id = c.class_id
        WHERE f.departure_time_id = TO_NUMBER('&dep_time_1_id')
          AND f.arrival_time_id = TO_NUMBER('&arr_time_1_id')
          AND UPPER(c.class_name) = 'ECONOMY';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_avg_price_economy_1 := 0;
    END;

    BEGIN
        -- Business Class Average Price for Option 2
        SELECT NVL(AVG(f.price), 0)
        INTO v_avg_price_business_2
        FROM Flight f
        JOIN Class c ON f.class_id = c.class_id
        WHERE f.departure_time_id = TO_NUMBER('&dep_time_2_id')
          AND f.arrival_time_id = TO_NUMBER('&arr_time_2_id')
          AND UPPER(c.class_name) = 'BUSINESS';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_avg_price_business_2 := 0;
    END;

    BEGIN
        -- Economy Class Average Price for Option 2
        SELECT NVL(AVG(f.price), 0)
        INTO v_avg_price_economy_2
        FROM Flight f
        JOIN Class c ON f.class_id = c.class_id
        WHERE f.departure_time_id = TO_NUMBER('&dep_time_2_id')
          AND f.arrival_time_id = TO_NUMBER('&arr_time_2_id')
          AND UPPER(c.class_name) = 'ECONOMY';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_avg_price_economy_2 := 0;
    END;

    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('Flight Price Comparison');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    
    -- Header row
    DBMS_OUTPUT.PUT_LINE(RPAD('Attribute', 26) || ' | ' || 
                        RPAD('Option 1: ' || v_time_option_1_name, 30) || ' | ' || 
                        RPAD('Option 2: ' || v_time_option_2_name, 30));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 26, '-') || '-+-' || 
                        RPAD('-', 30, '-') || '-+-' || 
                        RPAD('-', 30, '-'));
    
    -- Business Class row
    DBMS_OUTPUT.PUT_LINE(RPAD('Business Class', 26) || ' | ' || 
                        RPAD(CASE 
                            WHEN v_avg_price_business_1 = 0 THEN 'No flights found'
                            ELSE '$' || TO_CHAR(v_avg_price_business_1, '999,999,999.00')
                        END, 30) || ' | ' || 
                        RPAD(CASE 
                            WHEN v_avg_price_business_2 = 0 THEN 'No flights found'
                            ELSE '$' || TO_CHAR(v_avg_price_business_2, '999,999,999.00')
                        END, 30));
    
    -- Economy Class row
    DBMS_OUTPUT.PUT_LINE(RPAD('Economy Class', 26) || ' | ' || 
                        RPAD(CASE 
                            WHEN v_avg_price_economy_1 = 0 THEN 'No flights found'
                            ELSE '$' || TO_CHAR(v_avg_price_economy_1, '999,999,999.00')
                        END, 30) || ' | ' || 
                        RPAD(CASE 
                            WHEN v_avg_price_economy_2 = 0 THEN 'No flights found'
                            ELSE '$' || TO_CHAR(v_avg_price_economy_2, '999,999,999.00')
                        END, 30));
    
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 26, '-') || '-+-' || 
                        RPAD('-', 30, '-') || '-+-' || 
                        RPAD('-', 30, '-'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
END;
/
