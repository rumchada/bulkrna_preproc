bam_to_counts <- function(output) {

  require(tidyverse)
  require(dplyr)
  require(vroom)

  #grab the files from the input
  files <- list.files(
    path = ".",
    pattern = "\\.tsv$",
    recursive = TRUE,
    full.names = TRUE
  )
  message(files, "search found")

  print(files)

  counts <- list()
  #for i in range(len(files))
  for (i in seq_along(files)){
    #read those files into R
    counts[[i]] <- read.delim(
      files[i],
      # skip comment characters
      comment.char = "#",
      # no check name
      check.names = FALSE
    ) %>%
      # select for only the gene_id and the bam column
      select(Geneid, matches("\\.bam$")) %>%
      # convert the column to rownames
      column_to_rownames("Geneid")
  }
  #creat names for the list
  #substitute for the final counts name with base name of the file
  names(counts) <- sub( "_counts\\.tsv$", "", basename(files) )

  #column bind the count columns
  count_matrix <- do.call(cbind, counts)

  #write out the table
  write.table(count_matrix, file = output, sep = "\t", quote = FALSE, col.names = NA)

  return(count_matrix)

}

#grabbing arguments from the outside
# Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)

output_file <- args[1]

bam_to_counts(output_file)
