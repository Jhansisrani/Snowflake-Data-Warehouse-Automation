-- ============================================================
-- SNOWFLAKE JSON SEMI-STRUCTURED DATA PIPELINE
-- S3 → External Stage → VARIANT → Stream → Task → MERGE
-- ============================================================


-- ============================================================
-- 1. Create / configure the S3 storage integration
-- ============================================================

-- ACCOUNTADMIN is required to create the Storage Integration
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION aws_sf_data
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<>'
    STORAGE_ALLOWED_LOCATIONS = ('<s3/path>');


-- Give SYSADMIN permission to use the integration
GRANT USAGE ON INTEGRATION aws_sf_data TO ROLE SYSADMIN;

-- Allow SYSADMIN to execute Tasks
GRANT EXECUTE TASK ON ACCOUNT TO ROLE SYSADMIN;

-- Allow SYSADMIN to create stages in the target schema
GRANT CREATE STAGE
ON SCHEMA "ECOMMERCE_DB"."ECOMMERCE_LIV"
TO ROLE SYSADMIN;


-- ============================================================
-- 2. Switch to SYSADMIN and select the schema
-- ============================================================

USE ROLE SYSADMIN;

USE SCHEMA "ECOMMERCE_DB"."ECOMMERCE_LIV";


-- Check the Storage Integration details
-- This is also useful when configuring the AWS IAM trust relationship.

DESC INTEGRATION aws_sf_data;


-- ============================================================
-- 3. Create JSON file format
-- ============================================================

-- The source files in S3 contain JSON data.
-- Snowflake will use this file format when reading the files.

CREATE OR REPLACE FILE FORMAT json_load_format
    TYPE = 'JSON';


-- ============================================================
-- 4. Create an External Stage pointing to S3
-- ============================================================

-- The Stage provides Snowflake access to the JSON files
-- stored in the S3 location.

CREATE OR REPLACE STAGE stg_lineitem_json_dev
    STORAGE_INTEGRATION = aws_sf_data
    URL = '</path>'
    FILE_FORMAT = json_load_format;


-- Check whether Snowflake can see the files in S3

LIST @stg_lineitem_json_dev;


-- ============================================================
-- 5. Create a raw table using VARIANT
-- ============================================================

-- VARIANT is used to store semi-structured JSON data.
-- Instead of creating a separate column for every JSON field,
-- the complete JSON object is stored in the SRC column.

CREATE OR REPLACE TABLE lineitem_raw_json (
    SRC VARIANT
);


-- ============================================================
-- 6. Create a Standard Stream
-- ============================================================

-- The Stream captures changes made to the raw JSON table.
-- A Standard Stream can capture INSERT, UPDATE and DELETE changes.

CREATE OR REPLACE STREAM lineitem_std_stream ON TABLE lineitem_raw_json;


-- Check the raw table
SELECT * FROM lineitem_raw_json;


-- ============================================================
-- 7. Create a Task for automatic CDC processing
-- ============================================================

-- The Task runs every minute for practice.
--
-- SYSTEM$STREAM_HAS_DATA checks whether the Stream
-- contains new change records.
--
-- If new data is available, the Task runs the MERGE.

--create target table
CREATE OR REPLACE TABLE lineitem (
    L_ORDERKEY      INT,
    L_PARTKEY       INT,
    L_SUPPKEY       INT,
    L_LINENUMBER    INT,
    L_QUANTITY      FLOAT,
    L_EXTENDEDPRICE FLOAT,
    L_DISCOUNT      FLOAT,
    L_TAX            FLOAT,
    L_RETURNFLAG    STRING,
    L_LINESTATUS    STRING,
    L_SHIPDATE      STRING,
    L_COMMITDATE    STRING,
    L_RECEIPTDATE   STRING,
    L_SHIPINSTRUCT  STRING,
    L_SHIPMODE      STRING,
    L_COMMENT       STRING
);






CREATE OR REPLACE TASK lineitem_load_tsk1
    WAREHOUSE = compute_wh
    SCHEDULE = '1 minute'
    WHEN SYSTEM$STREAM_HAS_DATA('lineitem_std_stream')
AS

MERGE INTO lineitem AS li

-- Read the new INSERT records from the Stream.
-- JSON fields are extracted from the VARIANT column.
USING
(
    SELECT
        SRC:L_ORDERKEY AS L_ORDERKEY,
        SRC:L_PARTKEY AS L_PARTKEY,
        SRC:L_SUPPKEY AS L_SUPPKEY,
        SRC:L_LINENUMBER AS L_LINENUMBER,
        SRC:L_QUANTITY AS L_QUANTITY,
        SRC:L_EXTENDEDPRICE AS L_EXTENDEDPRICE,
        SRC:L_DISCOUNT AS L_DISCOUNT,
        SRC:L_TAX AS L_TAX,
        SRC:L_RETURNFLAG AS L_RETURNFLAG,
        SRC:L_LINESTATUS AS L_LINESTATUS,
        SRC:L_SHIPDATE AS L_SHIPDATE,
        SRC:L_COMMITDATE AS L_COMMITDATE,
        SRC:L_RECEIPTDATE AS L_RECEIPTDATE,
        SRC:L_SHIPINSTRUCT AS L_SHIPINSTRUCT,
        SRC:L_SHIPMODE AS L_SHIPMODE,
        SRC:L_COMMENT AS L_COMMENT
    FROM lineitem_std_stream
   

    -- Process only INSERT records from the Stream
    WHERE METADATA$ACTION = 'INSERT'

) AS li_stg


-- ============================================================
-- 8. MERGE condition
-- ============================================================

-- These columns are being used to identify
-- whether the incoming record already exists
-- in the LINEITEM target table.

ON li.L_ORDERKEY = li_stg.L_ORDERKEY
AND li.L_PARTKEY = li_stg.L_PARTKEY
AND li.L_SUPPKEY = li_stg.L_SUPPKEY


-- ============================================================
-- 9. If the record already exists → UPDATE
-- ============================================================

WHEN MATCHED THEN UPDATE SET

    li.L_PARTKEY = li_stg.L_PARTKEY,
    li.L_SUPPKEY = li_stg.L_SUPPKEY,
    li.L_LINENUMBER = li_stg.L_LINENUMBER,
    li.L_QUANTITY = li_stg.L_QUANTITY,
    li.L_EXTENDEDPRICE = li_stg.L_EXTENDEDPRICE,
    li.L_DISCOUNT = li_stg.L_DISCOUNT,
    li.L_TAX = li_stg.L_TAX,
    li.L_RETURNFLAG = li_stg.L_RETURNFLAG,
    li.L_LINESTATUS = li_stg.L_LINESTATUS,
    li.L_SHIPDATE = li_stg.L_SHIPDATE,
    li.L_COMMITDATE = li_stg.L_COMMITDATE,
    li.L_RECEIPTDATE = li_stg.L_RECEIPTDATE,
    li.L_SHIPINSTRUCT = li_stg.L_SHIPINSTRUCT,
    li.L_SHIPMODE = li_stg.L_SHIPMODE,
    li.L_COMMENT = li_stg.L_COMMENT


-- ============================================================
-- 10. If the record does not exist → INSERT
-- ============================================================

WHEN NOT MATCHED THEN INSERT
(
    L_ORDERKEY,
    L_PARTKEY,
    L_SUPPKEY,
    L_LINENUMBER,
    L_QUANTITY,
    L_EXTENDEDPRICE,
    L_DISCOUNT,
    L_TAX,
    L_RETURNFLAG,
    L_LINESTATUS,
    L_SHIPDATE,
    L_COMMITDATE,
    L_RECEIPTDATE,
    L_SHIPINSTRUCT,
    L_SHIPMODE,
    L_COMMENT
)

VALUES
(
    li_stg.L_ORDERKEY,
    li_stg.L_PARTKEY,
    li_stg.L_SUPPKEY,
    li_stg.L_LINENUMBER,
    li_stg.L_QUANTITY,
    li_stg.L_EXTENDEDPRICE,
    li_stg.L_DISCOUNT,
    li_stg.L_TAX,
    li_stg.L_RETURNFLAG,
    li_stg.L_LINESTATUS,
    li_stg.L_SHIPDATE,
    li_stg.L_COMMITDATE,
    li_stg.L_RECEIPTDATE,
    li_stg.L_SHIPINSTRUCT,
    li_stg.L_SHIPMODE,
    li_stg.L_COMMENT
);


-- ============================================================
-- 11. Check the Task
-- ============================================================

SHOW TASKS;


-- Resume the Task so Snowflake can execute it automatically
ALTER TASK lineitem_load_tsk1 RESUME;


-- ============================================================
-- 12. Load JSON data from S3 into the raw VARIANT table
-- ============================================================

-- COPY INTO loads the JSON records from the external Stage
-- into the SRC VARIANT column.

COPY INTO lineitem_raw_json1 FROM @stg_lineitem_json_dev
ON_ERROR = ABORT_STATEMENT;


-- Check the raw JSON data
SELECT * FROM lineitem_raw_json1;


-- View only the JSON object stored in the VARIANT column
SELECT SRC FROM lineitem_raw_json1;


-- ============================================================
-- 13. Check Task execution history
-- ============================================================

-- Check whether the Task executed successfully
-- after the Stream received new data.

SELECT *
FROM TABLE(
    INFORMATION_SCHEMA.TASK_HISTORY(
        SCHEDULED_TIME_RANGE_START =>
            DATEADD('hour', -1, CURRENT_TIMESTAMP()),
        RESULT_LIMIT => 100
    )
);


-- ============================================================
-- 14. Extract fields from the JSON VARIANT column
-- ============================================================

-- JSON fields can be accessed using:
--
-- SRC:FIELD_NAME
--
-- ::DATA_TYPE converts the extracted JSON value
-- into the required Snowflake data type.

SELECT
    SRC:L_COMMENT::STRING AS L_COMMENT,
    SRC:L_COMMITDATE::STRING AS L_COMMITDATE,
    SRC:L_DISCOUNT::FLOAT AS L_DISCOUNT,
    SRC:L_EXTENDEDPRICE::FLOAT AS L_EXTENDEDPRICE,
    SRC:L_LINENUMBER::INT AS L_LINENUMBER,
    SRC:L_LINESTATUS::STRING AS L_LINESTATUS,
    SRC:L_ORDERKEY::INT AS L_ORDERKEY,
    SRC:L_PARTKEY::INT AS L_PARTKEY,
    SRC:L_QUANTITY::INT AS L_QUANTITY,
    SRC:L_RECEIPTDATE::STRING AS L_RECEIPTDATE,
    SRC:L_RETURNFLAG::STRING AS L_RETURNFLAG,
    SRC:L_SHIPDATE::STRING AS L_SHIPDATE,
    SRC:L_SHIPINSTRUCT::STRING AS L_SHIPINSTRUCT,
    SRC:L_SHIPMODE::STRING AS L_SHIPMODE,
    SRC:L_SUPPKEY::INT AS L_SUPPKEY,
    SRC:L_TAX::FLOAT AS L_TAX
FROM lineitem_raw_json1;
