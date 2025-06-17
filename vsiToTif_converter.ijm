//converts a set of .vsi files into .tiff files using the specified LoD and input/output folders

//create a UI

emptySpace = "                                                                                                                                        ";

  nStart=283; nEnd=379;
  LoD = 5;
  types = newArray("8-bit", "16-bit", "32-bit", "RGB");
  Dialog.create("Vsi to Tiff converter");
  //Dialog.addDirectory("Source Path:", emptySpace);
  Dialog.addMessage("Indicate the stack number that needs to be iterated in the file name by putting it in {curly brackets}!");
  Dialog.addFile("First source File", emptySpace);
  Dialog.addDirectory("Output Path:", emptySpace);
  Dialog.addNumber("Start stack number:", nStart);
  Dialog.addNumber("End stack number:", nEnd);
  Dialog.addNumber("LoD to extract:", LoD);
  Dialog.show();
  //sourceDir = Dialog.getString();
  sourceFile = Dialog.getString();
  targetDirPath = Dialog.getString();
  stackStart = Dialog.getNumber();
  stackEnd = Dialog.getNumber();
  LoD = Dialog.getNumber();
  

  sourceFileArray = split(sourceFile, "\\");
  sourceFileName = sourceFileArray[sourceFileArray.length-1];
  sourcePathArray = Array.deleteIndex(sourceFileArray, sourceFileArray.length-1);
  sourceFilePath = String.join(sourcePathArray,"\\");
	
	sourceFileArray1 = split(sourceFileName, "{");
	sourceFileArray2 = split(sourceFileName, "}");


if (indexOf(sourceFileName,"{")==-1 || indexOf(sourceFileName,"}")==-1) {
	showMessage("Remember to put the slice number that needs to be iterated in curly brackets. \nExample: imageSlice{234}.vsi");
	exit;
}

	name1 = sourceFileArray1[0];
	name2 = sourceFileArray2[1];


//LoD = 5; //max 1, min 7 									// <<
//stackStart = 283; //first stack number						// <<
//stackEnd = 379; //last stack number							// <<

maxNumberStringSize = lengthOf(""+stackEnd);

setBatchMode(true);
for (sliceNumber = stackStart; sliceNumber <= stackEnd; sliceNumber++) {
	sliceNumberString = ""+sliceNumber;
	
	//this is just a helper to add leading zeros to the stack number nomenclature
	while (lengthOf(sliceNumberString)<maxNumberStringSize) { 
		sliceNumberString="0"+sliceNumberString;	
	}
	
	//define the paths of the source file and the save path
	//path = "J:/Rostock/ImageData/MausEmbryoSlides/Embryonen sortiert/SiR/SiR_KO_689-1/VS200_Slide "+sliceNumberString+".vsi";										// << use / as path separator not \ !
	//savePath = "J:/Rostock/ImageData/MausEmbryoSlides/Embryonen sortiert/SiR/SiR_KO_689-1TIFF/VS200_Slide "+sliceNumberString+"_LoD"+LoD+"_(RGB).tif";	// <<
	
	path = sourceFilePath+"\\"+name1+sliceNumberString+name2;										// << use / as path separator not \ !
	savePath = targetDirPath+name1+sliceNumberString+name2;	// <<
	
	
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