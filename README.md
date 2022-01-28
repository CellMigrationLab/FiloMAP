# FiloMAP
Updated ImageJ and R scripts used to map the localisation of proteins within filopodia and generate filopodia maps.

To map the localisation of each POI within filopodia, images were first processed in Fiji and data analysed using R.

FILOMAP_Fiji.ijm” script: in Fiji, the brightness and contrast of each image was automatically adjusted using, as an upper maximum, the brightest cellular structure labelled in the field of view. The line intensity profiles (1-pixel width) were manually drawn from filopodium tip to base (defined by the intersection of the filopodium and the lamellipodium). All visible filopodia in each image were analysed and exported for further analysis (export was performed using the “Multi Plot” function). 

The line intensity profiles were compiled and analysed in R (FILOMAP_R_Script_1.R). Each line intensity profile was binned into 40 bins (using the median value of pixels in each bin and the R function “tapply”). The map of each POI was created by averaging hundreds of binned intensity profiles (FILOMAP_R_Script_1.R). 

FILOMAP_R_Script_2.R allows the generation of the filopodia maps as heatmaps using R.



