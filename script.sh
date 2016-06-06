#!/bin/bash

# Extract the names column
cat $1.csv | cut -d, -f1 > $1_names.txt

# Replace spaces between first and last names by +, and remove quotes
cat $1_names.txt | sed -e 's/ /+/g' -e 's/$/   /g' -e 's/\"//g' > tmp.txt

# Convert to lower case
tr '[:upper:]' '[:lower:]' < tmp.txt > nameswithplus.txt

# Fetch Google suggestions
# (note that %20 is added to ensure that space after last word)
rm $1_googlesuggestions.txt
while read line; do
  curl -w "\n" -s "http://suggestqueries.google.com/complete/search?client=firefox&hl=en&q=${line}+%20" 
done < nameswithplus.txt > $1_googlesuggestions.txt

# Search for "wife" in suggestions
# 0 = yes
rm $1_wife.txt
while read line; do
  echo ${line} | grep -q wife ; echo $? 
done < $1_googlesuggestions.txt > $1_wife.txt

# Search for "husband"
# 0 = yes
rm $1_husband.txt
while read line; do
  echo ${line} | grep -q husband ; echo $? 
done < $1_googlesuggestions.txt > $1_husband.txt

# Clean
rm nameswithplus.txt
rm tmp.txt
