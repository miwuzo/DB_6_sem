-- 1.

create tablespace lob_ts
    datafile 'lob_ts222.dbf'
    size 100m
    autoextend on;
drop tablespace lob_ts including contents and datafiles;



-- 2. 

create or replace  directory LOBDIR as '/mnt/lob';


GRANT READ ON DIRECTORY LOBDIR TO c##lob_user;  
-- 3. 

CREATE USER c##lob_user IDENTIFIED BY 1111;

grant create session to c##lob_user;
grant connect, resource to c##lob_user;
grant unlimited tablespace to c##lob_user;
grant create any directory to c##lob_user;
grant execute on utl_file to c##lob_user;

-- 4. 

ALTER SESSION SET CONTAINER = ORCLPDB1;
SELECT username FROM dba_users WHERE username = 'C##LOB_USER';

alter user c##lob_user quota unlimited on LOB_TS;
SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name = 'LOB_TS';
SELECT tablespace_name, status, contents FROM dba_tablespaces ORDER BY tablespace_name;
-- 5.

create table lab10_table (
    id number primary key,
    photo blob,
    doc bfile
);
drop table lab10_table;

-- 6.

select * from lab10_table;
delete from lab10_table;



insert into lab10_table (id, photo, doc) values (3, bfilename('LOBDIR', '2.jpg'), bfilename('LOBDIR', 'test.docx'));





DECLARE
  f BFILE := BFILENAME('LOBDIR', '1.pdf');
BEGIN
  DBMS_OUTPUT.PUT_LINE('File exists: ' || DBMS_LOB.FILEEXISTS(f));
END;
/


















SELECT * FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'LOBDIR';
GRANT READ, WRITE ON DIRECTORY LOBDIR TO sys;