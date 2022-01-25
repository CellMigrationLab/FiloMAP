
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

# Multiple plot function

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space='Lab')  

map= data.matrix(Filopodia_map)
longData <- melt(map)
figure <- ggplot(longData, aes(x = Var1, y = Var2, fill = value)) + geom_tile()   +  coord_equal()    +   scale_fill_gradientn(colours = hm.palette(100), limits=c(0,Max_value), na.value="#9e0142") + ylab(NULL)   + theme_minimal()

#Plot all diagrams as figure
pdf(file=paste(path, "_Map.pdf"))
figure2 <- multiplot(figure, col = 1)

dev.off()

#clear everything
closeAllConnections()
rm(list=ls())
