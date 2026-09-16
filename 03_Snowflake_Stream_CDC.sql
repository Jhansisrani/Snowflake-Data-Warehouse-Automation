```sql
USE ROLE SYSADMIN;
USE DATABASE ecommerce_db;

CREATE OR REPLACE SCHEMA streams_test;
USE SCHEMA streams_test;


-- Create a raw table to test the streams

CREATE OR REPLACE TABLE members_raw (
    id NUMBER(8) NOT NULL,
    name VARCHAR(255) DEFAULT NULL,
    fee NUMBER(3) NULL
);


-- Create a production table which will consume the streams data

CREATE OR REPLACE TABLE members_prod (
    id NUMBER(8) NOT NULL,
    name VARCHAR(255) DEFAULT NULL,
    fee NUMBER(3) NULL
);


-- Create a standard stream on the raw table

CREATE OR REPLACE STREAM members_std_stream
ON TABLE members_raw;


-- Check the stream

SELECT * FROM members_std_stream;


-- Check the stream offset

SELECT SYSTEM$STREAM_GET_TABLE_TIMESTAMP('members_std_stream')
    AS members_table_st_offset;

SELECT TO_TIMESTAMP(
    SYSTEM$STREAM_GET_TABLE_TIMESTAMP('members_std_stream')
) AS members_table_st_offset;


-- Insert some data into the raw table

INSERT INTO members_raw (id, name, fee)
VALUES
    (1, 'SQL', 0),
    (2, 'Power BI', 0),
    (3, 'Python', 0),
    (4, 'AWS', 0),
    (5, 'DE', 0);


-- Check the stream

SELECT * FROM members_std_stream;


-- Check the stream offset

SELECT SYSTEM$STREAM_GET_TABLE_TIMESTAMP('members_std_stream')
    AS members_table_st_offset;


-- Query the stream data

SELECT
    id,
    name,
    fee
FROM members_std_stream
WHERE METADATA$ACTION = 'INSERT';


-- Consume the stream data by inserting it into the production table

INSERT INTO members_prod (id, name, fee)
SELECT
    id,
    name,
    fee
FROM members_std_stream
WHERE METADATA$ACTION = 'INSERT';


-- Check the production table

SELECT * FROM members_prod;


-- Check the stream offset

SELECT TO_TIMESTAMP(
    SYSTEM$STREAM_GET_TABLE_TIMESTAMP('members_std_stream')
) AS members_table_st_offset;


-- Insert some more data into the raw table

INSERT INTO members_raw (id, name, fee)
VALUES
    (6, 'Alteryx', 0),
    (7, 'Snowflake', 0),
    (8, 'Gen AI', 0);


-- Check the stream

SELECT * FROM members_std_stream;


-- Update the raw table

UPDATE members_raw SET fee = 10 WHERE id = 7;


-- Check the stream

SELECT * FROM members_std_stream;


-- Consume the INSERT records from the stream

INSERT INTO members_prod (id, name, fee)
SELECT
    id,
    name,
    fee
FROM members_std_stream  WHERE METADATA$ACTION = 'INSERT';


-- Update the raw table again

UPDATE members_raw SET fee = 20 WHERE id = 7;


-- Check the production table

SELECT * FROM members_prod;


-- Consume the INSERT records from the stream using MERGE

MERGE INTO members_prod AS mp
USING (
    SELECT
        id,
        name,
        fee
    FROM members_std_stream
    WHERE METADATA$ACTION = 'INSERT'
) AS mstr
ON mp.id = mstr.id

WHEN MATCHED THEN
    UPDATE SET
        mp.fee = mstr.fee,
        mp.name = mstr.name

WHEN NOT MATCHED THEN
    INSERT (id, name, fee)
    VALUES (
        mstr.id,
        mstr.name,
        CAST(mstr.fee AS NUMBER)
    );


-- Check the production table

SELECT * FROM members_prod;
```
