import marimo

__generated_with = "0.22.0"
app = marimo.App(width="medium")


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    [Databricks SQL Connector for Python](https://docs.databricks.com/aws/en/dev-tools/python-sql-connector?language=SQL%C2%A0warehouse)
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Dependencies
    """)
    return


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    debug = False
    return (debug,)


@app.cell
def _(log):
    from pathlib import Path
    log(Path.cwd())
    return


@app.cell
def _():
    from dotenv import load_dotenv
    load_dotenv()
    return


@app.cell
def _(log):
    import os
    from databricks import sql

    log(f"DATABRICKS_SERVER_HOSTNAME = {os.getenv('DATABRICKS_SERVER_HOSTNAME')}")
    log(f"DATABRICKS_HTTP_PATH = {os.getenv('DATABRICKS_HTTP_PATH')}")
    log(f"DATABRICKS_TOKEN = {os.getenv('DATABRICKS_TOKEN')}")
    return os, sql


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Databricks
    """)
    return


@app.cell
def _(os, sql):
    connection= sql.connect(
        server_hostname = os.getenv("DATABRICKS_SERVER_HOSTNAME"),
        http_path       = os.getenv("DATABRICKS_HTTP_PATH"),
        access_token    = os.getenv("DATABRICKS_TOKEN")
    )
    return (connection,)


@app.cell
def _(connection):
    with connection.cursor() as _cursor:
        _cursor.execute("SELECT 1 + 1")
        _result = _cursor.fetchall()

        for _row in _result:
          print(_row)
    return


@app.cell
def _(connection):
    with connection.cursor() as _cursor:
        _cursor.execute("""
    SELECT * 
    FROM cdsi_prod.pathology_data_mining.copath_molecular_links_cleaned
    WHERE 
    block_id LIKE 'M%';
    """)
        _result = _cursor.fetchall()

        for _row in _result:
          print(_row)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ### Code
    """)
    return


@app.cell
def _(debug):
    def log(text: str) -> None:
        if debug:
            print(text)

    return (log,)


if __name__ == "__main__":
    app.run()
