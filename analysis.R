# Combine data for a given "category"
getdata <- function(catname){
	tmp <- read.csv(paste(catname, ".csv", sep=""), header=FALSE)
	# Find duplicates
	dupl <- duplicated(tmp$V1)

	wife <- scan(paste(catname, "_wife.txt", sep=""))
	husband <- scan(paste(catname, "_husband.txt", sep=""))
	n <- length(wife) - sum(dupl)
	
	# Combine data, removing duplicates
	t2 <- cbind(tmp[!dupl,], wife=1-wife[!dupl], husband=1-husband[!dupl], cat=rep(catname, n))
	return(t2)
}

t.aaas <- getdata("aaas")
t.ted <- getdata("ted")
t.tennis <- getdata("tennis")
t.actors <- getdata("actors")
t.hhmi <- getdata("hhmi")

# Compute number of F, M, F husband, ...
countsuggestions <- function(cat){
	tab <- get(paste("t.", cat, sep=""))
	nF <- sum(tab$V2=="F")
	nM <- sum(tab$V2=="M")
	nFw <- sum(tab$V2=="F" & tab$wife==1)
	nMw <- sum(tab$V2=="M" & tab$wife==1)
	nFh <- sum(tab$V2=="F" & tab$husband==1)
	nMh <- sum(tab$V2=="M" & tab$husband==1)
	out <- c(nF=nF, nM=nM, nFw=nFw, nMw=nMw, nFh=nFh, nMh=nMh)
}

cats <- list("actors", "tennis", "ted", "aaas", "hhmi")
cts <- t(sapply(cats, countsuggestions))
x <- data.frame(cts)
xx <- cbind(data.frame(cat=unlist(cats)), x)
names(xx) <- c("cat", dimnames(cts)[[2]])
xx

colM <- rgb(0, 150, 150, maxColorValue = 255)
colF <- rgb(249, 113, 0, maxColorValue = 255)
plotfracs <- function(cat){
	lin <- xx[xx$cat==cat,]
	print(lin)
	dx <- 0.15
	xpos <- c(1-dx, 1+dx, 2-dx, 2+dx)
	ypos <- with(lin, c(nMh/nM, nMw/nM, nFh/nF, nFw/nF))
	plot(xpos, ypos, ylim=c(0,1), col=c(colM, colM, colF, colF), type="h", pch=15, lwd=5, axes = FALSE, ylab="Proportion", xlab="")
	lines(xpos, 0*xpos)
	axis(2, las=1)
	axis(1, at=xpos, labels=c("h", "w", "h", "w"), lwd=0, line=-1)
	axis(1, at=c(1, 2), labels=c("M", "F"), line=0.5, tick=FALSE)
	title(cat)
}
plotfracs("tennis")
plotfracs("aaas")
plotfracs("hhmi")
plotfracs("ted")
plotfracs("actors")


