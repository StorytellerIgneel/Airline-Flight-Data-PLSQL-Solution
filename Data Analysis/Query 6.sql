DECLARE
    CURSOR c_airlines IS
        SELECT airline_id, airline_name FROM Airline;

    CURSOR c_classes IS
        SELECT class_id, class_name FROM Class;

    v_best_route   VARCHAR2(200);
    v_worst_route  VARCHAR2(200);
    v_best_value   NUMBER;
    v_worst_value  NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        RPAD('Airline',20) || 
        RPAD('Class',12) ||
        RPAD('Best Route',30) || 
        RPAD('Avg $/hr (Best)',18) || 
        RPAD('Worst Route',30) || 
        'Avg $/hr (Worst)'
    );
    DBMS_OUTPUT.PUT_LINE(RPAD('-',140,'-'));

    FOR rec_air IN c_airlines LOOP
        FOR rec_cls IN c_classes LOOP
            -- Best average-value route (lowest average $/hr)
            BEGIN
                SELECT route, ROUND(avg_value,2)
                INTO v_best_route, v_best_value
                FROM (
                    SELECT dep.city_name || ' → ' || arr.city_name AS route,
                           AVG(f.price / (NULLIF(f.duration,0)/60)) AS avg_value
                    FROM Flight f
                    JOIN City dep ON f.source_city_id = dep.city_id
                    JOIN City arr ON f.destination_city_id = arr.city_id
                    WHERE f.airline_id = rec_air.airline_id
                      AND f.class_id   = rec_cls.class_id
                    GROUP BY dep.city_name, arr.city_name
                    ORDER BY avg_value ASC
                )
                WHERE ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_best_route := 'N/A';
                    v_best_value := NULL;
            END;

            -- Worst average-value route (highest average $/hr)
            BEGIN
                SELECT route, ROUND(avg_value,2)
                INTO v_worst_route, v_worst_value
                FROM (
                    SELECT dep.city_name || ' → ' || arr.city_name AS route,
                           AVG(f.price / (NULLIF(f.duration,0)/60)) AS avg_value
                    FROM Flight f
                    JOIN City dep ON f.source_city_id = dep.city_id
                    JOIN City arr ON f.destination_city_id = arr.city_id
                    WHERE f.airline_id = rec_air.airline_id
                      AND f.class_id   = rec_cls.class_id
                    GROUP BY dep.city_name, arr.city_name
                    ORDER BY avg_value DESC
                )
                WHERE ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_worst_route := 'N/A';
                    v_worst_value := NULL;
            END;

            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec_air.airline_name,20) || 
                RPAD(rec_cls.class_name,12) ||
                RPAD(v_best_route,30) || 
                RPAD(NVL(TO_CHAR(v_best_value),'N/A'),18) || 
                RPAD(v_worst_route,30) || 
                NVL(TO_CHAR(v_worst_value),'N/A')
            );
        END LOOP;
    END LOOP;
END;
/
