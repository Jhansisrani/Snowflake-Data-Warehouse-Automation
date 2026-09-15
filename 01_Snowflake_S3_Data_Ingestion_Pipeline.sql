-- ============================================
-- 1. STORAGE INTEGRATION
-- ============================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION aws_sf_data
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN =  'arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>'
  STORAGE_ALLOWED_LOCATIONS =  's3://<YOUR_S3_BUCKET>/<YOUR_PATH>/';

DESC INTEGRATION aws_sf_data;


-- ============================================
-- 2. DATABASE AND SCHEMA
-- ============================================

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS jhansi_store;

USE DATABASE jhansi_store;

CREATE SCHEMA IF NOT EXISTS jhansi_store;

USE SCHEMA jhansi_store;


-- ============================================
-- 3. TARGET TABLE
-- ============================================

CREATE OR REPLACE TABLE marketingdata (
    ad_id INT NOT NULL,
    xyz_campaign_id INT,
    fb_campaign_id INT,
    age VARCHAR(5),
    gender CHAR(1),
    interest INT,
    impressions BIGINT,
    clicks INT,
    spent DECIMAL(10, 2),
    total_conversion INT,
    approved_conversion INT,
    PRIMARY KEY (ad_id)
);


-- ============================================
-- 4. CSV FILE FORMAT
-- ============================================

CREATE OR REPLACE FILE FORMAT csv_load_format
    TYPE = 'CSV'
    COMPRESSION = 'AUTO'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042'
    TRIM_SPACE = FALSE
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = '\134'
    DATE_FORMAT = 'AUTO'
    TIMESTAMP_FORMAT = 'AUTO';


-- ============================================
-- 5. EXTERNAL STAGE
-- ============================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STAGE stg_marketing_csv_dev
    STORAGE_INTEGRATION = aws_sf_data
    URL = 's3://<YOUR_S3_BUCKET>/<YOUR_PATH>/'
    FILE_FORMAT = csv_load_format;


-- ============================================
-- 6. VERIFY S3 FILES
-- ============================================

LIST @stg_marketing_csv_dev;


-- ============================================
-- 7. LOAD DATA FROM S3 INTO SNOWFLAKE
-- ============================================

COPY INTO marketingdata FROM @stg_marketing_csv_dev ON_ERROR = CONTINUE;


-- ============================================
-- 8. VERIFY LOADED DATA
-- ============================================

SELECT * FROM marketingdata LIMIT 10;
