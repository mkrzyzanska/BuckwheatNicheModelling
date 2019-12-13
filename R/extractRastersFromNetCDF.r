### Defines a function to extract data:

### Selects the time slices for a specific variable from NetCDF file and crops and masks them to a specified area
### which is given as a vector polygon.
### Then it saves the raster layers as tiffs the folders created for past and present environemntal data 

extractRastersFromNetCDF <- function(variable=variable, path2file=path2file, nslices=nslices,area=area,present=present){
### Get the raster of brick for a variable:
r <- brick(path2file,varname = variable)
### Get the brick of relevant past data:
r<-r[[(length(names(r))-nslices):(length(names(r)))]]
### Crop and mask the layers to modern China:
cropped_env<-crop(r, extent(area), snap="out")
masked_env<-mask(cropped_env, area)
### Define the path to past data layers:
path2layers<-paste("data\\environmental\\past\\",variable,"\\",sep="")
### Create required directoried
dir.create(path2layers) 
dir.create(paste(path2layers,"cropped//",sep="")) 
dir.create(paste(path2layers,"masked//",sep="")) 
### Define the path to present data layers:
if(present==TRUE){
path2present<-"data\\environmental\\present\\" 
dir.create(paste(path2present,"cropped//",sep="")) 
dir.create(paste(path2present,"masked//",sep=""))
writeRaster(cropped_env[[7]],filename=paste(path2present,"cropped\\",variable,".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
writeRaster(masked_env[[7]],filename=paste(path2present,"masked\\",variable,".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
}
filenames <- sub("X.",paste(variable,"_",sep=""),names(r))
writeRaster(cropped_env[[1:6]],filename=paste(path2layers,"cropped\\",filenames[1:6],".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
writeRaster(masked_env[[1:6]],filename=paste(path2layers,"masked\\",filenames[1:6],".tiff",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
return(c(path2layers,path2present))
}