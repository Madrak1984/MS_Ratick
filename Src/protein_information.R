#### command lines to add protein information to MS output file result
# done by Jonathan Seguin, group of Prof Schwaller, DBM & UKBB
# Fri Dec 22 11:35:27 2023

# set the environment -----------------------------------------------------

## load the libraries -----------------------------------------------------
library(writexl)

## custom function -----------------------------------------------------
source("Src/DE_functions.R")

## create the R object -----------------------------------------------------

# load protein information for mouse
mouse_prot <- getMouseGene(withProtein = T)

# load protein information for human
human_prot <- getHumanGene(withProtein = T)

# create the output directory folder
outDir <- create_dir("Output")


# update the input file -----------------------------------------------------

# read the file
pilot2 <- read.table(file = "Input/Pilot 2.txt", header = T, sep = "\t", 
                     skip = 3, check.names = F, quote = "", comment.char = "")

# check if the accession id is present in the database protein information
table(pilot2$`Accession Number` %in% mouse_prot$uniprotswissprot)
# FALSE  TRUE
#   134   867

# remove the (+1) to increase the number of recognize accession id
pilot2$`Accession Number` = sapply(pilot2$`Accession Number`, function(x)strsplit(x, split = " \\(")[[1]][1])

# check if the accession id is present in the database protein information
table(pilot2$`Accession Number` %in% mouse_prot$uniprotswissprot)
# FALSE  TRUE
#  115   886 

# remove the long protein name
pilot2$`Accession Number`[grep(pattern = "\\|", pilot2$`Accession Number`)] = sapply(pilot2$`Accession Number`[grep(pattern = "\\|", pilot2$`Accession Number`)] , function(x)strsplit(x, split = "\\|")[[1]][2])

# check if the accession id is present in the database protein information
table(pilot2$`Accession Number` %in% mouse_prot$uniprotswissprot)
# FALSE  TRUE
#  107   894 

# add rownames
rownames(pilot2) = pilot2$`#`

# indicate the order of proteins
pilot2$order = 1:nrow(pilot2)

# add the mouse gene name
update_table <- merge(x = pilot2, y = human_prot, by.x = "Accession Number", by.y = "uniprotswissprot", all.x =T, sort = F)

# add the human gene name
update_table =  merge(x = update_table, y = mouse_prot, by.x = "Accession Number", by.y = "uniprotswissprot", all.x =T, sort = F, suffixes = c("_human","_mouse"))

# reorder the table
update_table <- update_table %>% arrange(order)

# export the table in a excel file
write_xlsx(x = update_table, path = file.path(outDir, "pilot2_GeneName.xlsx"))


