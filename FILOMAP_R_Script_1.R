
#Settings
number_of_bins <- 40 # change the number of bin per filopodia
row_ID <- TRUE # Do your input files have a row ID? If unsure check your input files


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

# create directories
dir.create(file.path(DIR, "single_in"))
DIROUT_single_IN <- file.path(DIR, "single_in", "") 
dir.create(file.path(DIR, "single_out"))
DIROUT_single_OUT <- file.path(DIR, "single_out", "") 
dir.create(file.path(DIR, "merge"))
DIROUT_merge <- file.path(DIR, "merge", "") 
dir.create(file.path(DIR, "temp"))
DIROUT_temp <- file.path(DIR, "temp", "")

fileNames <- dir(DIR, full.names=TRUE, pattern =".csv")

for (fileName in fileNames) {
  p = file_path_sans_ext(basename(fileName))
  Values <- read_csv(fileName)
  if (row_ID == TRUE) {
  names(Values)[1] <- 'ID'
  Values$ID <- NULL
  names(Values)[names(Values) == 'X1_1'] <- 'X1'}
  Nbvalues = ncol(Values)/2
  
  if (Nbvalues == 1) {
    names(Values)[names(Values) == 'X'] <- 'X0'
    names(Values)[names(Values) == 'Y'] <- 'Y0'
    }

  if (!as.integer(Nbvalues) == Nbvalues) {stop(fileName, " has an unexpected number of column, please check the file")}
  
  dp <- tapply(as.list(Values), gl(ncol(Values)/2, 2), as.data.frame)
  i =1
  repeat {
    write.csv(dp[[i]], file=file.path(DIROUT_single_IN, paste(p,"_", i, ".csv", sep="")), row.names = F)
    i = i +1
    if (i == Nbvalues) {
      break
    }
    if (i > Nbvalues) {
      break
    }
  }
  
}

  #multmerge function
  multmerge = function(mypath){
  filenames=list.files(path=mypath, full.names=TRUE)
  datalist = lapply(filenames, function(x){read_csv(file=x, show_col_types = FALSE)})
  Reduce(function(x,y) {join(x,y, by="ID")}, datalist)}
  
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
  
#Here we load each filopodia one by one
fileNames <- dir(DIROUT_single_IN, full.names=TRUE, pattern =".csv")

#Define protein name
protein <- basename(DIR)

#create somewhere to save the filopodia length

FilopodiaLength <- data.frame(nrow = length(fileNames), ncol = 2)

colnames(FilopodiaLength)  <- c("X","Y")   # Rename the result table
rownames(FilopodiaLength) <- c(fileName)


# Loop to analyse the whole folder

for (fileName in fileNames) {
#Define file name without extension

if (!as.integer(Nbvalues) == Nbvalues) {stop(fileName, " has an unexpected number of column, please check the file")}
  
  
p = file_path_sans_ext(basename(fileName))

# read data:
singleValues <- read_csv(fileName, show_col_types = FALSE)

#For filopodia length
singleValues2 <- na.omit(singleValues)
colnames(singleValues2) <- c("X","Y")   # Rename the result table
FilopodiaLength[fileName, ] <-tail(singleValues2, n=1)

colnames(singleValues) <- c("X","Y")   # Rename the result table
  
  # Bin the data into 40
  output = tapply(singleValues[["Y"]], cut(singleValues[["X"]], number_of_bins), median)
 
  # Transform the binned data into a table
  Result <- as.data.frame.table(output)
  
 
  Result <- cbind(Result, "ID"=1:nrow(Result))          # Add a extra row to the table
  colnames(Result) <- c("Distance","Intensity", "ID")   # Rename the result table
  Result <- Result[c("ID", "Distance", "Intensity")]    # reorganize the column name

  write.csv(Result, file=file.path(DIROUT_single_OUT, paste(p, "_out.csv", sep="")), row.names = F)
 
  #Create a new table without distance
  temp_res = Result
  temp_res$Distance <- NULL
  colnames(temp_res) <- c("ID", p)                      # Rename the result table
  
  write.csv(temp_res, file=file.path(DIROUT_temp, paste(p, "_temp.csv", sep="")), row.names = F)
 
  
  #Plot Original data
  raw_data  <-  ggplot(data=singleValues, aes(x=X, y=Y, group=1)) +    geom_line()+    geom_point() + ggtitle("Raw data") +  labs(x="Filopodia Length",y="Intensity")
  
  #Plot Binned data
   binned_data <- barplot(output, main=p)
  
  #Plot Transform Binned data
  tfrm_data <- ggplot(data=Result, aes(x=ID, y=Intensity, group=1)) +    geom_line()+    geom_point() + ggtitle("Binned data") +  labs(x="Filopodia Length",y="Intensity")
  
  #Heatmap version of the binned data
 
  hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space='Lab')  
  heatmap  <- ggplot(Result, aes(x = ID, y = 1, fill = Intensity))   + geom_tile()   +  coord_equal()    +   scale_fill_gradientn(colours = hm.palette(100))    + ylab(NULL)   + theme_minimal() + theme(axis.text.y = element_blank())

  pdf(file=file.path(DIROUT_single_OUT, paste(p, "_out.pdf", sep="")))
  Figure  <- multiplot(raw_data, tfrm_data, heatmap, col = 1)
  dev.off()
    } 

# end of loop

# Merge all the data ##########################
mymergeddata = multmerge(DIROUT_temp)


write.csv(mymergeddata, file=file.path(DIROUT_merge, paste(protein, "merge.csv", sep="")), row.names = F) # save the table full of merge data

FilopodiaLength$Y <- NULL
FilopodiaLength <- FilopodiaLength[-c(1), ]
names(FilopodiaLength)[1] <- 'Filopodia_Length'

write.csv(FilopodiaLength, file=file.path(DIROUT_merge, paste(protein, "_FilopodiaLength.csv", sep="")), row.names = F) # save the filopodia length


# Calculate Mean, SD, count and SEM
Data_mean <- data.frame(ID=mymergeddata[,1], Means=rowMeans(mymergeddata[,-1],  na.rm = TRUE))
Data_mean <- transform(Data_mean, SD=rowSds(as.matrix(mymergeddata[,-1]), na.rm=TRUE))
Data_mean <- transform(Data_mean, Count=ncol(mymergeddata[,-1]))
Data_mean <- transform(Data_mean, SEM= SD/sqrt(Count))

write.csv(Data_mean, file=file.path(DIROUT_merge, paste(protein, "summary.csv", sep="")), row.names = F) # save the summary table 

#Plot the summary data
pd <- position_dodge(0.1) # move them .05 to the left and right
Mean_plot <- ggplot(Data_mean, aes(x= ID, y=Means)) + geom_errorbar(aes(ymin=Means-SEM, ymax=Means+SEM), colour="black", width=.1, position=pd) +  geom_line(position=pd) +  geom_point(position=pd, size=3)

#plot the summary data as a heat map
heatmap2  <- ggplot(Data_mean, aes(x = ID, y = 1, fill = Means))   + geom_tile()   +  coord_equal()    +   scale_fill_gradientn(colours = hm.palette(100))    + ylab(NULL)   + theme_minimal() + theme(axis.text.y = element_blank())

#plot all the individual filopodia as a heat maps
map= data.matrix(mymergeddata)
longData <- melt(map)
mergeplot <- ggplot(longData, aes(x = Var1, y = Var2, fill = value)) + geom_tile()   +  coord_equal()    +   scale_fill_gradientn(colours = hm.palette(100)) + ylab(NULL)   + theme(axis.line=element_blank(),axis.text.x=element_blank(), axis.text.y=element_blank(), axis.ticks=element_blank(), axis.title.x=element_blank(), axis.title.y=element_blank(),legend.position="none", panel.background=element_blank(), panel.border=element_blank(), panel.grid.major=element_blank(), panel.grid.minor=element_blank(),plot.background=element_blank()) 

#Plot all diagrams as figure

pdf(file=file.path(DIROUT_merge, paste(protein, "_summary.pdf", sep="")))
Figure2  <- multiplot(Mean_plot, heatmap2, mergeplot, col = 1)

if (!as.integer(Nbvalues) == Nbvalues) {stop(fileName, " has an unexpected number of column, please check the file")}


dev.off()

#clear everything
closeAllConnections()
rm(list=ls())





