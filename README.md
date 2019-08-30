# MAGwash

Wash those MAGs

```
snakemake --use-conda
```

Then in R:

```R
library(alluvial)
library(dplyer)

# read in data
d <- read.table("protein_ox_tax/UBA7807_genomic.tsv", strings=FALSE, header=TRUE, sep="\t")
colnames(d) <- c("taxid","Superkingdom","kingdom","phylum","class","order","family","genus","species")

# set NA to "unknown"
d[is.na(d)] <- "unknown"
d[d==""] <- "unknown"

# set frequency
d$freq = rep(1,nrow(d))

# group by
d %>% group_by(Superkingdom,kingdom,phylum,class,order,family,genus,species) %>%  summarise(n = sum(freq)) -> dsum

# colour by kingdom
ifelse(dsum$Superkingdom == "Bacteria", 
	"orange", 
	ifelse(dsum$Superkingdom == "Eukaryota",
	"green",
	ifelse(dsum$Superkingdom == "Archaea",
	"maroon",
	"grey"
))) -> cols

# collapse small ribbons into "other"
dsum[dsum$n<50,c(2:8)] <- "other"

# plot
alluvial(dsum[,c(1,3:8)], freq=dsum$n, col=cols)

```
