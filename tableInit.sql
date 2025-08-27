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
/

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
