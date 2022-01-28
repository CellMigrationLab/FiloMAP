

		requires("1.51a");																			// To maintain general compatibility requirements (i.e. presence of CLAHE)
		current_version_script = "v1.1";															// The version number is saved in the log of the expriment
		number_of_tif = 0;																			// Initialization of file counter
		file_name_index = 0;																		// Initialization of index for storage

	
	// Directory structure
	
	source_directory = getDirectory("Choose the directory to analyze");							// Source data loading
	results_directory = getDirectory("Choose the result directory ");							// Path for the results and various outputs
	LineProf_results_directory = results_directory+"Line Profiles"+File.separator;					// Assemble string for temporary folder
	File.makeDirectory(LineProf_results_directory);
	temp_results_directory = results_directory+"temp"+File.separator;					// Assemble string for temporary folder
	File.makeDirectory(temp_results_directory);	
	
	// Create temporary directory within the results location
	Contrast_adjusted = results_directory+"Projection to analyse contrast adjusted"+File.separator;
	File.makeDirectory(Contrast_adjusted);	
	// File listing and counting the number of compatible files available

	all_files_list = getFileList(source_directory);															// Create an array with the name of all the elements in the folder
	number_files = lengthOf(all_files_list);																// Count the total number of elements in the source folder
	for (i=0; i<number_files; i++) {																		// |
	if (endsWith(all_files_list[i], ".dv") || endsWith(all_files_list[i], ".tif")) {						// |
		number_of_tif = number_of_tif + 1;																	// |— Count the number of TIFF/TIF files
	}																										// |
}																											// |
	if (number_of_tif == 0) {																				//  ||
	exit("Duh! This folder doesn't contain any compatible files!");											//  ||— Clean exit if no compatible file present in the location
}																											//  ||

// Creating array for full and extensionless filenames
	
	file_shortname=newArray(number_of_tif);																	// Array allocation
	file_fullname=newArray(number_of_tif);																	// Array allocation
	for (i=0; i<number_files; i++) {																		// 
		length_name=lengthOf(all_files_list[i]);															// 
	if (endsWith(all_files_list[i], ".dv")) {																// |
		file_fullname[file_name_index]=all_files_list[i];													// |
		file_shortname[file_name_index]=substring(all_files_list[i],0,length_name-5);						// |— Storage of filename for TIFF file
		file_name_index = file_name_index + 1;																// |
		}																									// |
	if (endsWith(all_files_list[i], ".tif")) {																//  ||
		file_fullname[file_name_index]=all_files_list[i];													//  ||
		file_shortname[file_name_index]=substring(all_files_list[i],0,length_name-4);						//  ||— Storage of filename for TIF file
		file_name_index = file_name_index + 1;																//  ||
	}																										//  ||
}																											// 

	// Main analysis loop, 1 iteration per tif/tiff file
	

	for (p=0; p<number_of_tif; p++) {																		// Beginning of main analysis loop
	showProgress(p+1, number_of_tif);																		// Update progress bar within ImageJ status bar
	open(source_directory + file_fullname[p]);																// Load the image rank p
	resetMinAndMax();																						// Reset the intensity scale (to make predicatable results in case autoscale is default)
	run("Grays");
	rename("image");
	//run("Stack to Images");
	run("Split Channels");
	selectWindow("C1-image"); rename("image-0001");
	selectWindow("C2-image"); rename("image-0002");
	selectWindow("C3-image"); rename("image-0003");
	
	setTool("rectangular");	
	run("Brightness/Contrast...");		
	waitForUser("Adjust contrast.\n Then click Ok");												// Dialog box for user to choose the cell to analyse
	selectWindow("image-0001"); run("16-bit");
	selectWindow("image-0002"); run("16-bit");
	selectWindow("image-0003"); run("16-bit");
	run("Merge Channels...", "c1=image-0001 c2=image-0003 c6=image-0002 keep");

	selectWindow("RGB"); rename("RGB2");
	selectWindow("RGB2");
	setTool("zoom");
	run("ROI Manager...");
	waitForUser("Draw filopodia.\n Then click Ok");
	roiManager("Save", Contrast_adjusted+file_shortname[p]+" - ROI.zip");
	array1 = newArray("0");;
for (i=1;i<roiManager("count");i++){
        array1 = Array.concat(array1,i);
        Array.print(array1);
}

selectWindow("image-0001");
roiManager("select", array1); 
roiManager("Multi Plot");
Plot.showValues();
saveAs("Results", LineProf_results_directory+file_shortname[p]+" - 001.csv");
selectWindow("Profiles"); close();
run("Clear Results"); 

selectWindow("image-0002");
roiManager("select", array1); 
roiManager("Multi Plot");
Plot.showValues();
saveAs("Results", LineProf_results_directory+file_shortname[p]+" - 002.csv");
selectWindow("Profiles"); close();
run("Clear Results"); 


selectWindow("image-0003");
roiManager("select", array1); 
roiManager("Multi Plot");
Plot.showValues();
saveAs("Results", LineProf_results_directory+file_shortname[p]+" - 003.csv");
selectWindow("Profiles"); close();
run("Clear Results"); 
	run("Merge Channels...", "c1=image-0002 c2=image-0001 c6=image-0003 keep");
	selectWindow("RGB"); saveAs("Tiff",Contrast_adjusted+file_shortname[p]+" - RGB.tif");		
	selectWindow("image-0001"); saveAs("Tiff",Contrast_adjusted+file_shortname[p]+" - 0001.tif");
	selectWindow("image-0002"); saveAs("Tiff",Contrast_adjusted+file_shortname[p]+" - 0002.tif");
	selectWindow("image-0003");	saveAs("Tiff",Contrast_adjusted+file_shortname[p]+" - 0003.tif");
	run("Close All");
	roiManager("Deselect");
	roiManager("Delete");
	
	}																														// End of the results saving sub-loop
	
																															// End of main analysis loop