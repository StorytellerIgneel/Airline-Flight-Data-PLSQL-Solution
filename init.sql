DROP TABLE Ticket CASCADE CONSTRAINTS;
DROP TABLE Schedule CASCADE CONSTRAINTS;
DROP TABLE Flight CASCADE CONSTRAINTS;
DROP TABLE Route CASCADE CONSTRAINTS;
DROP TABLE Airline CASCADE CONSTRAINTS;
DROP TABLE City CASCADE CONSTRAINTS;
DROP TABLE Time CASCADE CONSTRAINTS;
DROP TABLE Stop CASCADE CONSTRAINTS;
DROP TABLE Class CASCADE CONSTRAINTS;

-- 1. Airline Table
CREATE TABLE Airline (
    airline_id    NUMBER PRIMARY KEY,
    airline_name  VARCHAR2(100)
);

-- 2. City Table
CREATE TABLE City (
    city_id     NUMBER PRIMARY KEY,
    city_name   VARCHAR2(100)
);

-- 3. Route Table
CREATE TABLE Route (
    route_id             NUMBER PRIMARY KEY,
    source_city_id       NUMBER,
    destination_city_id  NUMBER,
    FOREIGN KEY (source_city_id) REFERENCES City(city_id),
    FOREIGN KEY (destination_city_id) REFERENCES City(city_id)
);

-- 4. Flight Table
CREATE TABLE Flight (
    flight_id    NUMBER PRIMARY KEY,
    airline_id   NUMBER,
    route_id     NUMBER,
    flight_code  VARCHAR2(50) UNIQUE,
    FOREIGN KEY (airline_id) REFERENCES Airline(airline_id),
    FOREIGN KEY (route_id) REFERENCES Route(route_id)
);

-- 5. Time Table
CREATE TABLE Time (
    time_id        NUMBER PRIMARY KEY,
    time_category  VARCHAR2(100)
);

-- 6. Stop Table
CREATE TABLE Stop (
    stop_id     NUMBER PRIMARY KEY,
    stop_count  NUMBER
);

-- 7. Schedule Table
CREATE TABLE Schedule (
    schedule_id        NUMBER PRIMARY KEY,
    flight_id          NUMBER,
    departure_time_id  NUMBER,
    arrival_time_id    NUMBER,
    stop_id            NUMBER,
    duration           NUMBER,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
    FOREIGN KEY (departure_time_id) REFERENCES Time(time_id),
    FOREIGN KEY (arrival_time_id) REFERENCES Time(time_id),
    FOREIGN KEY (stop_id) REFERENCES Stop(stop_id)
);

-- 8. Class Table
CREATE TABLE Class (
    class_id    NUMBER PRIMARY KEY,
    class_name  VARCHAR2(50)
);

-- 9. Ticket Table
CREATE TABLE Ticket (
    ticket_id     NUMBER PRIMARY KEY,
    schedule_id   NUMBER,
    class_id      NUMBER,
    days_left     NUMBER,
    price         NUMBER,
    FOREIGN KEY (schedule_id) REFERENCES Schedule(schedule_id),
    FOREIGN KEY (class_id) REFERENCES Class(class_id)
);

ACCEPT file_path CHAR PROMPT 'Enter full OS path for Data Pump directory: '
ACCEPT csv_file_name CHAR PROMPT 'Enter CSV file name: '

DROP SEQUENCE Airline_seq;
DROP SEQUENCE City_seq;
DROP SEQUENCE Route_seq;
DROP SEQUENCE Flight_seq;
DROP SEQUENCE Time_seq;
DROP SEQUENCE Stop_seq;
DROP SEQUENCE Schedule_seq;
DROP SEQUENCE Class_seq;
DROP SEQUENCE Ticket_seq;

CREATE SEQUENCE Airline_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE City_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Route_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Flight_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Time_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Stop_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Schedule_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Class_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Ticket_seq START WITH 1 INCREMENT BY 1;

DECLARE
    v_file   UTL_FILE.FILE_TYPE;
    v_line   VARCHAR2(4000);
    v_path   VARCHAR2(4000) := '&file_path';
    v_file_name VARCHAR2(100) := '&csv_file_name';
    
BEGIN
    EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY CSV_DIR AS ''' || v_path || '''';
    
    -- Open CSV file
    v_file := UTL_FILE.FOPEN('CSV_DIR', v_file_name, 'R');
    
    -- skip header file
    BEGIN
        UTL_FILE.GET_LINE(v_file, v_line);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('CSV file is empty or only has header.');
            UTL_FILE.FCLOSE(v_file);
            RETURN;
    END;

    LOOP
        BEGIN
            
            BEGIN
                UTL_FILE.GET_LINE(v_file, v_line);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    EXIT;  -- Exit loop at EOF
            END;
    
            -- Process CSV line
            DBMS_OUTPUT.PUT_LINE(v_line);
    
            -- Validate CSV format
            IF INSTR(v_line, ',') = 0 THEN
                RAISE_APPLICATION_ERROR(-20010, 'Invalid CSV format: missing commas.');
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(v_line);  -- prints the current CSV line

            -- Insert Airline (ignore if exists using MERGE)
            MERGE INTO Airline a
            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,2) AS name FROM dual) csv
            ON (a.airline_name = csv.name)
            WHEN NOT MATCHED THEN
              INSERT (airline_id, airline_name)
              VALUES (Airline_seq.NEXTVAL, csv.name);

            -- Insert Cities
            MERGE INTO City c
            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,4) AS name FROM dual) src
            ON (c.city_name = src.name)
            WHEN NOT MATCHED THEN
              INSERT (city_id, city_name)
              VALUES (City_seq.NEXTVAL, src.name);

            MERGE INTO City c
            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,8) AS name FROM dual) dest
            ON (c.city_name = dest.name)
            WHEN NOT MATCHED THEN
              INSERT (city_id, city_name)
              VALUES (City_seq.NEXTVAL, dest.name);

            -- Insert Route
            INSERT INTO Route(route_id, source_city_id, destination_city_id)
            SELECT Route_seq.NEXTVAL,
                   (SELECT city_id FROM City WHERE city_name = REGEXP_SUBSTR(v_line,'[^,]+',1,4)),
                   (SELECT city_id FROM City WHERE city_name = REGEXP_SUBSTR(v_line,'[^,]+',1,8))
            FROM dual;

--            -- Insert Flight
--            MERGE INTO Flight f
--            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,3) AS code FROM dual) csv
--            ON (f.flight_code = csv.code)
--            WHEN NOT MATCHED THEN
--              INSERT (flight_id, airline_id, route_id, flight_code)
--              VALUES (
--                  Flight_seq.NEXTVAL,
--                  (SELECT airline_id FROM Airline WHERE airline_name = REGEXP_SUBSTR(v_line,'[^,]+',1,2)),
--                  Route_seq.CURRVAL,
--                  csv.code
--              );


            -- Insert Time
            MERGE INTO Time t
            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,5) AS dep FROM dual) dep
            ON (t.time_category = dep.dep)
            WHEN NOT MATCHED THEN
              INSERT (time_id, time_category)
              VALUES (Time_seq.NEXTVAL, dep.dep);

            MERGE INTO Time t
            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,7) AS arr FROM dual) arr
            ON (t.time_category = arr.arr)
            WHEN NOT MATCHED THEN
              INSERT (time_id, time_category)
              VALUES (Time_seq.NEXTVAL, arr.arr);

--            -- Insert Stop
--            MERGE INTO Stop s
--            USING (SELECT CASE REGEXP_SUBSTR(v_line,'[^,]+',1,6)
--                           WHEN 'zero' THEN 0
--                           WHEN 'one' THEN 1
--                            WHEN 'two' THEN 2
--                            WHEN 'three' THEN 3
--                           ELSE TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,6))
--                        END AS stops
--                   FROM dual) csv
--            ON (s.stop_count = csv.stops)
--            WHEN NOT MATCHED THEN
--              INSERT (stop_id, stop_count)
--              VALUES (Stop_seq.NEXTVAL, csv.stops);

           -- Insert Schedule
                -- Insert Schedule
--        INSERT INTO Schedule(schedule_id, flight_id, departure_time_id, arrival_time_id, stop_id, duration)
--        SELECT Schedule_seq.NEXTVAL,
--               (SELECT flight_id 
--                FROM Flight 
--                WHERE flight_code = REGEXP_SUBSTR(v_line,'[^,]+',1,3)),  -- get existing flight_id
--               (SELECT time_id FROM Time WHERE time_category = REGEXP_SUBSTR(v_line,'[^,]+',1,5)),  -- departure_time
--               (SELECT time_id FROM Time WHERE time_category = REGEXP_SUBSTR(v_line,'[^,]+',1,7)),  -- arrival_time
--               (SELECT stop_id 
--                FROM Stop 
--                WHERE stop_count =
--                    CASE REGEXP_SUBSTR(v_line,'[^,]+',1,6)
--                        WHEN 'zero' THEN 0
--                        WHEN 'one' THEN 1
--                        WHEN 'two' THEN 2
--                        WHEN 'three' THEN 3
--                        ELSE TO_NUMBER(TRIM(REGEXP_SUBSTR(v_line,'[^,]+',1,6)))
--                    END),  -- stop_id
--               TO_NUMBER(TRIM(REGEXP_SUBSTR(v_line,'[^,]+',1,10)))  -- duration
--        FROM dual;
--
--            -- Insert Class
--            MERGE INTO Class c
--            USING (SELECT REGEXP_SUBSTR(v_line,'[^,]+',1,9) AS cname FROM dual) csv
--            ON (c.class_name = csv.cname)
--            WHEN NOT MATCHED THEN
--              INSERT (class_id, class_name)
--              VALUES (Class_seq.NEXTVAL, csv.cname);
--
--            -- Insert Ticket
--            INSERT INTO Ticket(ticket_id, schedule_id, class_id, days_left, price)
--            SELECT Ticket_seq.NEXTVAL,
--                   Schedule_seq.CURRVAL,
--                   (SELECT class_id 
--                    FROM Class 
--                    WHERE class_name = REGEXP_SUBSTR(v_line,'[^,]+',1,9)),
--                   TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,11)),  -- days_left
--                   TO_NUMBER(REGEXP_SUBSTR(v_line,'[^,]+',1,12))   -- price
--            FROM dual;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
    END LOOP;

    UTL_FILE.FCLOSE(v_file);
END;

