## calgary_net.R
## Ford Fishman
## 10/1/21

library(lpbrim)
library(vegan)

inf <- read.csv("data/20210929_InfectionMatrix.csv") #infection matrix
qual <- read.csv("data/Metadata_QuantFitness_scaled2.csv") # quality scores

# relabel column
colnames(inf)[1] <- "strain"

# subset to strains both datasets have in common
inf1 <- subset(inf, strain %in% qual$strain)
qual1 <- subset(qual, strain %in% inf$strain)

# alphabetize to ensure the same order
inf1 <- inf1[order(inf1$strain),]
qual1 <- qual1[order(qual1$strain),]

reg_df <- cbind(inf1, subset(qual1, select=c(partner_qual, scaled, qual_scale))) # create a new df for regressions
reg_df$partner_qual <- trimws(reg_df$partner_qual) # remove whitespace
reg_df$qual_cat <- ifelse(reg_df$partner_qual=="High",1,0) # turn quality factor into quantitative factor

# create a factor for total resistance
reg_df$sum_inf <- reg_df$P9VF + reg_df$P10VF + reg_df$P11VF + reg_df$B1VFA + reg_df$L338C + reg_df$RL38Ji + reg_df$RL2.RES

# some models
summary(lm(data = reg_df, formula = scaled ~ P9VF + P10VF + P11VF + B1VFA + L338C + RL38Ji + RL2.RES))

summary(lm(data = reg_df, formula = partner_qual ~ sum_inf))


## network statistics

B <- as.matrix( inf1[,2:ncol(inf1)] )
B[B<1] <- 0 # convert 0.5 to 0, partial lysis treated as no lysis

# nestedness
nodf <- nestednodf(B)

# modularity

B <- B[rowSums(B)>0, colSums(B)>0] # remove columns and rows with

Q <- ''
if (!is.null(dim(B)) ){
  Q <- findModules(B, sparse=FALSE)$Q

}

cat(nodf$statistic['NODF'],Q)
