#!/bin/bash

# Extract the names column
cat people.csv | cut -d, -f1 > names.txt

# Replace spaces between first and last names by +
cat names.txt | sed -e 's/ /+/g' -e 's/$/   /g' > tmp.txt

# Convert to lower case
tr '[:upper:]' '[:lower:]' < tmp.txt > nameswithplus.txt
rm tmp.txt

# Fetch Google suggestions
# (note that %20 is added to ensure that space after last word)
rm googlesuggestions.txt
while read line; do
  curl -w "\n" -s "http://suggestqueries.google.com/complete/search?client=firefox&hl=en&q=${line}+%20" 
done < nameswithplus.txt > googlesuggestions.txt

# Search for "wife" in suggestions
# 0 = yes
rm wife.txt
while read line; do
  echo ${line} | grep -q wife ; echo $? 
done < googlesuggestions.txt > wife.txt

# Search for "husband"
# 0 = yes
rm husband.txt
while read line; do
  echo ${line} | grep -q husband ; echo $? 
done < googlesuggestions.txt > husband.txt

