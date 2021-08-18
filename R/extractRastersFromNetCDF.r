extractRastersFromNetCDF <- function(variable=variable, timeslice=timeslice, area=area,path2file=path2file,path2layers=path2layers,path2present=path2present,crop=TRUE,mask=TRUE){

### Get the raster of brick for a variable:
r <- brick(path2file,varname = variable)
    
### If path to present is provided, save present layers in a separate directory:
if(!is.null(path2present)){
# Get present layer:
pr<-r[["X0"]]
# Crop present layer
cropped_pr<-crop(pr, extent(area), snap="out")
    # If crop==TRUE, save cropped layers into a separate directory
     if(crop ==TRUE){
        # First create a separate directory for the cropped layer
        dir.create(paste(path2present,"//cropped//",sep="")) 
        # Save the cropped layer
        writeRaster(cropped_pr,filename=paste(path2present,"\\cropped\\",variable,".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)}
    # If mask is TRUE, also save masked layers to the separate directory
    if(mask==TRUE){
        # Create the directory
        dir.create(paste(path2present,"//masked//",sep=""))
        # Mask the layers
        masked_pr<-mask(cropped_pr,area)
        # Write masked layers to a new directory
        writeRaster(masked_pr,filename=paste(path2present,"\\masked\\",variable,".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)}
}    
    
### Get the brick of relevant past data:
### Paste the "X." before the time period, as they are automatically added to the layers name on extraction from ncdf 
r<-r[[paste("X.",timeslice,sep="")]]
# Create directory for past layers
dir.create(path2layers) 
# Get names for the files by period and variable
filenames <- sub("X.",paste(variable,"_",sep=""),names(r))
### Crop and mask the layers to modern China:
cropped_env<-crop(r, extent(area), snap="out")
# If crop==TRUE, save cropped layers into a separate directory
if(crop==TRUE){
    # First create a separate directory for the cropped layer
    dir.create(paste(path2layers,"//cropped//",sep="")) 
     # Save the cropped layer
writeRaster(cropped_env[[1:length(names(r))]],filename=paste(path2layers,"\\cropped\\",filenames[1:length(names(r))],".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
    }
if(mask==TRUE){
    # Create the directory
    dir.create(paste(path2layers,"//masked//",sep=""))
    # Mask past layers
    masked_env<-mask(cropped_env, area)
    #Write masked layers to the file  
    writeRaster(masked_env[[1:length(names(r))]],filename=paste(path2layers,"\\masked\\",filenames[1:length(names(r))],".tiff",sep=""),format="GTiff",overwrite=TRUE,bylayer=TRUE)
        }
if(!is.null(path2present)){   
    return(c(path2layers,path2present))
    }else{return(path2layers)}
}