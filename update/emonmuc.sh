#!/bin/bash
source config.ini

echo "-------------------------------------------------------------"
echo "Update EmonMUC"
echo "-------------------------------------------------------------"

if [ -d $emonmuc_dir ]; then
    sudo bash $emonmuc_dir/update.sh
else
    echo "Not found at $emonmuc_dir"
fi
