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

echo "      actors..."
./script.sh actors
echo "done. tennis..."
./script.sh tennis
echo "done. aaas..."
./script.sh aaas
echo "done. hhmi..."
./script.sh hhmi
echo "done... ted..."
./script.sh ted
echo "done. \n"

echo " ----  Running analyses and compiling report ---- "

# Run the analysis and compile the report
Rscript -e "rmarkdown::render('report.Rmd')"

# Open the report
open report.html

# Update version 
git add .
git commit -m "Reran everything"
git push origin master
