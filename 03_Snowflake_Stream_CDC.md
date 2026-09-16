Snowflake Stream – CDC Practice
Created a members_raw table to act as the source/raw table.
Created a members_prod table to store the processed data.
Created a standard Stream on members_raw to capture changes (INSERT, UPDATE, DELETE).
Inserted initial records into members_raw and queried the Stream to view the captured changes.
Checked the Stream offset to understand the Stream's current position in the source table's change history.
Consumed the captured INSERT records and loaded them into members_prod.
Added more records and updated existing records in members_raw to generate additional CDC changes.
Used METADATA$ACTION to identify INSERT changes.
Used MERGE with the Stream to apply incremental changes to the production table.
Verified that the production table was updated with the latest Stream data.

Key concept:
Stream = captures changes
Offset = tracks the Stream's position in the source table's change history
MERGE = applies the captured changes to the target/production table.
