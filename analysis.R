# Clean the memory
rm(list=ls())

# For the report
#install.packages("rmarkdown")
library(rmarkdown)


#===============================#
# OBTAIN AND COMBINE DATA		#
#===============================#

# Combine data for a given "category"
getdata <- function(catname){
	tmp <- read.csv(paste(catname, ".csv", sep=""), header=FALSE, stringsAsFactors=FALSE)
	# Find duplicates
	dupl <- duplicated(tmp$V1)

	wife <- scan(paste(catname, "_wife.txt", sep=""))
	husband <- scan(paste(catname, "_husband.txt", sep=""))
	n <- length(wife) - sum(dupl)
	
	# Combine data, removing duplicates
	t1 <- cbind(tmp[!dupl,], wife=1-wife[!dupl], husband=1-husband[!dupl])
	t2 <- cbind(t1, wh=((t1$wife==1)|(t1$husband==1)), sex=1*(t1[,2]=="F")) # F=1, M=0
	names(t2)[1:3] <- c("name", "MF", "cat")
	return(t2)
}

# Do it for all our datasets
t.aaas <- getdata("aaas")
t.ted <- getdata("ted")
t.tennis <- getdata("tennis")
t.actors <- getdata("actors")
t.hhmi <- getdata("hhmi")

# Now we want to combine the Science data (ted, hhmi, aaas)
 # There are people who belong to different categories: we need to merge them
 # So first, find them
  tmpTA <- rbind(t.ted, t.aaas) # Combine TED and AAAS datasets
  duTA <- duplicated(tmpTA[, 1]) # Find replicated names
  namesTA <- tmpTA[duTA, 1] # Get the corresponding names
  print(namesTA) # Print replicates
  tmp <- tmpTA[!duTA,] # Remove replicates

  tmpTH <- rbind(tmp, t.hhmi) # Add HHMI data
  duTH <- duplicated(tmpTH$name) # Find replicated names
  namesTH <- tmpTH[duTH, 1] # Get the corresponding names 
  print(namesTH) # Print replicates
  tmp <- tmpTH[!duTH,] # Remove replicates

 # Now we need to add the removed info again!
  t.science <- data.frame(cbind(tmp[, c("name", "sex")], "science", tmp[, c("wife", "husband", "wh")], 1*(tmp[3]=="AAAS"), 1*(tmp[3]=="HHMI"), 1*(tmp[3]=="TED")))
  names(t.science) <- c("name", "sex", "cat", "wife", "husband", "wh", "AAAS", "HHMI", "TED")
  # Add removed AAAS data
  for (dTA in namesTA){
	t.science[t.science$name==dTA, "AAAS"] <- 1
  }
# Add removed HHMI data
  for (dTH in namesTH){
	t.science[t.science$name==dTH, "HHMI"] <- 1
  }

manualcontrol <- FALSE
if(manualcontrol){
	# Manual control of remaining potential duplicates
	library(stringr)
	# Extract last word in name (mostly last name)
	nm <- unname(vapply(t.science$name, function(l) word(l, -1), FUN.VALUE="c(1)"))
	# Sort by alphabetical order
	onm <- nm[order(nm)]
	# Sort the entire table by alphabetical order
	temp <- t.science[order(nm),]
	# Find duplicates in last names (all values, hence the | and fromLast) and print them
	temp[duplicated(onm) | duplicated(onm, fromLast=TRUE),]
	# Then inspect the table and potentially correct the files if typoes
	# But this is not necessary anymore since it's already been done.
}

#===============================#
# STATS AND OTHER CALCULATIONS  #
#===============================#

# Count the number of F/M, wife+husband
countsuggestions <- function(cat){
	tab <- get(paste("t.", cat, sep=""))
	nF <- sum(tab$sex==1)
	nM <- sum(tab$sex==0)
	nFwh <- sum(tab$sex==1 & tab$wh==1)
	nMwh <- sum(tab$sex==0 & tab$wh==1)
	out <- c(nF=nF, nM=nM, nFwh=nFwh, nMwh=nMwh, pFwh=nFwh/nF, pMwh=nMwh/nM)
}

cats <- list("actors", "tennis", "science")
cts <- t(sapply(cats, countsuggestions))
x <- data.frame(cts)
xx <- cbind(data.frame(cat=unlist(cats)), x)
names(xx) <- c("cat", dimnames(cts)[[2]])
xx

# STATS...
# ANOVAS on the data
summary(aov(formula = wh ~ sex, data=t.tennis))
summary(aov(formula = wh ~ sex, data=t.actors))
summary(aov(formula = wh ~ sex, data=t.science))
summary(aov(formula = wh ~ sex, data=t.science[t.science$HHMI==1,]))

# For the science data, we want to compare more precisely the effect of fame, measured by "TED"
summary(glm(formula = wh ~ sex*TED, data=t.science, family = binomial))


summary(glm(formula = wh ~ sex+TED, data=t.science, family = binomial))
summary(glm(formula = wh ~ sex*TED, data=t.science[t.science$HHMI==1,], family = binomial))
summary(glm(formula = wh ~ sex + TED + sex*TED, data=t.science[t.science$HHMI==1,], family = binomial))

st <- t.science[t.science$HHMI==1,]
test <- tapply(st$wh, list(st$sex, st$TED), mean)
tapply(st$wh, list(st$sex, st$TED), length)

# PLOTS
colM <- rgb(0, 150, 150, 100, maxColorValue = 255)
colF <- rgb(249, 80, 0, maxColorValue = 255)

cols <- c("sex", "wh", "cat")
#t.all <- rbind(t.tennis[, cols], t.actors[, cols], t.science[, cols])
#counts <- table(t.all$wh, t.all$cat)
par(las=1)
barplot(t(as.matrix(xx[, c("pMwh", "pFwh")])), #
        beside=TRUE, col=c(colM, colF), names.arg=as.character(xx$cat), ylim=c(0,1), main="Proportion of individuals for whom \n'wife' or 'husband' appear as suggestion in a Google search", cex.main=0.85)


dissectscience <- tapply(t.science$wh, list(TED=t.science$TED, sex=t.science$sex), sum)
dissectscience <- dissectscience / matrix(rep(c(xx[xx$cat=="science", "nM"], xx[xx$cat=="science", "nF"]), 2), byrow=TRUE, ncol=2)
dmod <- cbind(c(dissectscience[,1], 0, 0), c(0, 0, dissectscience[,2])) # Trick to make R believe that there are four categories, then we can tune the colors as we wish
barplot(dmod, beside=FALSE, col=matrix(c(colM, colM, colF, colF), ncol=2), names.arg=c("Men", "Women"))
barplot(dmod, beside=FALSE, col='black', density=matrix(c(4, 0, 4, 0), ncol=2), add=TRUE, border=NA)

# plotfracs <- function(cat){
	# lin <- xx[xx$cat==cat,]
	# print(lin)
	# dx <- 0.15
	# xpos <- c(1-dx, 1+dx, 2-dx, 2+dx)
	# ypos <- with(lin, c(nMh/nM, nMw/nM, nFh/nF, nFw/nF))
	# plot(xpos, ypos, ylim=c(0,1), col=c(colM, colM, colF, colF), type="h", pch=15, lwd=5, axes = FALSE, ylab="Proportion", xlab="")
	# lines(xpos, 0*xpos)
	# axis(2, las=1)
	# axis(1, at=xpos, labels=c("h", "w", "h", "w"), lwd=0, line=-1)
	# axis(1, at=c(1, 2), labels=c("M", "F"), line=0.5, tick=FALSE)
	# title(cat)
# }

# plotfracs("tennis")
# plotfracs("aaas")
# plotfracs("hhmi")
# plotfracs("ted")
# plotfracs("actors")


