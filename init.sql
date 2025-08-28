    -- ==========================================
    -- STEP 1: Prompt for File Path & File Name
    -- ==========================================
    ACCEPT file_path CHAR PROMPT 'Enter full OS path for Data Pump directory: '
    ACCEPT csv_file_name CHAR PROMPT 'Enter CSV file name: '

    -- ==========================================
    -- STEP 1: Drop Tables (ignore errors if not exist)
    -- ==========================================
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE Flight CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'DROP TABLE Airline CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'DROP TABLE City CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'DROP TABLE Stop CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'DROP TABLE Class CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE 'DROP TABLE Time CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    -- ==========================================
    -- STEP 2: Recreate Tables (with AUTO-INCREMENT IDs)
    -- ==========================================
    CREATE TABLE Airline (
        airline_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        airline_name  VARCHAR2(100) UNIQUE
    );

    CREATE TABLE City (
        city_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        city_name   VARCHAR2(100) UNIQUE
    );

    CREATE TABLE Stop (
        stop_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        stop_count  VARCHAR2(50) UNIQUE
    );

    CREATE TABLE Class (
        class_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        class_name  VARCHAR2(50) UNIQUE
    );

    CREATE TABLE Time (
        time_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        time_category  VARCHAR2(100) UNIQUE
    );

    CREATE TABLE Flight (
        flight_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        flight_code        VARCHAR2(50),
        airline_id         NUMBER,
        source_city_id     NUMBER,
        departure_time_id  NUMBER,
        stops_id           NUMBER,
        arrival_time_id    NUMBER,
        destination_city_id NUMBER,
        class_id           NUMBER,
        duration           NUMBER,
        days_left          NUMBER,
        price              NUMBER,
        FOREIGN KEY (airline_id) REFERENCES Airline(airline_id),
        FOREIGN KEY (source_city_id) REFERENCES City(city_id),
        FOREIGN KEY (destination_city_id) REFERENCES City(city_id),
        FOREIGN KEY (departure_time_id) REFERENCES Time(time_id),
        FOREIGN KEY (arrival_time_id) REFERENCES Time(time_id),
        FOREIGN KEY (stops_id) REFERENCES Stop(stop_id),
        FOREIGN KEY (class_id) REFERENCES Class(class_id)
    );

    -- ==========================================
    -- STEP 2: CSV Import via UTL_FILE
    -- ==========================================
    DECLARE
        v_file      UTL_FILE.FILE_TYPE;
        v_line      VARCHAR2(4000);
        v_path      VARCHAR2(4000) := '&file_path';
        v_file_name VARCHAR2(100) := '&csv_file_name';
        v_exists    BOOLEAN;
        v_file_len   PLS_INTEGER;
        v_block_size PLS_INTEGER;
    BEGIN
        -- Create/replace directory
        EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY CSV_DIR AS ''' || v_path || '''';

        -- validation for checking file existence and format before Import
        UTL_FILE.FGETATTR(
            location     => 'CSV_DIR',       -- your Oracle DIRECTORY object
            filename     => v_file_name,   -- your file name
            fexists      => v_exists,
            file_length  => v_file_len,
            block_size   => v_block_size
        );

        IF v_exists THEN
            DBMS_OUTPUT.PUT_LINE('File exists. Size: ' || v_file_len || ' bytes');
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'CSV file not found: ' || v_file_name);
        END IF;
        IF INSTR(v_file_name, '.csv') = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'File is not a CSV file: ' || v_file_name);
            RETURN;
        END IF;

        BEGIN
            -- Open CSV file
            v_file := UTL_FILE.FOPEN('CSV_DIR', v_file_name, 'R');
            SAVEPOINT file_opened;

        EXCEPTION
            --- validation for others
            WHEN UTL_FILE.INVALID_PATH THEN
                RAISE_APPLICATION_ERROR(-20003, 'Invalid directory path: ' || v_path);
                RETURN;
            WHEN UTL_FILE.INVALID_MODE THEN
                RAISE_APPLICATION_ERROR(-20004, 'Invalid file open mode.');
                RETURN;
            WHEN UTL_FILE.INVALID_FILEHANDLE THEN
                RAISE_APPLICATION_ERROR(-20005, 'Invalid file handle.');
                RETURN;
            WHEN UTL_FILE.INVALID_OPERATION THEN
                RAISE_APPLICATION_ERROR(-20006, 'Invalid file operation.');
                RETURN;
            WHEN UTL_FILE.READ_ERROR THEN
                RAISE_APPLICATION_ERROR(-20007, 'Error reading the file.');
                RETURN;
        END;

        -- Skip header line
        BEGIN
            UTL_FILE.GET_LINE(v_file, v_line);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20008, 'CSV is empty.');
                RETURN;
        END;

        LOOP
            BEGIN
                UTL_FILE.GET_LINE(v_file, v_line);
            -- When the file has reached EOF
            EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
            END;

            BEGIN
                -- -- Insert Airline
                MERGE INTO Airline a
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,2))) AS name FROM dual) csv
                ON (a.airline_name = csv.name)
                WHEN NOT MATCHED THEN
                    INSERT (airline_name) VALUES (csv.name);
                SAVEPOINT after_airplanes;

                -- Insert Cities (source and destination)
                MERGE INTO City c
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,4))) AS name FROM dual) src
                ON (c.city_name = src.name)
                WHEN NOT MATCHED THEN
                    INSERT (city_name) VALUES (src.name);
                SAVEPOINT after_source_cities;

                MERGE INTO City c
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,8))) AS name FROM dual) dest
                ON (c.city_name = dest.name)
                WHEN NOT MATCHED THEN
                    INSERT (city_name) VALUES (dest.name);
                SAVEPOINT after_destination_cities;

                -- Insert Time (Departure and Arrival)
                MERGE INTO Time t
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,5))) AS dep FROM dual) d
                ON (t.time_category = d.dep)
                WHEN NOT MATCHED THEN
                    INSERT (time_category) VALUES (d.dep);
                SAVEPOINT after_departure_times;

                MERGE INTO Time t
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,7))) AS arr FROM dual) a
                ON (t.time_category = a.arr)
                WHEN NOT MATCHED THEN
                    INSERT (time_category) VALUES (a.arr);
                SAVEPOINT after_arrival_times;

                -- Insert Stop
                MERGE INTO Stop s
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,6))) AS stops FROM dual) st
                ON (s.stop_count = st.stops)
                WHEN NOT MATCHED THEN
                    INSERT (stop_count) VALUES (st.stops);
                SAVEPOINT after_stop;

                -- Insert Class
                MERGE INTO Class c
                USING (SELECT TRIM(UPPER(REGEXP_SUBSTR(v_line,'[^,]+',1,9))) AS cname FROM dual) cls
                ON (c.class_name = cls.cname)
                WHEN NOT MATCHED THEN
                    INSERT (class_name) VALUES (cls.cname);
                SAVEPOINT after_class;

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
            EXCEPTIONS
                WHEN OTHERS THEN
                    -- Rollback to after classes since most likely the problem comes from flight (reference tables are stable)
                    ROLLBACK TO SAVEPOINT after_class;
                    RAISE_APPLICATION_ERROR(-20009, 'Error on line: ' || v_line || ' - ' || SQLERRM);
                    NULL;
            END;
        END LOOP;
        UTL_FILE.FCLOSE(v_file);
    END;
    /

    COMMIT;

    -- ==========================================
    -- STEP 3: Verification
    -- ==========================================
    SELECT COUNT(*) AS total_flights FROM Flight;
    SELECT COUNT(*) AS total_airlines FROM Airline;
    SELECT COUNT(*) AS total_cities FROM City;
    SELECT COUNT(*) AS total_classes FROM Class;
    SELECT COUNT(*) AS total_stops FROM Stop;
    SELECT COUNT(*) AS total_times FROM Time;

    SELECT * FROM flight;