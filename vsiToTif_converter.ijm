//converts a set of .vsi files into .tiff files using the specified LoD and input/output folders

LoD = 5; //max 1, min 7 									// <<
stackStart = 283; //first stack number						// <<
stackEnd = 379; //last stack number							// <<

maxNumberStringSize = lengthOf(""+stackEnd);

setBatchMode(true);
for (sliceNumber = stackStart; sliceNumber <= stackEnd; sliceNumber++) {
	sliceNumberString = ""+sliceNumber;
	
	//this is just a helper to add leading zeros to the stack number nomenclature
	while (lengthOf(sliceNumberString)<maxNumberStringSize) { 
		sliceNumberString="0"+sliceNumberString;	
	}
	
	//define the paths of the source file and the save path
	path = "J:/Rostock/ImageData/MausEmbryoSlides/Embryonen sortiert/SiR/SiR_KO_689-1/VS200_Slide "+sliceNumberString+".vsi";										// << use / as path separator not \ !
	savePath = "J:/Rostock/ImageData/MausEmbryoSlides/Embryonen sortiert/SiR/SiR_KO_689-1TIFF/VS200_Slide "+sliceNumberString+"_LoD"+LoD+"_(RGB).tif";	// <<
	print(sliceNumberString); // basic progress indicator
	
	if (File.exists(path)) { // check if the file actually exists 
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+LoD); // import the selected LoD image from the image file with bioformats importer
		compositImageId = getImageID(); //memorize the ID of the image
		run("Stack to RGB"); //convert it to RGB
		rgbImage = getImageID(); //memorize the ID of the RGB image
		
		//close the original image
		selectImage(compositImageId);
		close();
		
		//select the RGB image, save it, then close it 
		selectImage(rgbImage);
		run("Invert");
		saveAs("Tiff", savePath);
		close();
	}else{
		print("slice missing, skipping...");
	}
}

setBatchMode(false);
print("done!");