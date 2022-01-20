
#parameter
Max_value <- 30000


# Choose file location
path <- file.choose()
DIR  <- dirname(path)

Filopodia_map <- read_csv(path, show_col_types = FALSE)


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

hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space='Lab')  

map= data.matrix(Filopodia_map)
longData <- melt(map)

#Plot all diagrams as figure
pdf(file=paste(DIR, "Map.pdf"))
ggplot(longData, aes(x = Var1, y = Var2, fill = value)) + geom_tile()   +  coord_equal()    +   scale_fill_gradientn(colours = hm.palette(100), limits=c(0,Max_value), na.value="#9e0142") + ylab(NULL)   + theme_minimal()

