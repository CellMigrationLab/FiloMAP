# FiloMAP

**This version of FiloMap is deprecated but archived here as it was used in the following publication:

Jacquemet G, Stubb A, Saup R, Miihkinen M, Kremneva E, Hamidi H, Ivaska J. Filopodome Mapping Identifies p130Cas as a Mechanosensitive Regulator of Filopodia Stability. Curr Biol. 2019 Jan 21;29(2):202-216.e7. doi: 10.1016/j.cub.2018.11.053. Epub 2019 Jan 10. PMID: 30639111; PMCID: PMC6345628.

This version of FiloMap contains the original ImageJ and R scripts used to map the localisation of proteins within filopodia and generate filopodia maps.
To map the localisation of each POI within filopodia, images were first processed in Fiji (script 1), and data were analysed using R (script 2 and 3).
Script 1: in Fiji, the brightness and contrast of each image were automatically adjusted using, as an upper maximum, the brightest cellular structure labelled in the field of view. The line intensity profiles (1-pixel width) were manually drawn from filopodium tip to base (defined by the intersection of the filopodium and the lamellipodium). All visible filopodia in each image were analysed and exported for further analysis (export was performed using the “Multi Plot” function). 
The line intensity profiles were then compiled and analysed in R (script 2). Each line intensity profile was binned into 40 bins (using the median value of pixels in each bin and the R function “tapply”). The map of each POI was created by averaging hundreds of binned intensity profiles (script 2). 
Script 3 allows the generation of the filopodia maps as heatmaps using R.

The length of each filopodium analysed can be directly extracted from the line intensity profiles created by script 1 (Fiji) using the R script: Extract_filopodia_length.
