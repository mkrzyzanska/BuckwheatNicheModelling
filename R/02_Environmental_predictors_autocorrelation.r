
#### This tests the autocorrelation between the environmental variables in the study area, across the 7 time periods
#### (6 from the past, and the present environmental layers:)
####(first just for present, then see whether you can do both past and present both for past and present:)
# Library for correlation plotting
library(corrplot)
# Library for plotting dendrogram
library(dendextend)
# library for working with data frames:
library(data.table)
# library for working with later layers
library(raster)

## Paths to existing files
## Define the path to the environmental layers from the present:
path2past <- "G:\\My Drive\\SDM_China\\data\\environmental\\past"
path2present <- "G:\\My Drive\\SDM_China\\data\\environmental\\present\\masked\\"
path2env_table<-"G:\\My Drive\\SDM_China\\outputs\\01_Predictor_variables.csv"
## Paths to the files that will be created
## Define the path to csv file with the pearson's correlation coefficients:
path2pearson <- "G:\\My Drive\\SDM_China\\outputs\\02_01_Predictors_autocorrelation.csv"
path2corrplot <- "G:\\My Drive\\SDM_China\\outputs\\02_02_Predictors_corrplot.tiff"
path2dendrogram<-"G:\\My Drive\\SDM_China\\outputs\\02_03_Predictors_dendrogram.tiff"

### Load the list of variables names (will be needed to change the names later):
var_list<-read.csv(path2env_table)

### Get list of folders that contain past environmental layers
layers<-list.files(path=path2past,full.names=TRUE)
### Include only npp, and bioclimatic variables, with the exception of BIO3, BIO14, and BIO15, as these are known to cause issues
layers<-subset(layers,lapply(layers, grepl,pattern="BIO|npp")==TRUE &lapply(layers, grepl,pattern="BIO3|BIO14|BIO15")==FALSE)
layers<-paste(layers,"//masked//",sep="")
### Get list of files in the folder for each variable
layers<-lapply(layers,list.files,full.names=TRUE, pattern=".tif")

### Make a list of stacks for each of the environmental variables:
egv_list<-lapply(layers,stack)
### Make a list of stacks grouped by perios
egv_by_period<-c()
for(i in 1:6){
a<-stack(lapply(egv_list, subset,i))
egv_by_period[[i]]<-c(a)}
egv_by_period <- unlist(egv_by_period)

### Load layers for present climatic variables:
p_layers<-list.files(path=path2present,pattern='tif',full.names=TRUE)
### Get only the layers related to bioclimatic variables and net primary productivity,
### and exclude bioclimatic variables 3, 14 and 15, because of the recommendations
p_layers<-subset(p_layers,lapply(p_layers, grepl,pattern="BIO|npp")==TRUE &lapply(p_layers, grepl,pattern="BIO3|BIO14|BIO15")==FALSE)
# Join all rasters in a single object
egv<-stack(p_layers)

egv_by_period<-append(egv,egv_by_period)

### Extract the dataframe of variables from all of the layers
prd_list<-lapply(egv_by_period,values)
prd_list<-lapply(prd_list,as.data.frame)
prd_list<-lapply(prd_list,function(x){colnames(x)<-sub('_.*','',colnames(x))
                                      return(x)})

### This merges the data frame of present predictors with a data frame of past predictors
predictors<-rbindlist(prd_list)

### Calculate the correlation coefficient matrick
pearson<-cor(predictors, method = "pearson",use="complete.obs")
write.csv(pearson, file=path2pearson,row.names=TRUE)

### Create a graph showing the correlation coefficients
### Set color palette
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
### Create a correlation plot and save it as a tiff file:
tiff(path2corrplot, units="in", width=6, height=5, res=600,bg = "transparent")
corrplot(pearson, method="color", col=col(200),  
         type="upper", order="hclust", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE,number.cex=0.4,tl.cex=0.5
         )
dev.off()

### Plot the dendrogram:
### Transform the correlation coefficient into a data.frame
cor.df<-as.data.frame(pearson)
### Change the names for plotting in the dendrogram
var_names<-colnames(cor.df)
rownames(cor.df)<-colnames(cor.df) <-unlist(lapply(var_names,function(x){return(var_list[which(var_list[,1]==x),2])}))
# Transfrom correlation matrix to distances
var.dist <- abs(as.dist(cor.df))
# Calculate dendrogram based on distance (less distance = more correlation)
var.cluster <- hclust(1-var.dist)
# Turn into dendrogram
dd<-as.dendrogram(var.cluster)

## Plot the dendrogram showing the clusters of higly correlated predictors:
labels_colors(dd) <- c("black","red","black","red","black","black","red","black","black","black","red","black","black","black","red","black")
tiff(path2dendrogram, units="in", width=6, height=8, res=100,bg = "transparent")
par(mar=c(20,4,1,0))
plot(dd, main="",ylab="distance", xlab="",sub=NA, cex=0.75,col=c("red","blue","black","yellow"))
abline(h=0.25, lty=2, lwd=2)
dev.off()
