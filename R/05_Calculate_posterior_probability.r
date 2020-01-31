
library(rgdal)
### Set working directory:
setwd("/export/home/mk843/mnt/")
#setwd("G:\\My Drive\\SDM_China\\")

### Define the size of the sample from the posterior:
n=40000
n_cnt=100

### Define the model to run
mname<-'parabolic_interactions_iCAR'
mname<-'parabolic_simple_iCAR'
stan_model<-paste('stan_models/',mname,'.stan',sep="")

### Source the functions:

source("R/square.r")
source("R/calculatePredictions.r")

### Define the paths
path2model<-paste('outputs/models/',mname,'.rds',sep="")
path2predictions <- paste('outputs/05_01_Posterior_Predictions_',mname,'.csv',sep="")
path2counterfactual <-paste('outputs/05_02_Counterfactual_predictions_',mname,'.csv',sep="")

### Load reqired data:
china<-readOGR(dsn = "data/china_data", layer = "china_data")
data<-china@data[c('BIO10_sd','BIO17_sd','BIO4_sd','BIO9_sd','npp_sd')]
fit<-readRDS(path2model)

### Extract posterior distribution for all parameters:
posterior <- rstan::extract(fit) 

### Calculate predictions
predictions<-calculatePredictions(fit, data, posterior,n,counterfactual=FALSE)

### Save predictions:

write.csv(predictions, path2predictions,col.names=FALSE, row.names=FALSE)

### Calculate the predictions for the posterior plots
### Also do counterfactual plots

means<-colMeans(data)
means<-as.data.frame(rbind(means))
means<-means[rep(seq_len(nrow(means)), each = n_cnt), ]
range<-apply(data,2,range)

for (i in 1:ncol(data)){
    print(i)
    new_data<-means
    new_data[,i]<-seq(from = range[1,i], to = range[2,i],length.out=n_cnt)
    predictions<-calculatePredictions(fit, new_data, posterior,n,counterfactual=TRUE)
    write.csv(predictions, gsub("predictions", paste("predictions",colnames(data)[i],sep="_"),path2counterfactual),col.names=FALSE, row.names=FALSE)
}

### Also calculate the predictions for the future:

### Also do counterfactual plots

data<-china@data[c('BIO10_sd','BIO17_sd','BIO4_sd','BIO9_sd','npp_sd')]
means<-colMeans(data)
means<-as.data.frame(rbind(means))
means<-means[rep(seq_len(nrow(means)), each = n_cnt), ]
range<-apply(data,2,range)

for (i in 1:ncol(data)){
    print(i)
    new_data<-means
    new_data[,i]<-seq(from = range[1,i], to = range[2,i],length.out=n_cnt)
    predictions<-calculatePredictions(fit, new_data, posterior,n,counterfactual=TRUE)
    write.csv(predictions, gsub("predictions", paste("predictions",colnames(data)[i],sep="_"),path2counterfactual), row.names=FALSE)
}

