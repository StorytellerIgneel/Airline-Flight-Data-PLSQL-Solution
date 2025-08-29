DECLARE
    v_avg_economy NUMBER;
    v_avg_business NUMBER;
    v_max_economy NUMBER;
    v_max_business NUMBER;
    v_avg_diff_pct NUMBER;
    v_max_diff NUMBER;
BEGIN
    SELECT AVG(CASE WHEN c.class_name='ECONOMY' THEN f.price END),
           AVG(CASE WHEN c.class_name='BUSINESS' THEN f.price END)
    INTO v_avg_economy, v_avg_business
    FROM Flight f
    JOIN Class c ON f.class_id = c.class_id;

    SELECT MAX(CASE WHEN c.class_name='ECONOMY' THEN f.price END),
           MAX(CASE WHEN c.class_name='BUSINESS' THEN f.price END)
    INTO v_max_economy, v_max_business
    FROM Flight f
    JOIN Class c ON f.class_id = c.class_id;

    v_avg_diff_pct := ROUND(((v_avg_business - v_avg_economy) / v_avg_economy) * 100, 2);
    v_max_diff := ROUND(v_max_business - v_max_economy, 2);

    DBMS_OUTPUT.PUT_LINE(RPAD('Metric',20) || RPAD('Economy',15) || RPAD('Business',15) || 'Difference');
    DBMS_OUTPUT.PUT_LINE(RPAD('-',60,'-'));

    DBMS_OUTPUT.PUT_LINE(RPAD('Average Price',20) || 
                         RPAD(ROUND(v_avg_economy,2),15) || 
                         RPAD(ROUND(v_avg_business,2),15) || 
                         v_avg_diff_pct || '%');

    DBMS_OUTPUT.PUT_LINE(RPAD('Maximum Price',20) || 
                         RPAD(ROUND(v_max_economy,2),15) || 
                         RPAD(ROUND(v_max_business,2),15) || 
                         v_max_diff);
END;
/
