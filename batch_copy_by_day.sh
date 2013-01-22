#! /usr/bin/env bash

FROM_DIR="$1"
TO_DIR="$2"

INTERVAL=10

ALL_DAYS=`/bin/ls $FROM_DIR | cut -b 14-21 | sort -u`


wait_until_all_existing_files_are_imported() {
  while [ "$(any_files_still_not_imported)" == 'true' ]; do
    sleep $INTERVAL
  done
}

any_files_still_not_imported() {
  local total_data_files_number=$(find $TO_DIR -name "*.csv" | egrep -v '\.errors\.csv' | wc -l)
  local total_imported_files_number=$(find $TO_DIR -name "*.csv" | egrep '\.errors\.csv' | wc -l)

  if [ -z "${total_data_files_number}" ]; then
    echo 'false'
  fi

  if [ "x${total_data_files_number}" != "x${total_imported_files_number}" ]; then
    echo 'true'
  else
    echo 'false'
  fi
}

file_size() {
  local filename=$1
  echo $(du -sh $filename | awk '{print $1}')
}

copy_single_file() {
  local filename="$1"
  local size=$(file_size $file)

  printf '# Copyed %6s %s\n' $size $filename
  cp $filename $TO_DIR
}

copy_files() {
  local files=$(find ${FROM_DIR} -name "*${1}*.csv")

  echo "####################### `date` #######################"

  for file in $files; do
    copy_single_file $file
  done
}

main() {
  for day in $ALL_DAYS; do
    wait_until_all_existing_files_are_imported
    copy_files ${day}
  done
}

main

