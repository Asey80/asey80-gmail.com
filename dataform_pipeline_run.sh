#!/usr/bin/env bash

_usage() {
cat <<EOF
Usage: dataform_pipeline_run.sh [OPTION] [ARGUMENT]...
Script compiles and runs dataform pipeline

Options:
  -o    List of outlet_ids. Default null
  -d    List of date_ids. Default null

Example:
  dataform_pipeline_run.sh -o 11,44 -d 2021-01-27,2021-01-30
EOF
}

function _check_args() {
  if [[ $OPTARG =~ ^-.*$ ]]; then
    echo "Invalid argument '$OPTARG' for option '$OPTION'."
    _usage
    exit 1
  fi
}

function escape_slashes {
    sed 's/\//\\\//g'
}

function change_line {
    local OLD_LINE_PATTERN=$1; shift
    local NEW_LINE=$1; shift
    local FILE=$1

    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    sed -i.old '/'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
#    mv "${FILE}.old" /tmp/
}
# Main
while getopts "o:d:" OPTION; do
  case $OPTION in
    o) _check_args
#      Replace line with "outlet_ids" in constants.js
      change_line "outlet_ids=" "const outlet_ids=[$OPTARG];" includes/constants.js
      ;;
    d) _check_args
#      Modify date_ids list to necessary format (using "''")
      DATE_IDS=$(sed -r "s/[0-9]{4}-[0-9]{2}-[0-9]{2}/\"\'&\'\"/g" <<< "$OPTARG")
#      Replace line with "snapshot_dates" in constants.js
      change_line "snapshot_dates=" "const snapshot_dates=["$DATE_IDS"];" includes/constants.js
      sed -i .old  "s|[0-9]{4}-[0-9]{2}-[0-9]{2}|\"\'&\'\"|g" includes/constants.js
      ;;
    *) _usage
      exit $OPTERR
      ;;
  esac
done

# Run dataform project
dataform run
echo -e "done."

# Restore variables of outlets and dates to default
echo "
Restoring variables of outlets and dates to default..."
change_line "outlet_ids=" "const outlet_ids=null;" includes/constants.js
change_line "snapshot_dates=" "const snapshot_dates=null;" includes/constants.js
echo "done.
"
echo -e "Script is completed!!!"