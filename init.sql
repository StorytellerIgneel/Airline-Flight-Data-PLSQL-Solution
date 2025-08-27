-- ==========================================
-- STEP 0: Prompt for File Path & File Name
-- ==========================================
ACCEPT file_path CHAR PROMPT 'Enter full OS path for Data Pump directory: '
ACCEPT csv_file_name CHAR PROMPT 'Enter CSV file name: '

-- ==========================================
-- STEP 3: CSV Import via UTL_FILE
-- ==========================================
DECLARE
    v_file   UTL_FILE.FILE_TYPE;
    v_line   VARCHAR2(4000);
    v_path   VARCHAR2(4000) := '&file_path';
    v_file_name VARCHAR2(100) := '&csv_file_name';
BEGIN
    -- Create/replace directory
    EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY CSV_DIR AS ''' || v_path || '''';

    -- Open CSV file
    v_file := UTL_FILE.FOPEN('CSV_DIR', v_file_name, 'R');

    -- Skip header line
    BEGIN
        UTL_FILE.GET_LINE(v_file, v_line);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('CSV is empty.');
            RETURN;
    END;

    LOOP
        BEGIN
            UTL_FILE.GET_LINE(v_file, v_line);
        EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
        END;

        -- Insert Airline
        MERGE INTO Airline a
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,2))) AS name FROM dual) csv
        ON (a.airline_name = csv.name)
        WHEN NOT MATCHED THEN
            INSERT (airline_name) VALUES (csv.name);

        -- Insert Cities
        MERGE INTO City c
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,4))) AS name FROM dual) src
        ON (c.city_name = src.name)
        WHEN NOT MATCHED THEN
            INSERT (city_name) VALUES (src.name);

        MERGE INTO City c
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,8))) AS name FROM dual) dest
        ON (c.city_name = dest.name)
        WHEN NOT MATCHED THEN
            INSERT (city_name) VALUES (dest.name);

        -- Insert Time
        MERGE INTO Time t
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,5))) AS dep FROM dual) d
        ON (t.time_category = d.dep)
        WHEN NOT MATCHED THEN
            INSERT (time_category) VALUES (d.dep);

        MERGE INTO Time t
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,7))) AS arr FROM dual) a
        ON (t.time_category = a.arr)
        WHEN NOT MATCHED THEN
            INSERT (time_category) VALUES (a.arr);

        -- Insert Stop
        MERGE INTO Stop s
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,6))) AS stops FROM dual) st
        ON (s.stop_count = st.stops)
        WHEN NOT MATCHED THEN
            INSERT (stop_count) VALUES (st.stops);

        -- Insert Class
        MERGE INTO Class c
        USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,9))) AS cname FROM dual) cls
        ON (c.class_name = cls.cname)
        WHEN NOT MATCHED THEN
            INSERT (class_name) VALUES (cls.cname);

        -- Insert Flight
        INSERT INTO Flight (
            flight_code, airline_id, source_city_id, departure_time_id,
            stops_id, arrival_time_id, destination_city_id, class_id, duration, days_left, price
        )
        VALUES (
            TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,3))),
            (SELECT airline_id FROM Airline WHERE airline_name = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,2)))),
            (SELECT city_id FROM City WHERE city_name = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,4)))),
            (SELECT time_id FROM Time WHERE time_category = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,5)))),
            (SELECT stop_id FROM Stop WHERE stop_count = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,6)))),
            (SELECT time_id FROM Time WHERE time_category = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,7)))),
            (SELECT city_id FROM City WHERE city_name = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,8)))),
            (SELECT class_id FROM Class WHERE class_name = TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,9)))),
            TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,10)),
            TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,11)),
            TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,12))
        );

    END LOOP;
    UTL_FILE.FCLOSE(v_file);
END;
/

COMMIT;

-- ==========================================
-- STEP 4: Verification
-- ==========================================
SELECT COUNT(*) AS total_flights FROM Flight;
SELECT COUNT(*) AS total_airlines FROM Airline;
SELECT COUNT(*) AS total_cities FROM City;
SELECT COUNT(*) AS total_classes FROM Class;
SELECT COUNT(*) AS total_stops FROM Stop;
SELECT COUNT(*) AS total_times FROM Time;

SELECT * FROM flight;