EXEC Show_Cities;

ACCEPT source_city_id NUMBER PROMPT 'Enter Source City ID: '
ACCEPT destination_city_id NUMBER PROMPT 'Enter Destination City ID: '

DECLARE
  v_source_city_id NUMBER := &source_city_id;
  v_dest_city_id   NUMBER := &destination_city_id;
  v_source VARCHAR2(100);
  v_dest   VARCHAR2(100);
BEGIN
  -- Get city names for title
  SELECT city_name INTO v_source FROM City WHERE city_id = v_source_city_id;
  SELECT city_name INTO v_dest   FROM City WHERE city_id = v_dest_city_id;
  
  DBMS_OUTPUT.PUT_LINE('Cheapest and Most Expensive Prices by Airline and Class');
  DBMS_OUTPUT.PUT_LINE('Route: ' || v_source || ' → ' || v_dest);
  DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE(RPAD('Airline', 20) || RPAD('Class', 15) || 
                       LPAD('Lowest Price (Days Left)', 30) || LPAD('Highest Price (Days Left)', 30));
  DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------');
  
  FOR rec IN (
    SELECT 
        a.airline_name,
        cl.class_name,
        -- lowest price + days_left
        MIN(f.price) KEEP (DENSE_RANK FIRST ORDER BY f.price) AS lowest_price,
        MIN(f.days_left) KEEP (DENSE_RANK FIRST ORDER BY f.price) AS lowest_days,
        -- highest price + days_left
        MAX(f.price) KEEP (DENSE_RANK LAST ORDER BY f.price) AS highest_price,
        MAX(f.days_left) KEEP (DENSE_RANK LAST ORDER BY f.price) AS highest_days
    FROM Flight f
    JOIN Airline a ON f.airline_id = a.airline_id
    JOIN Class cl ON f.class_id = cl.class_id
    WHERE f.source_city_id = v_source_city_id
      AND f.destination_city_id = v_dest_city_id
    GROUP BY a.airline_name, cl.class_name
    ORDER BY a.airline_name, cl.class_name
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      RPAD(rec.airline_name, 20) ||
      RPAD(rec.class_name, 15)   ||
      LPAD(rec.lowest_price || ' (' || rec.lowest_days || ' days left)', 30) ||
      LPAD(rec.highest_price || ' (' || rec.highest_days || ' days left)', 30)
    );
  END LOOP;
END;
/
