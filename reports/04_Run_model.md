
# Run model

This runs the stun model as defined in a Stan file provided, for the 5 environmental variables used as predictors, and fraction of the cultivated area used as a response variable. It assumes that the model is located in the 'stan_models' directory.

## Variables to be defined:

*@mname - name of a model  
@warmup - number of warmup iterations  
@iter - overall number of iterations  
@chains - number of chains  
@corese - number of cores  
@thin - thin*  


```R
### Set working directory:
setwd("/export/home/mk843/mnt/")

### Define the model to run
mname<-'parabolic_simple_iCAR'
stan_model<-paste('stan_models/',mname,'.stan',sep="")

### Define model parameters:

warmup=2000
iter=10000
chains=4
cores=4
thin=1

### Define the path in which to save models:
path2models<-"outputs/models/"
```

## Load libraries and data


```R
### Load libraries
library(rstan)
library(rgdal)

### Load data
china<-readOGR(dsn = "data/china_data", layer = "china_data")
### Get the data on counties adjacency
adjacency<-read.csv("data/china_data/adjacency.csv")
```

## Format data


```R
### Get the adjacent nodes from the matrix:
node1<-adjacency$node1
node2<-adjacency$node2
N_edges<-length(node1)
N<-nrow(china@data)

# Defince stan data:
y=china@data$logArea
x1=china@data$BIO10_sd
x2=china@data$BIO11_sd
x3=china@data$BIO19_sd
x4=china@data$BIO4_sd
x5=china@data$npp_sd

#Format the data
stan_data <- list(N = N, x1 = x1, y = y,x2=x2,x3=x3,x4=x4,x5=x5,N_edges=N_edges,node1=node1,node2=node2)
```

## Run and save model


```R
print("Fitting the model")

fit <- stan(file = stan_model, data = stan_data, warmup = warmup, iter = iter, chains = chains, cores = cores, thin = thin)

print("Saving the model")
saveRDS(fit, paste(path2models, mname,".rds",sep="")) 
```