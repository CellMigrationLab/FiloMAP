        
        
        
        #Open libraries
        library(readr)
        library(ggplot2)
        library(RColorBrewer) 
        library(reshape2) 
        library(gridExtra)
        library(tools)
        library(plyr)
        library(matrixStats)
        library(tidyverse)
        
        # FIRST SPLIT ALL FILES INTO SINGLE FILOPODIA
        
        # Choose file location
        path <- file.choose()
        DIR  <- dirname(path)
        
        
        fileNames <- dir(DIR, full.names=TRUE, pattern =".csv")
        
        results <- data.frame(nrow = length(fileNames), ncol = 2)
        
        colnames(results)  <- c("X","Y")   # Rename the result table
        rownames(results) <- c(fileName)
        
         
        for (fileName in fileNames) {
         
         p = file_path_sans_ext(basename(fileName))
         Values <- read_csv(fileName) 
         
         Values2 <- na.omit(Values)
         
         colnames(Values2) <- c("X","Y")   # Rename the result table
         
         results[fileName, ] <-tail(Values2, n=1)
         
         
        }
        
        write.csv(results, file=paste(DIR, "_FilopodiaLength.csv", sep=""), row.names = F)
         
         
        
