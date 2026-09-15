# Snowflake + S3 Data Ingestion Pipeline

## Overview

This project demonstrates how to ingest CSV data from an Amazon S3 bucket into Snowflake using a Snowflake Storage Integration, External Stage, File Format, and `COPY INTO`.

## Pipeline Flow

```text
Amazon S3 Bucket
       ↓
AWS IAM Role
       ↓
Snowflake Storage Integration
       ↓
External Stage
       ↓
CSV File Format
       ↓
COPY INTO
       ↓
Snowflake Target Table
```

## Steps

### 1. Create an S3 Bucket

Created an Amazon S3 bucket to store the source CSV files.

```text
S3 Bucket
└── marketing CSV files
```

The actual bucket name is not included in this repository for security reasons.

### 2. Create an AWS IAM Role

Created an AWS IAM role that allows Snowflake to access the required S3 location.

The IAM role was configured with the required S3 permissions.

### 3. Create Snowflake Storage Integration

Created a Snowflake Storage Integration using the AWS IAM role.

The Storage Integration establishes a secure connection between Snowflake and Amazon S3 without storing AWS access keys directly in Snowflake.

The AWS account-specific Role ARN is replaced with a placeholder in this repository.

### 4. Configure IAM Trust Relationship

The Snowflake-generated IAM information from the Storage Integration was used to configure the AWS IAM role's trust relationship.

This allows Snowflake to assume the IAM role and access the permitted S3 location.

### 5. Create Snowflake Database and Schema

Created the Snowflake database and schema used for the project.

```text
jhansi_store
└── jhansi_store
```

### 6. Create Target Table

Created the `marketingdata` table in Snowflake to store the CSV data loaded from S3.

### 7. Create CSV File Format

Created a Snowflake CSV File Format defining how the source CSV file should be interpreted.

The configuration includes:

* CSV format
* Comma delimiter
* Header row skipped
* Optional quotation marks
* Automatic compression handling
* Column-count validation

### 8. Create External Stage

Created an external stage pointing to the S3 location.

The stage uses:

* Snowflake Storage Integration
* S3 location
* CSV File Format

```text
S3
 ↓
External Stage
```

### 9. Verify Files in S3

Used the Snowflake `LIST` command to verify that the CSV files were accessible through the external stage.

```sql
LIST @stg_marketing_csv_dev;
```

### 10. Load Data into Snowflake

Used `COPY INTO` to ingest the CSV data from the S3 stage into the Snowflake target table.

```sql
COPY INTO marketingdata
FROM @stg_marketing_csv_dev
ON_ERROR = CONTINUE;
```

### 11. Validate the Loaded Data

Queried the target table to verify that the data was successfully loaded.

```sql
SELECT *
FROM marketingdata
LIMIT 10;
```

## Technologies Used

* Amazon S3
* AWS IAM
* Snowflake
* Snowflake Storage Integration
* Snowflake External Stage
* Snowflake File Format
* Snowflake `COPY INTO`
* SQL

## Architecture

```text
                    AWS
              ┌──────────────┐
              │  S3 Bucket   │
              │ CSV Files    │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │  IAM Role    │
              └──────┬───────┘
                     │
                     ▼
        ┌─────────────────────────┐
        │ Snowflake               │
        │ Storage Integration     │
        └───────────┬─────────────┘
                    │
                    ▼
             External Stage
                    │
                    ▼
              CSV File Format
                    │
                    ▼
              COPY INTO
                    │
                    ▼
           marketingdata Table
```

## Security

AWS account-specific information, IAM role details, S3 bucket names, credentials, and other environment-specific values have been replaced with placeholders before publishing this project to GitHub.

No AWS access keys, secret keys, passwords, or private credentials are stored in this repository.

## Next Step

The next stage of the project extends this batch ingestion pipeline using **Snowpipe automatic ingestion**, allowing new files arriving in S3 to be automatically loaded into Snowflake.
