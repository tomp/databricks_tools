Databricks Tools
================
Code and data used for checking the PDM Databricks tables for data quality
and governance issues.


Installation
------------
The `databricks_tables.sh` script uses the databricks CLI to interact with
Databricks, so that needs to be installed, first.  The python scripts
will need `uv` to be installed and initialized.

1. Install the Databricks CLI
```
brew install databricks
```
2. Authenticate to our `msk-mode-prod` workspace on MSK Databricks.  Authentication records are stored in `$HOME/.databrickscfg`
```
databricks auth login --host https://msk-mode-prod.cloud.databricks.com/
```
3. Check access by listing all of the catalogs available to us.
```
databricks catalogs list
```
4. If uv isn't already installed, install it with the command (see https://docs.astral.sh/uv/getting-started/installation/)
```
curl -LsSf https://astral.sh/uv/install.sh | sh
```
5.  Once uv is installed, initialize the project environment by executing
```
uv sync
```


Scripts
-------

#### databricks_tables.sh
This script lists catalogs, schemas, and tables, and can be used to write files with the tables' column names or their general metadata.


#### grep_id_columns.sh
This script searches .columns files created by databricks_tables.sh for column names that reveal patient IDs.  The results are written to the file 'id_columns.txt'.


