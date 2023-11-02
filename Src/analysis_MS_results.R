#### command lines to analyze the result of MS done by Rathick Sivalingam
# done by Jonathan Seguin, group of Prof Schwaller, DBM & UKBB
# Thu Nov  2 16:38:45 2023

# set the environment -----------------------------------------------------

## load the libraries -----------------------------------------------------
library("R.utils")
library(readxl)
library(writexl)


## custom function -----------------------------------------------------
source("Src/DE_functions.R")

## create the R object -----------------------------------------------------
mouse_prot <- getMouseGene(withProtein = T)


# load the files -----------------------------------------------------

## parse the RBP file -----------------------------------------------------

# read the list of RBP
list_RBP <- read.table(file = "Doc/list_RBP_MLL-AF9_RBPmap.txt", header = F, sep = ":")

# remove the Hs/Mm 
list_RBP$V3 <- gsub(pattern = "\\(Hs/Mm\\)", replacement = "", list_RBP$V3)
list_RBP$V3 <- gsub(pattern = "\\ ", replacement = "", list_RBP$V3)

# change the colnames
colnames(list_RBP) <- c("Start", "Type", "Symbol")

# add the end line for the subtext
list_RBP$End = 0
list_RBP$End = c(list_RBP$Start[-1] -1, countLines(file = "Doc/RBP_MLL-AF9_RBPmap.txt")[1])


## parse the excel result file -----------------------------------------------------

# read the MS result
MS_result <- read_xlsx(path = "Doc/Samples_P640_PILOT_RS_Frozen.xlsx", skip = 3)

# merge with the protein informations
MS_result <- merge(x = MS_result, y = mouse_prot, by.x = "Accession Number",
                   by.y = "uniprotswissprot")


## compare the results -----------------------------------------------------

# add if the gene is present in the MS result
list_RBP$MS_result <- list_RBP$Symbol %in% toupper(MS_result$external_gene_name)

# select the genes only in the MS result
list_RBP_sel <- list_RBP[list_RBP$MS_result, ]


# create the loop to read the files
for(id in 1:nrow(list_RBP_sel)){
  
  # extract the lines
  lines <- read_lines(file = "Doc/RBP_MLL-AF9_RBPmap.txt", skip = list_RBP_sel$Start[id]-1, n_max = list_RBP_sel$End[id] - (list_RBP_sel$Start[id]-1))

  # write the text in one file
  write.table(lines, file = "Doc/RBP_MLL-AF9_RBPmap_MS_result.txt", quote = F, row.names = F, col.names = F, append = T)

}

# save the list_RBP in one excel file
write_xlsx(list_RBP, path = "Doc/list_RBP_MLL-AF9_RBPmap_MS_result.xlsx")
