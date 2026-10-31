#!/bin/bash
# set -x

die () { echo "FATAL: $*"; exit 1; }

CMD_LIST="list"
CMD_META="meta"
CMD_COLS="cols"

CATALOG=""
SCHEMA=""
TABLE=""

usage () {
    [[ -n $* ]] && echo "ERROR: $*"
    cat <<END
Usage: $0 <list | meta | cols> [--catalog <catalog>] [--schema <schema>]
Options:
  -s|--schema SCHEMA .... the schema to use
  -c|--catalog CATALOG .. the catalog to use
  -t|--table TABLE ...... consider only this table
  --dryrun .............. don't actually write any files
  -h|--help ............. print this summary

Commands:
  list .... list the tables in the specified catalog and schema (default)
  meta .... write a JSON file containg the full metadata for each table
  cols .... write a file for each table, listing its column names

END
    [[ -n $* ]] && exit 1
    exit 0
}

CMD="$CMD_LIST"
DRY_RUN=""

while [[ $# -gt 0 ]]; do
    ARG="$1"; shift
    case "$ARG" in
            list) CMD="$CMD_LIST";;
            meta) CMD="$CMD_META";;
            cols) CMD="$CMD_COLS";;
       -c|--cat*) CATALOG="${1?Expected a catalog name after $ARG}"; shift;;
       -s|--sch*) SCHEMA="${1?Expected a schema name after $ARG}"; shift;;
       -t|--tab*) TABLE="${1?Expected a table name after $ARG}"; shift;;
          --dry*) DRY_RUN="yes";;
       -h|--help) usage;;
              -*) usage "Unrecognized option '$ARG'";;
               *) usage "Unrecognized argument '$ARG'";;
    esac
done

# set -x

if [[ -n $TABLE ]]
then
    if echo "$TABLE" | grep '[.]' >& /dev/null
    then
        IFS="." read -ra PARTS <<< "$TABLE"
        [[ ${#PARTS[@]} == "3" ]] || die "table must be in form <catalog>.<schema>.<table>"
        CATALOG="${PARTS[0]}"
        SCHEMA="${PARTS[1]}"
        TABLE="${PARTS[2]}"
    elif [[ -z $CATALOG || -z $SCHEMA ]]; then
        die "catalog and schema were not specified"
    fi
fi

if [[ -n $SCHEMA ]]
then
    if echo "$SCHEMA" | grep '[.]' >& /dev/null
    then
        IFS="." read -ra PARTS <<< "$SCHEMA"
        [[ ${#PARTS[@]} == "2" ]] || die "schema must be in form <catalog>.<schema>"
        CATALOG="${PARTS[0]}"
        SCHEMA="${PARTS[1]}"
    fi
elif [[ -n $CATALOG ]]; then
    echo "Select a schema from this list:"
    databricks schemas list "$CATALOG" -o json | jq .[].name | sed 's!"!!g'
    exit 1
fi

if [[ -z $CATALOG ]]
then
    echo "Select a catalog from this list:"
    databricks catalogs list -o json | jq .[].name | sed 's!"!!g'
    exit 1
fi

process_table () {
    _table_path="${1?expected a table path to be specified}"

    if [[ $CMD = $CMD_META ]]
    then
        _outfile="${_table_path}.json"
        echo "$_outfile"
        if [[ -z $DRY_RUN ]]; then
            databricks tables get "$_table_path" > "$_outfile"
        fi
    elif [[ $CMD = $CMD_COLS ]]; then
        _outfile="${_table_path}.columns"
        echo "$_outfile"
        if [[ -z $DRY_RUN ]]; then
            databricks tables get "$_table_path" | jq .columns.[].name > "$_outfile"
        fi
    elif [[ $CMD = $CMD_LIST ]]; then
        echo "${_table_path}"
    else
        die "Unrecognized command '$CMD'"
    fi
    unset _table_path _outfile
}

if [[ -n $TABLE ]]
then
    process_table "$CATALOG.$SCHEMA.$TABLE"
    exit 0
fi

for _table_path in $(databricks tables list "$CATALOG" "$SCHEMA" -o json | jq .[].full_name | sed 's!"!!g')
do
    process_table "${_table_path}"
done



