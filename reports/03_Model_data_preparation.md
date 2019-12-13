
# Model data preparation

This code transform the data into a format from which input data from stan model can be easily extracted. First it calculates aggregate present environmental variables and data on buckwheat production for each county in China, and attaches them as metadata to the spatial polygon data frame with Chinese counties. Then it also caluclates and saves the adjacency matrix for Chinese counties to be used in iCAR model

## Set up working space and paths


```R
### This will created the shapefile, with production data and environmental variables in an appropriate format
### for the counties of China
### Set the working directory:
setwd("G:\\My Drive\\SDM_China\\")
### Load the libraries
library(rgdal)
library(raster)
### (For rbindlist)
library(data.table)
### To calculate the area of the polygon
require(geosphere)
### Calculates the adjacency matrix:
library(spdep)
```


```R
### Set the paths for loading data
# Masked data on buckwheat production in China (masked to keep the data consistent:
path2prd<-"data\\buckwheat_production\\masked\\"
### Environmental variables (cropped, because the border cells will have a consistent quality:
path2env <-"data\\environmental\\present\\cropped\\"
### Get path to past environmental data:
path2past <- "data\\environmental\\past\\"
###### Set the paths for outputs:
path2stats<- "outputs\\03_01_Env_Mean_and_SD.csv"
path2adjacency <- "data\\china_data\\adjacency.csv"
```


```R
### Loading data:
### Get vector map of Chinses counties
china<-readOGR(dsn = "raw_data\\CHN_adm", layer = "CHN_adm3")
### Get small dataset of China:
prd_layers<-list.files(path=path2prd,pattern='tif$',full.names=TRUE)
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
### Get only the environmental layers that are not autocorrelated:
env_layers<-subset(layers,lapply(layers, grepl,pattern="BIO4|BIO10|BIO11|BIO19|npp")==TRUE)
prd<-stack(prd_layers)
env<-stack(env_layers)
```

## Extract the environmental data for counties


```R
# Extract raster values of the cells for environmental variables for each county in China
r.vals <- extract(env,china,weights=TRUE,normalizeWeights=TRUE)
```


```R
# Calculate the mean value of each of the environmental variables for each county in China
# and attach it as attribute data for the spatial polygons data frame:
#r.means<-lapply(r.vals, colMeans, na.rm=TRUE)
## Calculate the weighted mean:
r.means<-lapply(r.vals,function(x){apply(rbind(x[,c(1:ncol(x)-1)]),2,weighted.mean,w=x[,ncol(x)],na.rm=TRUE)})
r.mean<-lapply(r.means, rbind)
r.mean<-lapply(r.mean,as.data.frame)
r.mean<- rbindlist(r.mean)
```


```R
# Get the counties with missing values, because they don't overlap with eny of the raster cells:
sums<-rowSums(r.mean)
mc<-which(is.na(sums))
```


```R
# Create a raster stack of environmental variables with a buffer zone around the coast
# to include the counties with missing values
buffer <- stack()
for (i in 1:length(names(env))){
    focal<-focal(env[[i]],w=matrix(1,3,3), fun=mean,na.rm=TRUE,NAonly=TRUE)
    names(focal)<-names(env[[i]])
    buffer<-stack(buffer,focal)
}
```


```R
# Extract the values from the buffer zone:
buffer.vals <- extract(buffer,china[mc,],weights=TRUE,normalizeWeights=TRUE)
buffer.means<-lapply(buffer.vals,function(x){apply(rbind(x[,c(1:ncol(x)-1)]),2,weighted.mean,w=x[,ncol(x)],na.rm=TRUE)})
buffer.mean<-lapply(buffer.means, rbind)
buffer.mean<-lapply(buffer.mean,as.data.frame)
buffer.mean<- rbindlist(buffer.mean)
```


```R
# Substitute newly calculated values for NAs
r.mean[mc,] <-buffer.mean
```


```R
china@data <- data.frame(china@data, r.mean)
```

## Extract values for production


```R
## Extract raster values of the cells with data on buckwheat production for each county in China
 r.vals <- extract(prd,china )
```


```R
## Calculate either mean values, or sums for the variables related to buckwheat production for each county
r.mean<-lapply(r.vals,function(x){
HarvestedAreaDataQuality<- names(sort(table(x[,1]),decreasing=TRUE))[1]
YieldDataQuality<- names(sort(table(x[,2]),decreasing=TRUE))[1]
HarvestAreaFraction<-mean(x[,3],na.rm=TRUE)
HarvestedAreasHectaresSum<-sum(x[,4],na.rm=TRUE)
HarvestedAreasHectaresMean<-mean(x[,4],na.rm=TRUE)
ProductionSum<-sum(x[,5],na.rm=TRUE)
ProductionMean<-mean(x[,5],na.rm=TRUE)
YieldPerHectare<-mean(x[,6],na.rm=TRUE)
df<-cbind(HarvestedAreaDataQuality,YieldDataQuality,HarvestAreaFraction,HarvestedAreasHectaresSum,HarvestedAreasHectaresMean,ProductionSum,ProductionMean,YieldPerHectare)
return(df)})
```


```R
## Turn the extracted values into one data frame
r.mean<-lapply(r.mean, rbind)
r.mean<-lapply(r.mean,as.data.frame)
r.mean<- rbindlist(r.mean)
### Change colnames to shorter onse before attaching them to the spatial polygons datafram, so that they are not cut when 
### writing it to the file
colnames(r.mean)<-c("AreaDQ","YieldDQ","AreaFr","AreaHaS","AreaHaM","ProdSum","ProdMean","YieldPH")
### Attach the dataframe to the attributes of the spatial polygons
china@data <- data.frame(china@data, r.mean)
```


```R
### Calculate the area of each 
china@data$area<-areaPolygon(china)
```


```R
### Get the prortion of area which is cultivated, by dividing the cultivated area in hectares for the county, by the area of 
### the county. Area is given in square meters, and cultivated area in hectares, so multiply by 10 000.
china@data$AreaPr<-(as.numeric(as.character(china@data$AreaHaS))/china@data$area)*10000

### Get the average produciont of buckwheat in tonnes, per hectar of a county
china@data$ProdHa<-(as.numeric(as.character(china@data$ProdSum))/china@data$area)*10000
```


```R
### Get the smallest possible values of AreaPr and Prod Ha:
sort(unique(china@data$AreaPr))[2]
sort(unique(china@data$ProdHa))[2]
```


```R
### Get the logarithms for the proportion of the area of the county where buckwheat is cultivatad 
### and for average production in tonnes per hectare in a country.
### To transform into a logarithm add a small value 
### (a magnitude smaller than the second smallest value in the column)
### to all of the numbers to avoind zeros:
china@data$logArea <- log(china@data$AreaPr+1e-11 )
china@data$logProd <- log(china@data$ProdHa+1e-11)
```

## Standardise environmental variables


```R
### Get the names of the environmental variables
env_vars<-names(env)
```


```R
#### Get the mean and standard deviation of all the bioclimatic variables that will be used in a model:
stats<-lapply(env_vars,function(x){
past_layers<-list.files(path=paste(path2past,x,"\\masked\\",sep=""),pattern='tif$',full.names=TRUE)
var_stack <- stack(past_layers,subset(env,x))
vals<-as.vector(values(var_stack))
mean<-mean(vals, na.rm=TRUE)
sd<-sd(vals, na.rm=TRUE)
return(as.data.frame(cbind(mean,sd)))})

# Get the mean and standard deviations of the environmental variables into a dataframe
stats<-rbindlist(stats)
# Name the rows according to the names of the environmental variables
rownames(stats) <- env_vars
# Save the mean and standard deviation used for scaling and centering of the variables:
write.csv(stats, file=path2stats)
```


```R
### Calculate standardised values for all columns, using the obtained mean and standard deviation
new_columns<-scale(china@data[,env_vars],center=stats$mean,scale=stats$sd)
colnames(new_columns)<-paste(env_vars,"sd",sep="_")
```


```R
### Add standardised columns to the spatial polygons data frame:
china@data <- data.frame(china@data,new_columns)
```


```R
### Write the Spatial Polygon data frame to a file:
writeOGR(obj=china, dsn="data\\china_data", layer="china_data", driver="ESRI Shapefile")
```

## Calculate and save the adjacency matrix


```R
### Calculate the adjacency matrix for the Spatial Polygons Data Frame:

#### Now also get the adjacency matrix between the nodes and save it as csv:
# Gets the numbe of observations
N=nrow(china@data)

# Gets the adjacency
adj<-poly2nb(china)

# Define the nodes as vectors

node2 = vector(mode="numeric");
node1 = vector(mode="numeric");

# Get the values for each node
for (i in 1:N){
    a<-unlist(adj[i])
    a<-a[a>i]
    # Add to values of Node 1
    n1<-rep(i,length(a))
    node1 <-c(node1,n1)
    # Add values of Node 2
    node2<-c(node2,a)
}

mat<-cbind(node1, node2)
write.csv(mat, file=path2adjacency,row.names = FALSE)
```

## Visualise data


```R
# Finally, visualise some of the data:
#spplot(china['BIO_1'] )
spplot(china['BIO10'] )
spplot(china['logArea'] )
```
