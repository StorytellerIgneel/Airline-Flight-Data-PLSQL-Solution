SET SERVEROUTPUT ON;

ACCEPT prompt_table_name  PROMPT 'Enter table name: '
ACCEPT prompt_output      PROMPT 'Enter output columns (x,y,z): '
ACCEPT prompt_condition   PROMPT 'Enter filter condition (e.g., id=2, flight_code=''SG-8709''): '

DECLARE
    v_sql   VARCHAR2(1000);
    v_table VARCHAR2(100) := '&prompt_table_name';
    v_output VARCHAR2(100) := '&prompt_output';
    v_cond  VARCHAR2(400) := '&prompt_condition';
    c       SYS_REFCURSOR;
    v1      VARCHAR2(4000);
    v2      VARCHAR2(4000);

    v_cursor    INTEGER;
    v_col_cnt   INTEGER;
    v_desc_tab  DBMS_SQL.DESC_TAB;
    v_value     VARCHAR2(32767);
    v_dummy     INT;
    v_row_count INTEGER := 0; -- output counter 
BEGIN
    -- Build SQL dynamically
    v_sql := 'SELECT ' || v_output || ' FROM ' || v_table;
    
    IF v_cond IS NOT NULL THEN
        v_sql := v_sql || ' WHERE ' || v_cond;
    END IF;

    -- DBMS_OUTPUT.PUT_LINE('Executing: ' || v_sql);
    
    -- Dynamic v_cursor
    v_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor, v_sql, DBMS_SQL.NATIVE);
    v_dummy := DBMS_SQL.EXECUTE(v_cursor);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor, v_col_cnt, v_desc_tab);

--    DBMS_OUTPUT.PUT_LINE('PASSED CURSOR');
--    DBMS_OUTPUT.PUT_LINE(v_col_cnt);
    -- Define columns
    FOR i IN 1..v_col_cnt LOOP
        DBMS_SQL.DEFINE_COLUMN(v_cursor, i, v_value, 4000);
    END LOOP;

    -- Execute the cursor
    v_dummy := DBMS_SQL.EXECUTE(v_cursor);
    
    DBMS_OUTPUT.PUT_LINE('SEARCH OUTPUT:');
    -- Fetch and print rows
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0 LOOP
        v_row_count := v_row_count + 1; -- increment counter
        DBMS_OUTPUT.PUT(v_row_count || '. ');
        FOR i IN 1..v_col_cnt LOOP
            DBMS_SQL.COLUMN_VALUE(v_cursor, i, v_value);
            DBMS_OUTPUT.PUT(NVL(v_value,'NULL') || ' | ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(v_cursor);
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor);
        END IF;
        RAISE_APPLICATION_ERROR(-20000, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END;
/