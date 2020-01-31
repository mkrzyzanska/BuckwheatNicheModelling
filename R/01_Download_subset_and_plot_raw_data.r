
# Set up workspace and libraries:
# Set working directory to the github folder:
setwd("G:\\My Drive\\SDM_China")
# Load the required libraries
library(raster)
library(rgdal)
## This is needed to get a quantile-based scale, to show variation in buckwheat production
library(classInt)

### This is needed to work with environmental layers provided as ncdf
require("ncdf4")
require("lattice")

## Load utility functions that will be used in data processing:

source("R\\extractRastersFromNetCDF.r")

### Define the paths to outputs:
path2clipped_china<-"data\\buckwheat_production\\clipped\\"
path2masked_china<-"data\\buckwheat_production\\masked\\"
dir.create(path2clipped_china)
dir.create(path2masked_china)
path2world_production <- "outputs\\01_02_World_buckwheat_production.tiff"
path2china_production <- "outputs\\01_03_China_buckwheat_production.tiff"

##### Download and extract data from earthstat
# Define url of the zipped folder to download
url <- "https://s3.us-east-2.amazonaws.com/earthstatdata/HarvestedAreaYield175Crops_Indvidual_Geotiff/buckwheat_HarvAreaYield_Geotiff.zip"
# Define the directory to which the files will be extracted
fname <- "raw_data//buckwheat_HarvAreaYield_Geotiff"
# Download the zipped folder
download.file(url,paste(fname,".zip",sep=""), mode = "wb")
# Unzip the folder and get the names of its contents:
files <- unzip(paste(fname,".zip",sep=""),exdir="raw_data")
# Removes the zipped folder:#
file.remove(paste(fname,".zip",sep=""))

## Get all the Geotifs with buckwehat production
#List all layers related to buckwheat production:
layers<-list.files(path=fname,pattern='tif$',full.names=TRUE)
#Stack all layers:
prd<-stack(layers)
#Define names of the layers:
names <- c("Data quality: harvested area","Data quality: yield","Harvested area: fractional","Harvested area: hectares",
            "Production in tons","Yield (tons per hectare)")

### Download the dataset with the administrative division of China, so that it can be used to subset the raster maps
url<-"http://biogeo.ucdavis.edu/data/diva/adm/CHN_adm.zip"
# Define the directory to which the files will be extracted
fname <- "raw_data//CHN_adm"
# Download the zipped folder
download.file(url,paste(fname,".zip",sep=""), mode = "wb")
# Unzip the folder and get the names of its contents:
dir.create(fname)
files <- unzip(paste(fname,".zip",sep=""),exdir=fname)
# Removes the zipped folder:#
file.remove(paste(fname,".zip",sep=""))

### Load the shapefile with the borders of China
china <- readOGR(dsn = fname, layer = "CHN_adm0")

### Download the shapefile of the continents as well:
url<-"https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/physical/ne_50m_land.zip"
fname <- "raw_data//ne_50m_land"
# Download the zipped folder
download.file(url,paste(fname,".zip",sep=""), mode = "wb")
# Unzip the folder and get the names of its contents:
dir.create(fname)
files <- unzip(paste(fname,".zip",sep=""),exdir=fname)
# Removes the zipped folder:#
file.remove(paste(fname,".zip",sep=""))

### Load the shapefile with the outline of the continents
continents <- readOGR(dsn = fname, layer = "ne_50m_land")

#Plot data on bucwheat production
#This prepares data for visualisation
## Define breakpoints for each of the map scales
breakpoints <- lapply(as.list(prd),function(x){return(classIntervals(x[!is.na(x)], n = 50, style = "quantile"))})
#Transform the shapefile with continents for visualisation
#continents <- spTransform(continents, crs(prd))
#Make a color palette for visualisation
pal <- colorRampPalette(c("lightyellow","orange","brown"))
my_col = pal(10)

#tiff(path2world_production, units="in", width=7, height=8, res=600,bg = "transparent")
#### Plot data quality on the map with countries boarders:
par(mfrow=c(3,2), mar=c(0,1,1,2), oma=c(0,0,0,1), xpd=NA)

# First map
#Define the map to plot
for(i in 1:6){
    map<-prd[[i]]
    #Define the breakpoints:
    bp<-unique(breakpoints[[i]]$brks)
    #Plot data quality:
    if(grepl("quality",names(map),ignore.case=TRUE)){
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=c(-180,180,-55,90),
             col = c("white",my_col[seq(1,10,length.out=4)]))
        #legend(x='topright', legend = c("No data", "country", "interpolated\n(within 2°\n lat/lon)",
        #"state","county"), fill = c("white",my_col[seq(1,10,length.out=4)]), horiz=FALSE,
        # cex=0.8, inset=c(-0.32,0.1),xpd=TRUE, title="Level of\ncensus data",bty="n",title.adj=0.1)
        plot(continents,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }else{
        #Plot production
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=c(-180,180,-55,90),breaks=bp,col = my_col)
        #Define breaks on the scale
        br<-seq(cellStats(map,min),cellStats(map,max),length.out=length(bp))
        plot(map,legend.only=TRUE, add=TRUE,col = my_col,breaks=br,
        axis.args=list(at=br,labels=signif(bp,digits=1)), smallplot=c(0.9,0.915, 0.05,0.8))
        plot(continents,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }
}
plot(1, type = "n", axes=FALSE, xlab="", ylab="")
legend(x='topright', legend = c("No data", "country", "interpolated\n(within 2°\n lat/lon)",
         "state","county"), fill = c("white",my_col[seq(1,10,length.out=4)]), horiz=TRUE,
         cex=0.8, inset=c(-0.5,0),xpd=TRUE, title="Level of\ncensus data",bty="n",title.adj=0.1)
        plot(continents,add=TRUE, lwd=0.01,border="grey80", lwd=1)

#dev.off()

# Note that china has the same projection as the prd maps, so it does not need to be reprojected
# Clip the data to the extent of china
clipped_prd<-crop(prd, extent(china), snap="out")
### Save clipped data as GeoTiffs:
writeRaster(clipped_prd,filename=paste(path2clipped_china,names(prd),".tif",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
### Mask the data to the borders of China
masked_prd<-mask(clipped_prd, china)
writeRaster(masked_prd,filename=paste(path2masked_china,names(prd),".tif",sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

# Plot clipped data
#nn=2
#path2image<-paste("images//01_",nn,"_buckwheat_production_clipped.png",sep="")
#png(path2image, units="in", width=8, height=6.72, res=1200)
#### Plot data quality on the map with countries boarders:
par(mfrow=c(3,2), mar=c(0,2,2,2), oma=c(2,0,2,0), xpd=NA)

# First map
#Define the map to plot
for(i in 1:6){
    map<-clipped_prd[[i]]
    #Define the breakpoints:
    bp<-unique(breakpoints[[i]]$brks)
    #Plot data quality:
    if(grepl("quality",names(map),ignore.case=TRUE)){
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),
             col = c("white",my_col[seq(1,10,length.out=4)]))
        legend(x='topright', legend = c("No data", "country", "interpolated\n(within 2°\nlat/lon)",
         "state","county"), fill = c("white",my_col[seq(1,10,length.out=4)]), horiz=FALSE,
         cex=0.8, inset=c(-0.15,0),xpd=TRUE, title="Level of\ncensus data",bty="n",title.adj=0.1)
        plot(borders_cropped,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }else{
        #Plot production
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),breaks=bp,col = my_col)
        #Define breaks on the scale
        br<-seq(cellStats(map,min),cellStats(map,max),length.out=length(bp))
        plot(map,legend.only=TRUE, add=TRUE,col = my_col,breaks=br,
        axis.args=list(at=br,labels=signif(bp,digits=1)), smallplot=c(0.9,0.915, 0.05,0.8))
        plot(borders_cropped,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }
}

#dev.off()

## Plot cropped data
nn=3
path2image<-paste("images//01_",nn,"_buckwheat_production_china.png",sep="")
png(path2image, units="in", width=8, height=6.72, res=1200)
#### Plot data quality on the map with countries boarders:
par(mfrow=c(3,2), mar=c(0,2,2,2), oma=c(2,0,2,0), xpd=NA)
#Define the map to plot
for(i in 1:6){
    map<-masked_prd[[i]]
    #Define the breakpoints:
    bp<-unique(breakpoints[[i]]$brks)
    #Plot data quality:
    if(grepl("quality",names(map),ignore.case=TRUE)){
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),
             col = c("white",my_col[seq(1,10,length.out=4)]))
        legend(x='topright', legend = c("No data", "country", "interpolated\n(within 2°\nlat/lon)",
         "state","county"), fill = c("white",my_col[seq(1,10,length.out=4)]), horiz=FALSE,
         cex=0.8, inset=c(-0.15,0),xpd=TRUE, title="Level of\ncensus data",bty="n",title.adj=0.1)
        plot(china,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }else{
        #Plot production
        plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),breaks=bp,col = my_col)
        #Define breaks on the scale
        br<-seq(cellStats(map,min),cellStats(map,max),length.out=length(bp))
        plot(map,legend.only=TRUE, add=TRUE,col = my_col,breaks=br,
        axis.args=list(at=br,labels=signif(bp,digits=1)), smallplot=c(0.9,0.915, 0.05,0.8))
        plot(china,add=TRUE, lwd=0.01,border="grey80", lwd=1)
    }
}

dev.off()

### Define the path to the table with full names of the environmental variables:
path2env_table<-"G:\\My Drive\\SDM_China\\outputs\\01_Predictor_variables.csv"

# Preparing environmental data for 6 time slices from Mid-Holocene to the present:
## The code below downloads the zipped folder containing data on the late Plaistocene and Holocene climate, bioclimate and vegetation
## from figshare (https://figshare.com/s/f098cc85074722ec4930). Data have been published alongside the paper: ()
## Then, it unzips the folder, deletes the original archive, loads extracted NetCDF file, selects the relavant layers
## and saves them as separate files:
##### Download and extract data
# Define url of the zipped folder to download
url <- "https://ndownloader.figshare.com/articles/8327081?private_link=f098cc85074722ec4930"
# Define the directory to which the files will be extracted
fname <- "raw_data//8327081"
# Download the zipped folder
download.file(url,paste(fname,".zip",sep=""), mode = "wb")
# Unzip the folder and get the names of its contents:
files <- unzip(file, exdir=fname)
# Removes the zipped folder:
file.remove(paste(fname,".zip",sep=""))

### The following code extracts the relevant layers from NetCDF and saves them as raster:
##### Open the NetCDF file and extract data
## This opens the env_nc file, in order to get the names of the variables that are stored there
##  and summarizes the time dimension of the data
env_nc <- ncdf4::nc_open(files[1])
# This extracts the availabe variable names:
var_names <- names(env_nc$var)
## Get the times units
env_nc$dim$time$units
str(env_nc$dim$time$vals)

### Prepare the table with the shortcuts of environmental variables and their full names:
short_name <-var_names[c(9,11:27)]
full_name <-c("Net Primary Production",'BIO1 Annual Mean Temperature',
                'BIO4 Temperature Seasonality', 
                'BIO5 Max Temperature of Warmest Month',
                'BIO6 Min Temperature of Coldest Month', 
               'BIO7 Temperature Annual Range', 
               'BIO8 Mean Temperature of Wettest Quarter',
               'BIO9 Mean Temperature of Driest Quarter',
               'BIO10 Mean Temperature of Warmest Quarter', 
               'BIO11 Mean Temperature of Coldest Quarter', 
               'BIO12 Annual Precipitation', 
               'BIO13 Precipitation of Wettest Month', 
              'BIO14 Precipitation of Driest Month',
              'BIO15 Precipitation Seasonality',
               'BIO16 Precipitation of Wettest Quarter',
               'BIO17 Precipitation of Driest Quarter', 
               'BIO18 Precipitation of Warmest Quarter',
               'BIO19 Precipitation of Coldest Quarter')
env_table <- cbind(short_name, full_name)
write.csv(env_table, file=path2env_table,row.names=FALSE)

env_table<-read.csv(path2env_table)

##### This creates the raster stack for the first variable for each of the time periods:
path2file<- files[1]
nslices<-6
area<-china
#### This extracts the relevan layers from the NetCDF file, using the utility function provided in this repository
lapply(var_names,extractRastersFromNetCDF,path2file=path2file, nslices=nslices,area=area,present=TRUE )

### Fagopyrum locations for China:
#Import the table for Fagopyrum occurance records, based on (Hunt et al., 2017) and further evidence from the literature
loc_ea <- read.csv("raw_data//fagopyrum_east_asia.csv")
# Trnsforma data into a spatial points data.frame
coordinates(loc_ea)<-~longitude+latitude

nn=2
path2image<-paste("images//_0",nn,"_absence_records.png",sep="")
png(path2image, units="in", width=6, height=4, res=600)

#### Plot data quality on the map with countries boarders:
borders_cropped <- crop(borders, c(40,190,-10,80))
par(mfrow=c(2,2), mar=c(0,2,2,2), oma=c(2,0,2,0), xpd=NA)
plot(borders_cropped,border="grey80", lwd=1,col="lightyellow", main="Pollen cores",cex.main=0.8)
points(cao2015,col="black",pch=16,cex=0.7)
points(cao2019,col="red",pch=16,cex=0.4)

plot(borders_cropped,border="grey80", lwd=1,col="lightyellow", main="Archaeological sites in China",cex.main=0.8)
points(hosner2016,col="black",pch=16,cex=0.2)
points(shaanxi,col="red",pch=16,cex=0.1)

plot(borders_cropped,border="grey80", lwd=1,col="lightyellow", main="Archaeological sites\nwith archaebotanical remains",
    cex.main=0.8)
points(gb2018,col="black",pch=16,cex=0.6)
points(rice,col="red",pch=16,cex=0.2)

#plot(borders_cropped,border="grey80", lwd=1,col="lightyellow", main="Archaeological sites\nwith archaebotanical remains")
#points(loc_ea,pch=16,col="black",cex=0.5)

dev.off()
