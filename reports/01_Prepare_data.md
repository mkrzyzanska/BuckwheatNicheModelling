
### Set up the working directory and load the libraries


```R
# Set working directory to the github folder:
setwd("G:\\My Drive\\SDM_China")
# Load the libraries:
library(rgdal)
library(raster)
library(RColorBrewer)
library(maptools)
require(XML)
library(classInt)
```

    Warning message:
    "package 'rgdal' was built under R version 3.4.4"Loading required package: sp
    Warning message:
    "package 'sp' was built under R version 3.4.4"rgdal: version: 1.3-6, (SVN revision 773)
     Geospatial Data Abstraction Library extensions to R successfully loaded
     Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
     Path to GDAL shared files: D:/Programs/R/R-3.4.1/library/rgdal/gdal
     GDAL binary built with GEOS: TRUE 
     Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
     Path to PROJ.4 shared files: D:/Programs/R/R-3.4.1/library/rgdal/proj
     Linking to sp version: 1.3-1 
    Warning message:
    "package 'raster' was built under R version 3.4.4"Warning message:
    "package 'maptools' was built under R version 3.4.4"Checking rgeos availability: TRUE
    Loading required package: XML
    Warning message:
    "package 'XML' was built under R version 3.4.4"Warning message:
    "package 'classInt' was built under R version 3.4.4"


```R
nn=1
```


```R
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
```

    OGR data source with driver: ESRI Shapefile 
    Source: "G:\My Drive\SDM_China\raw_data\ne_10m_admin_0_countries", layer: "ne_10m_admin_0_countries"
    with 255 features
    It has 94 fields
    Integer64 fields read as strings:  POP_EST NE_ID 
    OGR data source with driver: ESRI Shapefile 
    Source: "G:\My Drive\SDM_China\raw_data\continent_shapefile", layer: "continent"
    with 8 features
    It has 1 fields
    OGR data source with driver: ESRI Shapefile 
    Source: "G:\My Drive\SDM_China\raw_data\majorrivers_0_0", layer: "MajorRivers"
    with 98 features
    It has 4 fields
    

### Load data with fagopyrum presence in South East Asia


```R
### Fagopyrum locations for China:
#Import the table for Fagopyrum occurance records, based on (Hunt et al., 2017) and further evidence from the literature
loc_ea <- read.csv("raw_data//fagopyrum_east_asia.csv")
# Trnsforma data into a spatial points data.frame
coordinates(loc_ea)<-~longitude+latitude
```


<table>
<thead><tr><th scope=col>No.</th><th scope=col>Sample_type</th><th scope=col>Quantity</th><th scope=col>Sediment_type_pollen_cores</th><th scope=col>Site_section_name</th><th scope=col>Site_short</th><th scope=col>Province</th><th scope=col>Country</th><th scope=col>Taxonomic_identification</th><th scope=col>Dating_method</th><th scope=col>Dating_result</th><th scope=col>Reference</th><th scope=col>lon</th><th scope=col>lat</th><th scope=col>altitude..masl.</th><th scope=col>location_source</th><th scope=col>start_date</th><th scope=col>end_date</th></tr></thead>
<tbody>
	<tr><td>1                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Loess-palaeosol                              </td><td>Xindian section                              </td><td>Xindian                                      </td><td>Shaanxi                                      </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>AMS 14C and OSL                              </td><td>from 5500 cal BP                             </td><td>Li et al. 2009                               </td><td>107°48'E                                     </td><td>34°23'N                                      </td><td> 608.00                                      </td><td>Li et al. 2009                               </td><td>5500                                         </td><td>   0                                         </td></tr>
	<tr><td>2                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Loess-palaeosol                              </td><td>Beizhuangcun section                         </td><td>Beizhuangcun                                 </td><td>Shaanxi                                      </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>Stratigraphic comparison                     </td><td>from 5000 cal BP                             </td><td>Shang and Li 2010                            </td><td>109°32'E                                     </td><td>34°21'N                                      </td><td> 519.00                                      </td><td>Shang and Li 2010                            </td><td>5000                                         </td><td>   0                                         </td></tr>
	<tr><td>3                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Alluvial sediment                            </td><td>WangXianggou site                            </td><td>WangXianggou                                 </td><td>Inner Mongolia                               </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>AMS 14C                                      </td><td>from 4700 cal BP                             </td><td>Li et al. 2006                               </td><td>119°55'E                                     </td><td>42°04'N                                      </td><td> 751.00                                      </td><td>Li et al. 2006                               </td><td>4700                                         </td><td>   0                                         </td></tr>
	<tr><td>4                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Loess-palaeosol with cultural layers         </td><td>Xishanping site                              </td><td>Xishanping                                   </td><td>Gansu                                        </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>AMS 14C                                      </td><td>from 4600 cal BP                             </td><td>Li et al. 2007, Cao et al 2019               </td><td>105°32'41''E                                 </td><td>34°33'50''N                                  </td><td>1330.00                                      </td><td>Li et al. 2007                               </td><td>4600                                         </td><td>   0                                         </td></tr>
	<tr><td>5                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Alluvial sediment                            </td><td>CM97(Chongming island)/ Changjiang River_1997</td><td>CM97 (Chongming island)                      </td><td>Shanghai                                     </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>AMS 14C                                      </td><td>4500 cal BP                                  </td><td>Yi et al. 2003b; Cao et al. 2013             </td><td>121°23'E                                     </td><td>31°37'N                                      </td><td>   2.48                                      </td><td>Yi et al. 2003b                              </td><td>4500                                         </td><td>4500                                         </td></tr>
	<tr><td>6                                            </td><td>Pollen sequence                              </td><td>NA                                           </td><td>Loess-palaeosol                              </td><td>Jingbian section                             </td><td>Jingbian                                     </td><td>Shaanxi                                      </td><td>China                                        </td><td>Fagopyrum. sp                                </td><td>Stratigraphic comparison                     </td><td>4000 cal BP                                  </td><td>Cheng and Jiang 2011; Jiang et al. 2013      </td><td>108.9°E                                      </td><td>37.5°N                                       </td><td>1688.00                                      </td><td>Jiang et al. 2013                            </td><td>4000                                         </td><td>4000                                         </td></tr>
</tbody>
</table>



    Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
      ..@ data       :'data.frame':	40 obs. of  18 variables:
      .. ..$ No.                       : int [1:40] 1 2 3 4 5 6 7 8 9 10 ...
      .. ..$ Sample_type               : Factor w/ 3 levels "Charred seeds",..: 2 2 2 2 2 2 2 2 2 2 ...
      .. ..$ Quantity                  : int [1:40] NA NA NA NA NA NA NA NA NA NA ...
      .. ..$ Sediment_type_pollen_cores: Factor w/ 10 levels "","0","Alluvial sediment",..: 6 6 3 7 3 6 6 3 5 3 ...
      .. ..$ Site_section_name         : Factor w/ 37 levels "Bayantala site",..: 33 2 31 34 7 17 10 3 32 12 ...
      .. ..$ Site_short                : Factor w/ 37 levels "Bayantala","Beizhuangcun",..: 33 2 31 34 7 17 10 3 32 12 ...
      .. ..$ Province                  : Factor w/ 17 levels "","Beijing","Dongbei pingyuan",..: 11 11 6 4 13 11 11 7 17 12 ...
      .. ..$ Country                   : Factor w/ 3 levels "China","India",..: 1 1 1 1 1 1 1 1 1 1 ...
      .. ..$ Taxonomic_identification  : Factor w/ 8 levels "Buckwheat ","Buckwheat (qiaomai)",..: 7 7 7 7 7 7 7 7 8 7 ...
      .. ..$ Dating_method             : Factor w/ 7 levels "","AMS 14C","AMS 14C and OSL",..: 3 7 2 2 2 7 7 2 2 2 ...
      .. ..$ Dating_result             : Factor w/ 32 levels "1030-720 calBP",..: 31 30 29 28 20 19 19 15 13 7 ...
      .. ..$ Reference                 : Factor w/ 33 levels " Jiang et al. 2013",..: 13 19 11 12 30 4 4 17 28 29 ...
      .. ..$ lon                       : Factor w/ 37 levels "100°09'54''E",..: 10 16 24 9 26 13 14 23 1 22 ...
      .. ..$ lat                       : Factor w/ 37 levels "108.29","24.67",..: 16 15 31 17 9 23 19 8 4 25 ...
      .. ..$ altitude..masl.           : num [1:40] 608 519 751 1330 2.48 ...
      .. ..$ location_source           : Factor w/ 30 levels "Cao et al. 2013",..: 18 23 16 17 30 13 13 22 28 29 ...
      .. ..$ start_date                : int [1:40] 5500 5000 4700 4600 4500 4000 4000 2700 2400 1300 ...
      .. ..$ end_date                  : int [1:40] 0 0 0 0 4500 4000 4000 2500 2400 1300 ...
      ..@ coords.nrs : int [1:2] 13 14
      ..@ coords     : num [1:40, 1:2] 108 110 120 106 121 ...
      .. ..- attr(*, "dimnames")=List of 2
      .. .. ..$ : chr [1:40] "1" "2" "3" "4" ...
      .. .. ..$ : chr [1:2] "longitude" "latitude"
      ..@ bbox       : num [1:2, 1:2] 28.8 24.7 126.6 108.3
      .. ..- attr(*, "dimnames")=List of 2
      .. .. ..$ : chr [1:2] "longitude" "latitude"
      .. .. ..$ : chr [1:2] "min" "max"
      ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
      .. .. ..@ projargs: chr NA
    


```R
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
```


<strong>png:</strong> 2


## Load all sites with pollen/archaeological sites


```R
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
```


<table>
<thead><tr><th scope=col>ID</th><th scope=col>Country</th><th scope=col>Province</th><th scope=col>Site</th><th scope=col>Altitude</th><th scope=col>Cal.yr.BP</th><th scope=col>Fagopyrum</th><th scope=col>Polygonum</th><th scope=col>Polygonaceae..other.</th></tr></thead>
<tbody>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td> 353.2        </td><td>0             </td><td>0             </td><td>0             </td></tr>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td>1239.3        </td><td>0             </td><td>0             </td><td>0             </td></tr>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td>2763.2        </td><td>0             </td><td>0             </td><td>0             </td></tr>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td>2803.5        </td><td>0             </td><td>0             </td><td>0             </td></tr>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td>3207.5        </td><td>0             </td><td>0             </td><td>0             </td></tr>
	<tr><td>1             </td><td>Mongolia      </td><td>NA            </td><td>Achit Nur Lake</td><td>1435          </td><td>3541.4        </td><td>0             </td><td>0             </td><td>0             </td></tr>
</tbody>
</table>



    Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
      ..@ data       :'data.frame':	97 obs. of  9 variables:
      .. ..$ ID                  : int [1:97] 29 29 29 29 29 29 29 29 29 29 ...
      .. ..$ Country             : Factor w/ 6 levels "China","India",..: 1 1 1 1 1 1 1 1 1 1 ...
      .. ..$ Province            : Factor w/ 32 levels "","Anhui","Beijing",..: 15 15 15 15 15 15 15 15 15 15 ...
      .. ..$ Site                : Factor w/ 471 levels "11-CH-12A Lake",..: 59 59 59 59 59 59 59 59 59 59 ...
      .. ..$ Altitude            : num [1:97] 2 2 2 2 2 2 2 2 2 2 ...
      .. ..$ Cal.yr.BP           : num [1:97] 357 557 722 879 1000 ...
      .. ..$ Fagopyrum           : num [1:97] 3.57 1.47 7.81 2.86 1.64 ...
      .. ..$ Polygonum           : num [1:97] 0 0 0 0 0 0 1.49 0 4.35 7.5 ...
      .. ..$ Polygonaceae..other.: num [1:97] 0 0 0 0 0 0 0 0 0 0 ...
      ..@ coords.nrs : int [1:2] 6 5
      ..@ coords     : num [1:97, 1:2] 121 121 121 121 121 ...
      .. ..- attr(*, "dimnames")=List of 2
      .. .. ..$ : chr [1:97] "883" "885" "887" "889" ...
      .. .. ..$ : chr [1:2] "Longitude" "Latitude"
      ..@ bbox       : num [1:2, 1:2] 78.3 28.6 126.6 43
      .. ..- attr(*, "dimnames")=List of 2
      .. .. ..$ : chr [1:2] "Longitude" "Latitude"
      .. .. ..$ : chr [1:2] "min" "max"
      ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
      .. .. ..@ projargs: chr NA
    


9



<ol class=list-inline>
	<li>Changjiang River_1997</li>
	<li>Changjiang River_1998</li>
	<li>Charisu</li>
	<li>Luochuan</li>
	<li>Shayema Lake</li>
	<li>Wangjiadian</li>
	<li>Wangyanggou</li>
	<li>Sihailongwan Lake</li>
	<li>Tso Moriri Lake</li>
</ol>




```R
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
```


<strong>png:</strong> 2


# Data for the present distribution model:


```R
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
```


```R
## Define breakpoints for each of the map scales
breakpoints <- lapply(as.list(prd),function(x){return(classIntervals(x[!is.na(x)], n = 50, style = "quantile"))})
```

    Warning message in classIntervals(x[!is.na(x)], n = 50, style = "quantile"):
    "n greater than number of different finite values\nn reset to number of different finite values"Warning message in classIntervals(x[!is.na(x)], n = 50, style = "quantile"):
    "n same as number of different finite values\neach different finite value is a separate class"Warning message in classIntervals(x[!is.na(x)], n = 50, style = "quantile"):
    "n greater than number of different finite values\nn reset to number of different finite values"Warning message in classIntervals(x[!is.na(x)], n = 50, style = "quantile"):
    "n same as number of different finite values\neach different finite value is a separate class"


```R
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
```


<strong>png:</strong> 2



```R
### Now crop the map to the extent of china:
# Get the borders of China from the world shapefile:
china<-subset(borders,borders$SOVEREIGNT=="China")
# Note that is has the same projection as the prd maps, so it does not need to be reprojected
clipped_prd<-crop(prd, extent(china), snap="in")
borders_cropped <- crop(borders, extent(china))
```

    Loading required namespace: rgeos
    


```R
### Save clipped data as GeoTiffs:
path2layers<-"data\\buckwheat_production\\clipped\\"
#writeRaster(clipped_prd,filename=paste(path2layers,names(clipped_prd),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
layers<-list.files(path=path2layers,pattern='tif$',full.names=TRUE)
clipped_prd<-stack(layers)
```


```R
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
```


![png](output_16_0.png)



```R
#Mask raster with the shapefile of China to create NoData
masked_prd<-mask(clipped_prd, china)
```


```R
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
```


<strong>png:</strong> 2



```R
path2layers<-"data\\buckwheat_production\\china\\"
writeRaster(masked_prd,filename=paste(path2layers,names(masked_prd),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
```


```R
china_counties <- readOGR(dsn = "raw_data\\CHN_adm", layer = "CHN_adm3")
```

    OGR data source with driver: ESRI Shapefile 
    Source: "G:\My Drive\SDM_China\raw_data\CHN_adm", layer: "CHN_adm3"
    with 2409 features
    It has 13 fields
    Integer64 fields read as strings:  ID_0 ID_1 ID_2 ID_3 
    


```R
plot(masked_prd[[2]])
```


```R
i=4
bp<-unique(breakpoints[[5]]$brks)
map=masked_prd[[i]]
plot(map,main=names[i],axes=FALSE,box=FALSE,legend=FALSE,ext=extent(china),breaks=bp,col = my_col)
plot(china_counties,add=TRUE)
```


![png](output_22_0.png)


# Environmental data (for 120K)


```R
require("ncdf4")
require("lattice")
require("ggplot2")
## Loads the file
file <- "raw_data//8327081//LatePleistoceneHolocene_Climate.nc"
```

    Loading required package: ncdf4
    Loading required package: lattice
    Loading required package: ggplot2
    Warning message:
    "package 'ggplot2' was built under R version 3.4.4"


```R
env_nc      <- ncdf4::nc_open(file)
longitude   <- ncdf4::ncvar_get(env_nc, "longitude")
latitude    <- ncdf4::ncvar_get(env_nc, "latitude")
years       <- ncdf4::ncvar_get(env_nc, "time")
months      <- ncdf4::ncvar_get(env_nc, "month")
temperature <- ncdf4::ncvar_get(env_nc, "temperature")
biome       <- ncdf4::ncvar_get(env_nc, "biome")
ncdf4::nc_close(env_nc)
```


```R
my_year      <- -10000;   # 10,0000 BP
my_month     <- 6;        # June
my_longitude <- 0.1218;
my_latitude  <- 52.2053;  # Cambridge (UK)
```


```R
p1 <- print(lattice::levelplot(biome[,,years == my_year], main = "Biome distribution, 10000 BP"))
p2 <- print(lattice::levelplot(temperature[,,months == my_month,years == my_year], main = "Mean June temperature, 10000 BP"))
```


![png](output_27_0.png)



![png](output_27_1.png)



```R
### Get the list of variables used
summary(env_nc$var)
### npp is a net primary productivity estimate
### lai - leaf area index
```


                      Length Class  Mode
    temperature       22     ncvar4 list
    precipitation     22     ncvar4 list
    cloud             22     ncvar4 list
    relative_humidity 22     ncvar4 list
    wind_speed        22     ncvar4 list
    min_temperature   22     ncvar4 list
    max_temperature   22     ncvar4 list
    biome             22     ncvar4 list
    npp               22     ncvar4 list
    lai               22     ncvar4 list
    BIO1              22     ncvar4 list
    BIO4              22     ncvar4 list
    BIO5              22     ncvar4 list
    BIO6              22     ncvar4 list
    BIO7              22     ncvar4 list
    BIO8              22     ncvar4 list
    BIO9              22     ncvar4 list
    BIO10             22     ncvar4 list
    BIO11             22     ncvar4 list
    BIO12             22     ncvar4 list
    BIO13             22     ncvar4 list
    BIO14             22     ncvar4 list
    BIO15             22     ncvar4 list
    BIO16             22     ncvar4 list
    BIO17             22     ncvar4 list
    BIO18             22     ncvar4 list
    BIO19             22     ncvar4 list



```R
str(years)
str(longitude)
str(latitude)
str(months)
str(temperature)
```

     int [1:72(1d)] -120000 -118000 -116000 -114000 -112000 -110000 -108000 -106000 -104000 -102000 ...
     num [1:720(1d)] -180 -179 -179 -178 -178 ...
     num [1:300(1d)] -59.8 -59.2 -58.8 -58.2 -57.8 ...
     int [1:12(1d)] 1 2 3 4 5 6 7 8 9 10 ...
     num [1:720, 1:300, 1:12, 1:72] NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ...
    


```R
holocene_years <- years[66:72]
```


```R
env_nc      <- ncdf4::nc_open(file)
BIO9 <- ncdf4::ncvar_get(env_nc, "BIO9")
BIO10 <- ncdf4::ncvar_get(env_nc, "BIO10")
ncdf4::nc_close(env_nc)
```


```R
str(BIO9)
```

     num [1:720, 1:300, 1:72] NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ...
    


```R
lonID <- which.min(abs(longitude - my_longitude));
latID <- which.min(abs(latitude - my_latitude));
yearID <- which.min(abs(years - my_year));
```


```R
p3 <- ggplot2::qplot(months, temperature[lonID,latID,,yearID], xlab = "Month", ylab = "Mean temperature",  geom=c("point", "line"))
```


```R
p3
```




![png](output_35_1.png)



```R
mean_annual_temperature <- apply(temperature, c(1,2,4), mean)
p4 <- ggplot2::qplot(years, mean_annual_temperature[lonID,latID,], xlab = "Year", ylab = "Temperature", main = "Mean annual temperature time series, Cambridge (UK)", geom=c("point", "line"))
gridExtra::grid.arrange(p1, p2, p3, p4, nrow = 2)
```


![png](output_36_0.png)



```R

```

# Environmental data: (bioclim website)


```R
prd
```


    class       : RasterStack 
    dimensions  : 2160, 4320, 9331200, 6  (nrow, ncol, ncell, nlayers)
    resolution  : 0.08333333, 0.08333333  (x, y)
    extent      : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
    coord. ref. : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
    names       : buckwheat//vestedArea, buckwheat//lity_Yield, buckwheat//eaFraction, buckwheat//eaHectares, buckwheat_Production, buckwheat_YieldPerHectare 
    



```R
### Load environmental layers from bioclim:
### Use environmental data with similiar resolution to the data on buckwheat production i.e. 5 min by 5 min or ~10km:
path2env<-"raw_data\\environmental\\modern\\wc2.0_5m_bio\\"
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
env<-stack(layers)
```


```R
#Here needs to print nicely all of the environmental data:
plot(env)
```


![png](output_41_0.png)



```R
clipped_env<-crop(env, extent(china), snap="in")
masked_env<-mask(clipped_env, china)
```


```R
path2layers<-"data\\environmental\\clipped\\"
writeRaster(clipped_env,filename=paste(path2layers,names(clipped_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

path2layers<-"data\\environmental\\china\\"
writeRaster(masked_env,filename=paste(path2layers,names(masked_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
```


```R
plot(clipped_env)
```


![png](output_44_0.png)



```R
plot(masked_env)
```


![png](output_45_0.png)


### Past Environmental data:


```R
path2env<-"raw_data\\environmental\\past\\bioclim_variables\\"
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
env<-stack(layers)
```


```R
clipped_env<-crop(env, extent(china), snap="in")
masked_env<-mask(clipped_env, china)
```


```R
path2layers<-"data\\environmental\\past\\clipped\\"
writeRaster(clipped_env,filename=paste(path2layers,names(clipped_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)

path2layers<-"data\\environmental\\past\\china\\"
writeRaster(masked_env,filename=paste(path2layers,names(masked_env),sep=""),format="GTiff", overwrite=TRUE,bylayer=TRUE)
```


```R
### Possible sources of soil data:

https://soilgrids.org/#!/?layer=ORCDRC_M_sl2_250m&vector=1
http://globalchange.bnu.edu.cn/research/data
```
