
### Set working directory:
setwd("/export/home/mk843/mnt/")
#setwd("G:\\My Drive\\SDM_China\\")

### Define the model to run
mname<-'parabolic_simple_iCAR'
stan_model<-paste('stan_models/',mname,'.stan',sep="")

### Define model parameters:

warmup=2000
iter=50000
chains=5
cores=5
thin=1

### Define the path in which to save models:
path2models<-"outputs/models/"

### Load libraries
library(rstan)
library(rgdal)

### Load data
china<-readOGR(dsn = "data/china_data", layer = "china_data")
### Get the data on counties adjacency
adjacency<-read.csv("data/china_data/adjacency.csv")

### Get the adjacent nodes from the matrix:
node1<-adjacency$node1
node2<-adjacency$node2
N_edges<-length(node1)
N<-nrow(china@data)

# Defince stan data:
y=china@data$logArea
x1=china@data$BIO10_sd
x2=china@data$BIO17_sd
x3=china@data$BIO4_sd
x4=china@data$BIO9_sd
x5=china@data$npp_sd

#Format the data
stan_data <- list(N = N, x1 = x1, y = y,x2=x2,x3=x3,x4=x4,x5=x5,N_edges=N_edges,node1=node1,node2=node2)

print("Fitting the model")

fit <- stan(file = stan_model, data = stan_data, warmup = warmup, iter = iter, chains = chains, cores = cores, thin = thin)

print("Saving the model")
saveRDS(fit, paste(path2models, mname,".rds",sep="")) 
