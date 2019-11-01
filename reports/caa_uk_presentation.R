library(rstan)
library(rgdal)
library(raster)
setwd("G:\\My Drive\\SDM_China\\")
fit <- readRDS("stan_server\\buckwheat_simple_log_parabolic_all_sc.rds")
china<-readOGR(dsn = "data\\china_counties", layer = "china_counties")
posterior <- rstan::extract(fit)

### Get layers with the past data:

path2layers<-"data\\environmental\\past\\china\\"
layers<-list.files(path=path2layers,pattern='tif$',full.names=TRUE)
env<-stack(layers)
senv<-env[[c(2,9,10,12,14,19)]]
env_data <- as.data.frame(raster::extract(senv,1:ncell(senv)))
head(china@data)
env_data$BIO_09 <- scale(env_data$bcmidbi9/10,scale=attributes(scale(china@data$BIO_09))[[3]],center = attributes(scale(china@data$BIO_09))[[2]])
env_data$BIO_18 <- scale(env_data$bcmidbi18,scale=attributes(scale(china@data$BIO_18))[[3]],center = attributes(scale(china@data$BIO_18))[[2]])
env_data$BIO_04 <- scale(env_data$bcmidbi4/10,scale=attributes(scale(china@data$BIO_04))[[3]],center = attributes(scale(china@data$BIO_04))[[2]])
env_data$BIO_10 <- scale(env_data$bcmidbi10/10,scale=attributes(scale(china@data$BIO_10))[[3]],center = attributes(scale(china@data$BIO_10))[[2]])
env_data$BIO_17 <- scale(env_data$bcmidbi17,scale=attributes(scale(china@data$BIO_17))[[3]],center = attributes(scale(china@data$BIO_17))[[2]])
env_data$BIO_02 <- scale(env_data$bcmidbi2/10,scale=attributes(scale(china@data$BIO_02))[[3]],center = attributes(scale(china@data$BIO_02))[[2]])

path2layers2<-"data\\environmental\\china\\"
layers2<-list.files(path=path2layers2,pattern='tif$',full.names=TRUE)
env2<-stack(layers2)
senv2<-env2[[c(2,4,9,10,17,18)]]
env_data2 <- as.data.frame(raster::extract(senv2,1:ncell(senv2)))

env_data2$BIO_09 <- scale(env_data2$wc2.0_bio_5m_09,scale=attributes(scale(china@data$BIO_09))[[3]],center = attributes(scale(china@data$BIO_09))[[2]])
env_data2$BIO_18 <- scale(env_data2$wc2.0_bio_5m_18,scale=attributes(scale(china@data$BIO_18))[[3]],center = attributes(scale(china@data$BIO_18))[[2]])
env_data2$BIO_04 <- scale(env_data2$wc2.0_bio_5m_04,scale=attributes(scale(china@data$BIO_04))[[3]],center = attributes(scale(china@data$BIO_04))[[2]])
env_data2$BIO_10 <- scale(env_data2$wc2.0_bio_5m_10,scale=attributes(scale(china@data$BIO_10))[[3]],center = attributes(scale(china@data$BIO_10))[[2]])
env_data2$BIO_17 <- scale(env_data2$wc2.0_bio_5m_17,scale=attributes(scale(china@data$BIO_17))[[3]],center = attributes(scale(china@data$BIO_17))[[2]])
env_data2$BIO_02 <- scale(env_data2$wc2.0_bio_5m_02,scale=attributes(scale(china@data$BIO_02))[[3]],center = attributes(scale(china@data$BIO_02))[[2]])

### That's for china data

china@data$predictions<-mean(posterior$alpha)+ mean(posterior$beta1)*china@data$BIO_O9_ + mean(posterior$beta2)*(china@data$BIO_O9_^2)+
  mean(posterior$beta3)*china@data$BIO_18_ + mean(posterior$beta4)*(china@data$BIO_18_^2)+
  mean(posterior$beta5)*china@data$BIO_O4_ + mean(posterior$beta6)*(china@data$BIO_O4_^2)+
  mean(posterior$beta7)*china@data$BIO_10_ + mean(posterior$beta8)*(china@data$BIO_10_^2)+
  mean(posterior$beta9)*china@data$BIO_17_ + mean(posterior$beta10)*(china@data$BIO_17_^2)+
  mean(posterior$beta11)*china@data$BIO_O2_ + mean(posterior$beta12)*(china@data$BIO_O2_^2)

### And thats for environmental data:

env_data$predictions1<-mean(posterior$alpha)+ mean(posterior$beta1)*env_data$BIO_09 + mean(posterior$beta2)*(env_data$BIO_09^2)+
  mean(posterior$beta3)*env_data$BIO_18 + mean(posterior$beta4)*(env_data$BIO_18^2)+
  mean(posterior$beta5)*env_data$BIO_04 + mean(posterior$beta6)*(env_data$BIO_04^2)+
  mean(posterior$beta7)*env_data$BIO_10 + mean(posterior$beta8)*(env_data$BIO_10^2)+
  mean(posterior$beta9)*env_data$BIO_17 + mean(posterior$beta10)*(env_data$BIO_17^2)+
  mean(posterior$beta11)*env_data$BIO_02 + mean(posterior$beta12)*(env_data$BIO_02^2)


env_data2$predictions1<-mean(posterior$alpha)+ mean(posterior$beta1)*env_data2$BIO_09 + mean(posterior$beta2)*(env_data2$BIO_09^2)+
  mean(posterior$beta3)*env_data2$BIO_18 + mean(posterior$beta4)*(env_data2$BIO_18^2)+
  mean(posterior$beta5)*env_data2$BIO_04 + mean(posterior$beta6)*(env_data2$BIO_04^2)+
  mean(posterior$beta7)*env_data2$BIO_10 + mean(posterior$beta8)*(env_data2$BIO_10^2)+
  mean(posterior$beta9)*env_data2$BIO_17 + mean(posterior$beta10)*(env_data2$BIO_17^2)+
  mean(posterior$beta11)*env_data2$BIO_02 + mean(posterior$beta12)*(env_data2$BIO_02^2)

a<-attributes(scale(china@data$BIO_09))
a

at<-c(-Inf,-35,-30,-25,-20,-15,-10,-5,0,5,10)

at<-c(-Inf,-35,-20,-15,-10,-5,0,10)
spplot(china['predictions'], at=at)

### Also get the plot of the past predictions

at<-c(-35,-20,-15,-10,-5,0,10)

pred.mean <- senv[[1]]
pred.mean2 <- senv2[[1]]
pred.mean[]<-env_data$predictions1
pred.mean2[]<-env_data2$predictions1
plot(pred.mean,col=colorRampPalette(c('grey','white','yellow','orange','red','brown'))(10),breaks=at)


summary(env_data$predictions1)
summary(china@data$predictions)

col.regions=colorRampPalette(c('blue', 'gray80','red'))(5)
spplot(china['HrvsAF_'], at=at,col.regions=colorRampPalette(c('grey',"blue",'darkgreen','yellow','orange','red','brown'))(10))
spplot(china['predictions'], at=at,col.regions=colorRampPalette(c('grey','white','yellow','orange','red','brown'))(10))

### Plot present predictions:

spplot(china['HrvsAF_'], at=at,col.regions=colorRampPalette(c('grey','white','yellow','orange','red','brown'))(10))
spplot(china['predictions'], at=at,col.regions=colorRampPalette(c('grey','white','yellow','orange','red','brown'))(10))

### Plot past extrapolation:
plot(pred.mean,col=colorRampPalette(c('white','yellow','orange','red','brown'))(7), breaks=c(-16,-14,-12,-10,-8,-6,-4),axes=FALSE)
plot(pred.mean2,col=colorRampPalette(c('white','yellow','orange','red','brown'))(7), breaks=c(-16,-14,-12,-10,-8,-6,-4),axes=FALSE)
spplot(china['predictions'],col.regions=colorRampPalette(c('white','yellow','orange','red','brown'))(7),at=c(-16,-14,-12,-10,-8,-6,-4),col="transparent")


spplot(china['HrvsAF_'],col.regions=colorRampPalette(c('black','grey','white','yellow','orange','red','brown','saddlebrown'))(11),at=c(-35,-20,-16,-14,-12,-10,-8,-6,-4,10),
       col="transparent")


par(fg="white",bg = 'black')

png("pres6.png", units="in", width=8, height=6, res=300)

par(mfrow=c(7,2),oma=c(2,1,2,1),mar=c(1,4,1,4))
plot(posterior$alpha, type = "l")
plot(posterior$sigma, type = "l")
plot(posterior$beta1, type = "l")
plot(posterior$beta2, type = "l")
plot(posterior$beta3, type = "l")
plot(posterior$beta4, type = "l")
plot(posterior$beta5, type = "l")
plot(posterior$beta6, type = "l")
plot(posterior$beta7, type = "l")
plot(posterior$beta8, type = "l")
plot(posterior$beta9, type = "l")
plot(posterior$beta10, type = "l")
plot(posterior$beta11, type = "l")
plot(posterior$beta12, type = "l")

png("pres7.png", units="in", width=8, height=6, res=300)

par(mfrow=c(2,3),mar=c(4,1,1,1))

#####Plots counterfactual plot for BIO2

plot(china@data$HrvsAF_~china@data$BIO_O2 , pch = 20,xlab="Mean Diurnal Range",ylab="")

x0 <- seq(min(china@data$BIO_O2_), max(china@data$BIO_O2_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_O2), max(china@data$BIO_O2), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*x0 + mean(posterior$beta12)*(x0^2)

y1 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  summary(fit,"beta11",probs=0.05)$summary[4]*x0 + summary(fit,"beta12",probs=0.05)$summary[4]*(x0^2)

y2 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  summary(fit,"beta11",probs=0.95)$summary[4]*x0 + summary(fit,"beta12",probs=0.95)$summary[4]*(x0^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)


#####Plots counterfactual plot for BIO4

plot(china@data$HrvsAF_~china@data$BIO_O4 , pch = 20,xlab="Temperature Seasonality",ylab="")

x0 <- seq(min(china@data$BIO_O4_), max(china@data$BIO_O4_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_O4), max(china@data$BIO_O4), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*x0 + mean(posterior$beta6)*(x0^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y1 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  summary(fit,"beta5",probs=0.05)$summary[4]*x0 + summary(fit,"beta6",probs=0.05)$summary[4]*(x0^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y2 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  summary(fit,"beta5",probs=0.95)$summary[4]*x0 + summary(fit,"beta6",probs=0.95)$summary[4]*(x0^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)

#####Plots counterfactual plot for BIO9
plot(china@data$HrvsAF_~china@data$BIO_O9 , pch = 20,xlab="Mean Temperature of Driest Quarter",ylab="")

x0 <- seq(min(china@data$BIO_O9_), max(china@data$BIO_O9_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_O9), max(china@data$BIO_O9), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*x0 + mean(posterior$beta2)*x0^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y1 <-  mean(posterior$alpha)+ summary(fit,"beta1",probs=0.05)$summary[4]*x0 + summary(fit,"beta2",probs=0.05)$summary[4]*x0^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y2 <-  mean(posterior$alpha)+ summary(fit,"beta1",probs=0.95)$summary[4]*x0 + summary(fit,"beta2",probs=0.95)$summary[4]*x0^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)

#####Plots counterfactual plot for BIO10

plot(china@data$HrvsAF_~china@data$BIO_10 , pch = 20,xlab="Mean Temperature of the Warmest Quarter",ylab="")

x0 <- seq(min(china@data$BIO_10_), max(china@data$BIO_10_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_10), max(china@data$BIO_10), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*x0 + mean(posterior$beta8)*(x0^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y1 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  summary(fit,"beta7",probs=0.05)$summary[4]*x0 + summary(fit,"beta8",probs=0.05)$summary[4]*(x0^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y2 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  summary(fit,"beta7",probs=0.95)$summary[4]*x0 + summary(fit,"beta8",probs=0.95)$summary[4]*(x0^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)

#####Plots counterfactual plot for BIO17

plot(china@data$HrvsAF_~china@data$BIO_17 , pch = 20,xlab="Precipitation of Driest Quarter",ylab="")

x0 <- seq(min(china@data$BIO_17_), max(china@data$BIO_17_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_17), max(china@data$BIO_17), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*x0 + mean(posterior$beta10)*(x0^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y1 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  summary(fit,"beta9",probs=0.05)$summary[4]*x0 + summary(fit,"beta10",probs=0.05)$summary[4]*(x0^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)

y2 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  summary(fit,"beta9",probs=0.95)$summary[4]*x0 + summary(fit,"beta10",probs=0.95)$summary[4]*(x0^2)+
  mean(posterior$beta11)*mean(china@data$BIO_O2_) + mean(posterior$beta12)*(mean(china@data$BIO_O2_)^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)

#####Plots counterfactual plot for BIO18

plot(china@data$HrvsAF_~china@data$BIO_18 , pch = 20,xlab="Precipitation of the Warmest Quarter")

x0 <- seq(min(china@data$BIO_18_), max(china@data$BIO_18_), length = 20)  ## prediction grid
x1 <- seq(min(china@data$BIO_18), max(china@data$BIO_18), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  mean(posterior$beta11)*x0 + mean(posterior$beta12)*(x0^2)

y1 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  summary(fit,"beta11",probs=0.05)$summary[4]*x0 + summary(fit,"beta12",probs=0.05)$summary[4]*(x0^2)

y2 <-  mean(posterior$alpha)+ mean(posterior$beta1)*mean(china@data$BIO_O9_) + mean(posterior$beta2)*mean(china@data$BIO_O9_)^2+
  mean(posterior$beta3)*mean(china@data$BIO_18_) + mean(posterior$beta4)*(mean(china@data$BIO_18_)^2)+
  mean(posterior$beta5)*mean(china@data$BIO_O4_) + mean(posterior$beta6)*(mean(china@data$BIO_O4_)^2)+
  mean(posterior$beta7)*mean(china@data$BIO_10_) + mean(posterior$beta8)*(mean(china@data$BIO_10_)^2)+
  mean(posterior$beta9)*mean(china@data$BIO_17_) + mean(posterior$beta10)*(mean(china@data$BIO_17_)^2)+
  summary(fit,"beta11",probs=0.95)$summary[4]*x0 + summary(fit,"beta12",probs=0.95)$summary[4]*(x0^2)


lines(x1, y1, col = "grey",lwd=1)
lines(x1, y2, col = "grey",lwd=1)
polygon(c(x1, rev(x1)), c(y1, rev(y2)),col = "lightgrey", border = NA, angle=45)
lines(x1, y0, col = "red",lwd=1)



