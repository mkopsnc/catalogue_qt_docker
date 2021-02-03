#!/bin/bash

for i in $(find $1 -name "*.tree"); do
  dir_name=`dirname $i`
  file_name=`basename $i .tree`
  if [[ $2 == 1 ]]; then
    echo '{ "occurrence":"1" }' > ${dir_name}/${file_name}.populate
  else
    echo '' > ${dir_name}/${file_name}.populate
  fi
done