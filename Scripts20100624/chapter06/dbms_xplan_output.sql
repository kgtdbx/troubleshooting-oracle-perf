SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: dbms_xplan_output.sql
REM Author......: Christian Antognini
REM Date........: August 2008
REM Description.: This script generates a sample output containing the main
REM               information provided by the functions of dbms_xplan.
REM Notes.......: Several SQL statements requires at last Oracle Database 10g
REM               Release 2.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

COLUMN pad FORMAT A10 TRUNCATE

UNDEFINE sql_id
UNDEFINE child_number

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t;

CREATE TABLE t 
AS 
SELECT rownum AS id, rownum AS n, lpad('*',1000,'*') AS pad 
FROM dual 
CONNECT BY level <= 1000;

ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id);

ALTER SESSION SET optimizer_mode = all_rows;
ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET workarea_size_policy = manual;
ALTER SESSION SET sort_area_size = 65536;

PAUSE

REM
REM Display information generated by EXPLAIN PLAN
REM

EXPLAIN PLAN FOR
SELECT t2.* 
FROM t t1, t t2
WHERE t1.n = t2.n
AND t1.id > 6
AND t2.id BETWEEN 6 AND 19;

SELECT * FROM table(dbms_xplan.display(NULL,NULL,'all'));

PAUSE

REM
REM Display information about the last execution
REM

SELECT t2.* 
FROM t t1, t t2
WHERE t1.n = t2.n
AND t1.id > 6
AND t2.id BETWEEN 6 AND 19;

SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'advanced'));

PAUSE

REM
REM Display additional columns, e.g. about partitioning
REM

DROP TABLE t;

CREATE TABLE t 
PARTITION BY HASH (id) 
PARTITIONS 2 
AS 
SELECT rownum AS id, rownum AS n, lpad('*',1000,'*') AS pad 
FROM dual 
CONNECT BY level <= 1000;

PAUSE

REM Display information about partitioning (columns Pstart and Pstop) and
REM temporary space (column TempSpc)

SELECT /*+ gather_plan_statistics */ count(pad) 
FROM (SELECT /* parallel(t,2) */ rownum AS rn, pad 
      FROM t 
      ORDER BY n)
WHERE rn = 1;
/
/
/

SELECT * FROM table(dbms_xplan.display_cursor);

PAUSE

REM Display information about execution statistics (columns Starts, E-Rows,
REM A-Rows and A-Time) and I/O operations (columns Buffers, Reads and Writes)

REM You have to take the sql_id and child_number from the previous output

SELECT * FROM table(dbms_xplan.display_cursor('&&sql_id',&&child_number,'iostats last'));

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor('&&sql_id',&&child_number,'iostats'));

REM Display information about execution statistics (columns Starts, E-Rows,
REM A-Rows and A-Time) and memory utilization (columns OMem, 1Mem, Used-Mem,
REM Used-Tmp, O/1/M and Max-Tmp)

SELECT * FROM table(dbms_xplan.display_cursor('&&sql_id',&&child_number,'memstats last'));

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor('&&sql_id',&&child_number,'memstats'));

REM Display information about remote operations (section "Remote SQL
REM Information" + columns Inst and IN-OUT)

REM A database link referencing the current schema must be created 

CREATE DATABASE LINK loopback 
CONNECT TO &user IDENTIFIED BY &password 
USING '&connect_string';

PAUSE

EXPLAIN PLAN FOR
SELECT count(*)
FROM t t1, t@loopback t2
WHERE t1.id = t2.id;

SELECT * FROM table(dbms_xplan.display(NULL,NULL,'all'));

PAUSE

REM Display information about bind variable peeking (section "Peeked Binds")

VARIABLE id NUMBER
EXECUTE :id := 6;

SELECT * 
FROM t
WHERE id = :id;

SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'peeked_binds'));

PAUSE

REM
REM Cleanup
REM

DROP DATABASE LINK loopback;

DROP TABLE t;
PURGE TABLE t;

UNDEFINE sql_id
UNDEFINE child_number
