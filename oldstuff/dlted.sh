#!/bin/bash

# Download data for each page
rm teds.txt
for i in $(seq 4 1 13);
do
  curl --globoff "https://www.ted.com/talks?language=en&page=${i}&sort=popular&topics[]=science" -o "teddata${i}"
done  


# Concatenate them
find . -name 'teddata*' | sort | xargs cat > teds.txt
rm teddata*

# Extract lines with speaker name
cat teds.txt | grep talk-link__speaker > tmp1

sed -e "s/^.*'>//g" -e 's/<\/h4>//g' tmp1 > tmp2