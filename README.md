# ❄️ Snowflake Data Warehouse Automation

A hands-on Snowflake project covering **AWS S3 data ingestion, Snowpipe automated ingestion, Snowflake Streams for CDC, Tasks, MERGE processing, and semi-structured JSON data processing**.

## 🚀 Project Overview

This project demonstrates different Snowflake data ingestion and automation scenarios using AWS S3 as the external data source.

The project was developed progressively, starting with basic S3-to-Snowflake ingestion and extending into automated ingestion, CDC processing, task-based automation, and JSON/semi-structured data processing.

---

## 🏗️ Project Workflows

### 1️⃣ Snowflake S3 Data Ingestion

**Workflow:**

```text
AWS S3
   ↓
Snowflake Storage Integration
   ↓
External Stage
   ↓
COPY INTO
   ↓
Snowflake Table
```

This section covers the initial setup and loading of data from AWS S3 into Snowflake.

**Files:**

* [`01_Snowflake_S3_Data_Ingestion_Pipeline.md`](01_Snowflake_S3_Data_Ingestion_Pipeline.md)
* [`01_Snowflake_S3_Data_Ingestion_Pipeline.sql`](01_Snowflake_S3_Data_Ingestion_Pipeline.sql)

---

### 2️⃣ Snowflake S3 Automated Ingestion with Snowpipe

**Workflow:**

```text
AWS S3
   ↓
Snowflake Stage
   ↓
Snowpipe
   ↓
Snowflake Table
```

Configured Snowpipe to automatically ingest new files arriving in the S3 location.

**File:**

* [`02_Snowflake_S3_Auto_Ingestion_Snowpipe.sql`](02_Snowflake_S3_Auto_Ingestion_Snowpipe.sql)

---

### 3️⃣ Snowflake Standard Stream — CDC

**Workflow:**

```text
Snowflake Source Table
        ↓
   Stream (CDC)
        ↓
Incremental Changes
```

Implemented a standard Snowflake Stream to capture incremental changes for downstream processing.

The workflow also explores Snowflake stream metadata such as:

* `METADATA$ACTION`
* `METADATA$ISUPDATE`

**Files:**

* [`03_Snowflake_Standard_Delta_Stream_CDC.md`](03_Snowflake_Standard_Delta_Stream_CDC.md)
* [`03_Snowflake_Standard_Delta_Stream_CDC.sql`](03_Snowflake_Standard_Delta_Stream_CDC.sql)

---

### 4️⃣ Snowflake S3 JSON CDC & Task Processing

**Workflow:**

```text
AWS S3 JSON
     ↓
Raw JSON / VARIANT
     ↓
Snowflake Stream
     ↓
Snowflake Task
     ↓
MERGE
     ↓
Structured Target Table
```

Implemented a semi-structured JSON processing scenario using Snowflake `VARIANT`, Streams, Tasks and SQL MERGE logic.

This demonstrates how JSON data can be ingested from S3 and incrementally processed into structured target tables.

**Files:**

* [`04.Snowflake_S3_JSON_CDC_Task_ingestion.sql`](04.Snowflake_S3_JSON_CDC_Task_ingestion.sql)
* [`04.Snowflake_S3_JSON_CDC_Task_ingestion.sql.md`](04.Snowflake_S3_JSON_CDC_Task_ingestion.sql.md)

---

## 🛠️ Technologies

* Snowflake
* SQL
* AWS S3
* Snowpipe
* Snowflake Streams
* Snowflake Tasks
* SQL MERGE
* JSON / VARIANT
* CDC / Incremental Processing

---

## 📂 Repository Structure

```text
snowflake-data-warehouse-automation/
│
├── README.md
│
├── 01_Snowflake_S3_Data_Ingestion_Pipeline.md
├── 01_Snowflake_S3_Data_Ingestion_Pipeline.sql
│
├── 02_Snowflake_S3_Auto_Ingestion_Snowpipe.sql
│
├── 03_Snowflake_Standard_Delta_Stream_CDC.md
├── 03_Snowflake_Standard_Delta_Stream_CDC.sql
│
├── 04.Snowflake_S3_JSON_CDC_Task_ingestion.sql
└── 04.Snowflake_S3_JSON_CDC_Task_ingestion.sql.md
```

---

## 🔄 Overall Learning Progression

```text
S3 → Snowflake
       ↓
   Snowpipe
       ↓
    Streams
       ↓
     Tasks
       ↓
     MERGE
       ↓
    CDC Processing

        +

S3 JSON
   ↓
VARIANT
   ↓
Stream
   ↓
Task
   ↓
MERGE
   ↓
Structured Data
```

---

## 🎯 Key Concepts Practiced

* Loading data from AWS S3 into Snowflake
* Snowflake Storage Integration and external stages
* Automated file ingestion using Snowpipe
* Change Data Capture using Snowflake Streams
* Stream metadata
* Scheduled and conditional processing using Snowflake Tasks
* Incremental processing using SQL MERGE
* Semi-structured JSON data using `VARIANT`
* JSON CDC processing
* Data validation and pipeline monitoring

---

## 📌 Project Status

**Completed as a hands-on Data Engineering practice project.**

The repository contains SQL scripts and documentation for each stage of the Snowflake ingestion and CDC workflows.
