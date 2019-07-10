# FiloMAP
ImageJ and R scripts used to map the localisation of proteins whithin filopodia and generate filopodia maps.
To map the localization of each POI within filopodia, images were first processed in Fiji (script 1) and data analyzed using R (script 2 and 3).
Script 1: in Fiji, the brightness and contrast of each image was automatically adjusted using, as an upper maximum, the brightest cellular structure labeled in the field of view. The line intensity profiles (1 pixel width) were manually drawn from filopodium tip to base (defined by the intersection of the filopodium and the lamellipodium). All visible filopodia in each images were analyzed and exported for further analysis (export was performed using the “Multi Plot” function). 
The line intensity profiles were then compiled and analyzed in R (script 2). To homogenize filopodia length, each line intensity profile was binned into 40 bins (using the median value of pixels in each bin and the R function “tapply”). The map of each POI was created by averaging hundreds of binned intensity profiles (script 2). 
Script 3 allow to generate the filopodia maps as heatmaps using R.

The length of each filopodia analyzed can be directly extracted from the line intensity profiles created by script 1 (using Fiji) using the R script : Extract_filopodia_length.
