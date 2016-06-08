# GoogleSuggestions

## To do everything again:
type `./make.sh` in a terminal. 

*For more details on what is done,*  go read the report 
http://htmlpreview.github.io/?https://github.com/flodebarre/GoogleSuggestions/blob/master/report.html

## Contents:
- script.sh to fetch google suggestions
type ./script.sh typedata.csv (replacing typedata by actors/ted/aaas/tennis)
- report.Rmd to run the analysis and print the report.
- .csv datasets: lists of names
- make.sh to rerun the analysis. 

## Sources of the names:

### Tennis
- Women: http://www.wtatennis.com/singles-rankings
- Men: http://www.atpworldtour.com/en/rankings/singles

### Actors
http://www.vulture.com/2012/07/most-valuable-movie-stars.html

### Science
#### TED
Topic: Science, by: most viewed; first 3 pages
https://www.ted.com/talks?sort=popular&topics[]=science&language=en
(There are duplicates, they will be taken care of later)

#### AAAS
https://www.amacad.org/multimedia/pdfs/classlist.pdf
all in Class II: Biological Sciences (II:1, II:2, II:3, II:4, II:5).

### HHMI
https://www.hhmi.org/scientists/browse?kw=&sort_by=field_scientist_last_name&sort_order=ASC&items_per_page=100

## Acknowledgements
- Francois Bienvenu wrote a first version of the script fetching Google Suggestions in OCaml (available in the `oldstuff/` folder. He gave me the tip about the http://suggestqueries.google.com webpage.
- Nicolas Rode gave a few helpful tips for the analysis. 

All remaining errors are my fault.
 
