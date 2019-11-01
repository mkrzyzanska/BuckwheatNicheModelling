
# Set working directory to the github folder:
setwd("G:\\My Drive\\SDM_China")
# Load the libraries:
library(rgdal)
library(raster)
library(RColorBrewer)
library(maptools)
require(XML)
library(classInt)

nn=1

#### Set working directory:
#### Load data useful for visualisation:
# Get country borders
borders <- readOGR(dsn = "raw_data\\ne_10m_admin_0_countries", layer = "ne_10m_admin_0_countries")
# Get continents borders
continents <- readOGR(dsn = "raw_data\\continent_shapefile", layer = "continent")
# Get a nice basemap from: https://www.naturalearthdata.com/downloads/
basemap <- brick("raw_data\\NE2_50m_SR_W\\NE2_50M_SR_W\\NE2_50M_SR_W.tif")
### Add the map with rivers
rivers <- readOGR(dsn = "raw_data\\majorrivers_0_0", layer = "MajorRivers")
china<-subset(borders,borders$SOVEREIGNT=="China")

### Fagopyrum locations for China:
#Import the table for Fagopyrum occurance records, based on (Hunt et al., 2017) and further evidence from the literature
loc_ea <- read.csv("raw_data//fagopyrum_east_asia.csv")
# Trnsforma data into a spatial points data.frame
coordinates(loc_ea)<-~longitude+latitude

nn=1
path2image<-paste("images//01_",nn,"_Fagopyrum_in_China.png",sep="")
png(path2image, units="in", width=12, height=6.72, res=1200)
#Define extent for plotting and cropp all the shapefiles that will be put on the top
ext <- c(65,140,15,57 )
rivers_cropped <- crop(rivers, ext)
borders_cropped<-crop(borders, ext)
plotRGB(basemap, interpolate = TRUE,ext=ext,mar=c(0,0,0,0),bg=rgb(255,255,255,alpha=1))
plot(rivers_cropped, add=TRUE, col="dodgerblue",lwd=1,main="Fagopyrum locations in China")
plot(borders_cropped, add=TRUE, border="grey50", lwd=1)
#points(d)

d<-subset(loc_ea,loc_ea$start_date>=000)
points(d[as.character(d$Sample_type)=="Pollen sequence",],pch=21, bg="pink",col="red",lwd=3)
points(d[as.character(d$Sample_type)=="Charred seeds",],pch=17, bg="black",col="black",lwd=3)
text(d[as.character(d$Sample_type)=="Charred seeds",],labels=d[as.character(d$Sample_type)=="Charred seeds",]$Site_short, 
    cex= 1,pos=c(3,2,4,4,1,4,4,4,4,2,4,3))
points(d[as.character(d$Sample_type)=="Starch grains",],pch=22, bg="orange",col="brown",lwd=3)
text(d[as.character(d$Sample_type)=="Starch grains",],labels=d[as.character(d$Sample_type)=="Starch grains",]$Site_short, 
    cex= 1,pos=c(2,2))
text(85,60 , "Fagopyrum in China", pos = 4, cex=2,col="black")
legend(x='bottomright', legend = c("Pollen", "Charred seeds","Starch grains"), inset=c(0.01,0.01), cex=1.5,
       pch=c(21,24,22), col=c("red","black","brown"), pt.bg=c("pink","black","orange"))
dev.off()

### Import additional pollen data from pollen database for Asia provided by Xianyong Cao, used in the paper (Cao et al., 2019):
cao2015<-read.csv("raw_data//FossilPollenDatabasePercentageAsian.csv")
### Transform the data into a Spatial Points data frame:
coordinates(cao2015)<-~Longitude+Latitude
#Create a subset of records where fagopyrum has been identified:
cao2015_fagopyrum <- subset(cao2015, cao2015$Fagopyrum>0)

# Import additional data for northern China & Syberia provided alongside the paper (Cao et al., 2019)
cao2019 <-read.table("raw_data\\CaoX-etal_2019\\datasets\\Siberia_pollen_percentages.tab", header = TRUE, sep = "\t", row.names=NULL,skip=303)
cao2019<-subset(cao2019, !is.na(cao2019$Longitude))
coordinates(cao2019)<-~Longitude+Latitude
cao2019_poly<-subset(cao2019,cao2019$Polygonacea>0)

### Open the kmz rice database (archaeological sites with rice):
### This unzips the kmlfile and saves it in the database
#kmlfile <- unzip(zipfile = "raw_data\\journal.pone.0137024.s001.kmz",exdir   = "raw_data\\rice_database")
### This imports the rice database into R:
rice<-readOGR("raw_data\\rice_database\\Rice Archaeological Database.kml")

### Import the database from d'Guedes:
gb2018 <-read.csv("raw_data\\guedesbocinsky2018_crops_across_eurasia.csv")
gb2018<-subset(gb2018,!is.na(gb2018$Longitude))
coordinates(gb2018)<-~Longitude+Latitude

## Import archaeological sties from China
hosner2016 <-read.table("raw_data\\Hosner_2016.tab", header = TRUE, sep = "\t", row.names=NULL,skip=20)
coordinates(hosner2016)<-~Longitude+Latitude

### Import archaeological sites from Shaanxi
#Unzip all km files
#files<-list.files(path="raw_data\\SHAANXI DISCRETE KMZ\\",pattern='kmz$',full.names=TRUE)
#shaanxi <- lapply(files, function(file){unzip(file,exdir=paste("raw_data\\shaanxi\\",gsub(".*KMZ\\\\s*|.kmz.*", "",file),sep=""))})
sh_allsites <- lapply(shaanxi[c(-3,-14,-17,-25,-48,-52)],readOGR)
shaanxi<-bind(sh_allsites)

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

## Get all the Geotifs with buckwehat production

### This loads the data
#List all layers related to buckwheat production:
layers<-list.files(path="raw_data\\buckwheat_HarvAreaYield_Geotiff\\buckwheat_HarvAreaYield_Geotiff\\",pattern='tif$',full.names=TRUE)
#Stack all layers:
prd<-stack(layers)
#Define names of the layers:
names <- c("Data quality: harvested area","Data quality: yield","Harvested area: fractional","Harvested area: hectares",
                "Production in tons","Yield (tons per hectare)")
##This prepares data for visualisation
#Transform the shapefile with continents for visualisation
continents <- spTransform(continents, crs(prd))
#Make a color palette for visualisation
pal <- colorRampPalette(c("lightyellow","orange","brown"))
my_col = pal(10)

## Define breakpoints for each of the map scales
breakpoints <- lapply(as.list(prd),function(x){return(classIntervals(x[!is.na(x)], n = 50, style = "quantile"))})

path2image<-paste("images//01_",nn,"_buckwheat_production_in_the_world.png",sep="")
png(path2image, units="in", width=12, height=6.72, res=1200)
#### Plot data quality on the map with countries boarders:
par(mfrow=c(3,2), mar=c(0,2,2,2), oma=c(2,0,2,0), xpd=NA)

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
        legend(x='topright', legend = c("No data", "country", "interpolated\n(within 2° lat/lon)",
         "state","county"), fill = c("white",my_col[seq(1,10,length.out=4)]), horiz=FALSE,
         cex=0.85, inset=c(-0.1,0.23),xpd=TRUE, title="Level of\ncensus data",bty="n",title.adj=0.1)
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

dev.off()

### Now crop the map to the extent of china:
# Get the borders of China from the world shapefile:
china<-subset(borders,borders$SOVEREIGNT=="China")
# Note that is has the same projection as the prd maps, so it does not need to be reprojected
clipped_prd<-crop(prd, extent(china), snap="in")
borders_cropped <- crop(borders, extent(china))

### Save clipped data as GeoTiffs:
path2layers<-"data\\buckwheat_production\\clipped\\"
#writeRaster(clipped_prd,filename=paste(path2layers,names(clipped_prd),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
layers<-list.files(path=path2layers,pattern='tif$',full.names=TRUE)
clipped_prd<-stack(layers)

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

#Mask raster with the shapefile of China to create NoData
masked_prd<-mask(clipped_prd, china)

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

path2layers<-"data\\buckwheat_production\\china\\"
writeRaster(masked_prd,filename=paste(path2layers,names(masked_prd),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

china_counties <- readOGR(dsn = "raw_data\\CHN_adm", layer = "CHN_adm3")

plot(masked_prd[[2]])

i=4
bp<-unique(breakpoints[[5]]$brks)
map=masked_prd[[i]]
plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),breaks=bp,col = my_col)
plot(china_counties,add=TRUE)

require("ncdf4")
require("lattice")
require("ggplot2")
## Loads the file
file <- "raw_data//8327081//LatePleistoceneHolocene_Climate.nc"

env_nc      <- ncdf4::nc_open(file)
longitude   <- ncdf4::ncvar_get(env_nc, "longitude")
latitude    <- ncdf4::ncvar_get(env_nc, "latitude")
years       <- ncdf4::ncvar_get(env_nc, "time")
months      <- ncdf4::ncvar_get(env_nc, "month")
temperature <- ncdf4::ncvar_get(env_nc, "temperature")
biome       <- ncdf4::ncvar_get(env_nc, "biome")
ncdf4::nc_close(env_nc)

my_year      <- -10000;   # 10,0000 BP
my_month     <- 6;        # June
my_longitude <- 0.1218;
my_latitude  <- 52.2053;  # Cambridge (UK)

p1 <- print(lattice::levelplot(biome[,,years == my_year], main = "Biome distribution, 10000 BP"))
p2 <- print(lattice::levelplot(temperature[,,months == my_month,years == my_year], main = "Mean June temperature, 10000 BP"))

### Get the list of variables used
summary(env_nc$var)
### npp is a net primary productivity estimate
### lai - leaf area index

str(years)
str(longitude)
str(latitude)
str(months)
str(temperature)

holocene_years <- years[66:72]

env_nc      <- ncdf4::nc_open(file)
BIO9 <- ncdf4::ncvar_get(env_nc, "BIO9")
BIO10 <- ncdf4::ncvar_get(env_nc, "BIO10")
ncdf4::nc_close(env_nc)

str(BIO9)

lonID <- which.min(abs(longitude - my_longitude));
latID <- which.min(abs(latitude - my_latitude));
yearID <- which.min(abs(years - my_year));

p3 <- ggplot2::qplot(months, temperature[lonID,latID,,yearID], xlab = "Month", ylab = "Mean temperature",  geom=c("point", "line"))

p3

mean_annual_temperature <- apply(temperature, c(1,2,4), mean)
p4 <- ggplot2::qplot(years, mean_annual_temperature[lonID,latID,], xlab = "Year", ylab = "Temperature", main = "Mean annual temperature time series, Cambridge (UK)", geom=c("point", "line"))
gridExtra::grid.arrange(p1, p2, p3, p4, nrow = 2)



prd

### Load environmental layers from bioclim:
### Use environmental data with similiar resolution to the data on buckwheat production i.e. 5 min by 5 min or ~10km:
path2env<-"raw_data\\environmental\\modern\\wc2.0_5m_bio\\"
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
env<-stack(layers)

#Here needs to print nicely all of the environmental data:
plot(env)

clipped_env<-crop(env, extent(china), snap="in")
masked_env<-mask(clipped_env, china)

path2layers<-"data\\environmental\\clipped\\"
writeRaster(clipped_env,filename=paste(path2layers,names(clipped_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

path2layers<-"data\\environmental\\china\\"
writeRaster(masked_env,filename=paste(path2layers,names(masked_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

plot(clipped_env)

plot(masked_env)

path2env<-"raw_data\\environmental\\past\\bioclim_variables\\"
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
env<-stack(layers)

clipped_env<-crop(env, extent(china), snap="in")
masked_env<-mask(clipped_env, china)

path2layers<-"data\\environmental\\past\\clipped\\"
writeRaster(clipped_env,filename=paste(path2layers,names(clipped_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

path2layers<-"data\\environmental\\past\\china\\"
writeRaster(masked_env,filename=paste(path2layers,names(masked_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

### Possible sources of soil data:

https://soilgrids.org/#!/?layer=ORCDRC_M_sl2_250m&vector=1
http://globalchange.bnu.edu.cn/research/data
