#!/bin/bash

#===========================================================================#
# This script fetches google suggestions for the collected lists of names   #
# and runs the analysis.                                                    #
# It does not collect names again -- that step was done semi-manually.      #
#===========================================================================#

# Fetch Google suggestions for all datasets
#  Note: the results may depend on your location
#        I ran the script from France.

echo " ----  Fetching Google suggestions ---- "

./script.sh actors
./script.sh tennis
./script.sh aaas
./script.sh hhmi
./script.sh ted

echo " ----  Running analyses and compiling report ---- "

# Run the analysis and compile the report
Rscript -e "rmarkdown::render('report.Rmd')"

# Open the report
open report.html

# Update version 
git add .
git commit -m "Reran everything"
git push origin master
