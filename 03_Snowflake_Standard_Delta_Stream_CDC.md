
### Stream CDC Practice

* Created `members_raw` as the source/raw table and `members_prod` as the production/target table.
* Created a standard Stream on `members_raw` to capture CDC changes.
* Inserted records into `members_raw` and checked the Stream to view the captured changes.
* Checked the Stream offset to observe its position in the source table's change history.
* For the first processing step, filtered the Stream using `METADATA$ACTION = 'INSERT'` and **manually loaded those INSERT records into `members_prod`**.
* Performed additional INSERT and UPDATE operations on `members_raw` to generate more CDC changes.
* Finally used `MERGE` with the Stream to apply incremental changes to `members_prod`.


Key concept:
Stream = captures changes
Offset = tracks the Stream's position in the source table's change history
MERGE = applies the captured changes to the target/production table.
