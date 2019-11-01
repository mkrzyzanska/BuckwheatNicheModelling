
setwd("G:\\My Drive\\SDM_China")
library("rstan")
library(gdata)
#library(bayesplot)
library(raster)
library(rgdal)
library(sp)
library(spdep)
library(data.table)

### Load data on buckwheat production in China:
path2bw<-"data\\buckwheat_production\\clipped\\"
path2env <-"data\\environmental\\clipped\\"
### Get small dataset of China:
china<-readOGR(dsn = "raw_data\\CHN_adm", layer = "CHN_adm3")
bw_layers<-list.files(path=path2bw,pattern='tif$',full.names=TRUE)
env_layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
bw<-stack(bw_layers)
env<-stack(env_layers)
### Change layer names to simpler ones
names(env) <- sub("wc2.0_bio_5m","BIO",names(env))

# Extract raster values to list object
r.vals <- extract(temperature,china )
# Calculates mean temperature across the polygon
r.mean <- unlist(lapply(r.vals, FUN=mean,na.rm=TRUE))
# Connect the data.frames
china@data <- data.frame(china@data, mean_temperature=r.mean)

r.vals <- extract(env,china )
save(r.vals,file="r_vals.R")

r.means<-lapply(r.vals, colMeans, na.rm=TRUE)
r.mean<-lapply(r.means, rbind)
r.mean<-lapply(r.mean,as.data.frame)
r.mean<- rbindlist(r.mean)
china@data <- data.frame(china@data, r.mean)

r.vals <- extract(bw[[3:6]],china )

r.mean<-lapply(r.vals,function(x){
HarvestAreaFraction<-mean(x[,1],na.rm=TRUE)
HarvestedAreasHectaresSum<-sum(x[,2],na.rm=TRUE)
HarvestedAreasHectaresMean<-mean(x[,2],na.rm=TRUE)
ProductionSum<-sum(x[,3],na.rm=TRUE)
ProductionMean<-mean(x[,3],na.rm=TRUE)
YieldPerHectare<-mean(x[,4],na.rm=TRUE)
df<-cbind(HarvestAreaFraction,HarvestedAreasHectaresSum,HarvestedAreasHectaresMean,ProductionSum,ProductionMean,YieldPerHectare)
return(df)})

r.mean<-lapply(r.mean, rbind)
r.mean<-lapply(r.mean,as.data.frame)
r.mean<- rbindlist(r.mean)

r.mean[162,3]

head(r.vals[[162]])

china@data <- data.frame(china@data, r.mean)

## Add the log of the harvested area fraction:
china@data$HrvstAF_log<-log(china@data$HarvestAreaFraction)

colnames(china@data)

china@data$BIO_O1_scaled<-scale(china@data$BIO_01)[,1]
china@data$BIO_O2_scaled<-scale(china@data$BIO_02)[,1]
china@data$BIO_O3_scaled<-scale(china@data$BIO_03)[,1]
china@data$BIO_O4_scaled<-scale(china@data$BIO_04)[,1]
china@data$BIO_O5_scaled<-scale(china@data$BIO_05)[,1]
china@data$BIO_O6_scaled<-scale(china@data$BIO_06)[,1]
china@data$BIO_O7_scaled<-scale(china@data$BIO_07)[,1]
china@data$BIO_O8_scaled<-scale(china@data$BIO_08)[,1]
china@data$BIO_O9_scaled<-scale(china@data$BIO_09)[,1]
china@data$BIO_10_scaled<-scale(china@data$BIO_10)[,1]
china@data$BIO_11_scaled<-scale(china@data$BIO_11)[,1]
china@data$BIO_12_scaled<-scale(china@data$BIO_12)[,1]
china@data$BIO_13_scaled<-scale(china@data$BIO_13)[,1]
china@data$BIO_14_scaled<-scale(china@data$BIO_14)[,1]
china@data$BIO_15_scaled<-scale(china@data$BIO_15)[,1]
china@data$BIO_16_scaled<-scale(china@data$BIO_16)[,1]
china@data$BIO_17_scaled<-scale(china@data$BIO_17)[,1]
china@data$BIO_18_scaled<-scale(china@data$BIO_18)[,1]
china@data$BIO_19_scaled<-scale(china@data$BIO_19)[,1]

### Write the shapefile with extracted data:
writeOGR(obj=china, dsn="data\\china_counties", layer="china_counties", driver="ESRI Shapefile")

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
    print(i)
    a<-unlist(adj[i])
    a<-a[a>i]
    # Add to values of Node 1
    n1<-rep(i,length(a))
    node1 <-c(node1,n1)
    # Add values of Node 2
    node2<-c(node2,a)
}

mat<-cbind(node1, node2)
write.csv(mat, file="data\\china_counties\\adjacency.csv",row.names = FALSE)

# Finally, visualise some of the data:
#spplot(china['BIO_1'] )
spplot(china['BIO_02'] )
spplot(china['HarvestAreaFraction'] )

log(china@data$HrvstAF)

china@data$HrvstAF_log<-log(china@data$HarvestAreaFraction)

colnames(china@data)


