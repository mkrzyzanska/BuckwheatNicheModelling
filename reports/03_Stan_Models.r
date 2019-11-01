
setwd("G:\\My Drive\\SDM_China")
library("rstan")
library(gdata)
#library(bayesplot)
library(raster)
library(rgdal)
library(sp)
library(spdep)
library(data.table)

### Get data on China
china<-readOGR(dsn = "data\\china_counties", layer = "china_counties")

### Get the data on counties adjacency
adjacency<-read.csv("data\\china_counties\\adjacency.csv")
node1<-adjacency$node1
node2<-adjacency$node2
N_edges<-length(node1)
N<-nrow(china@data)

### Define Stan model
write("// Stan model for simple linear regression

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 vector[N] x; // Predictor is a vector of the size of sample size
 vector[N] y; // Outcome is a vector of a size of sample size
}

parameters {
 real alpha; // Intercept is an unconstrained continous value
 real beta; // Slope (regression coefficients) is an unconstrained continous value
 real beta2; // Slope (regression coefficients) is an unconstrained continous value
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous valeu
}

model {
 log (y) ~ normal(alpha + x * beta + square(x) * beta2 , sigma); //this seem to declare the model
}
generated quantities {
} // The posterior predictive distribution",

"stan_models\\buckwheat_simple_log_BIO9_2.stan")

stan_model <- "stan_models\\buckwheat_simple_log_BIO9_2.stan"

colnames(china@data)

x<-china@data$BIO_09
y<-china@data$HrvstAF
y[y == 0] <- 1.0e-14
logy<-log(y)

stan_data <- list(N = N, x = x, y = y)

colnames(china@data)

str(stan_data)

fit <- stan(file = stan_model, data = stan_data, warmup = 500, iter = 1000, chains = 4, cores = 8, thin = 1)

save(fit, file="stan_models\\buckwheat_simple_log_BIO9_2.R")

### Extract posterios distribution
posterior <- rstan::extract(fit)
str(posterior)

fit

colnames(china@data)

plot(logy ~ x, pch = 20)

## This predicts the values for lm model:
x0 <- seq(min(x), max(x), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha) + mean(posterior$beta)*x0 + mean(posterior$beta2)*(x0^2) ## predicted values
lines(x0, y0, col = "red",lwd=3)
y1 <-  quantile(posterior$alpha)[[2]] + quantile(posterior$beta)[[2]]*x0 + quantile(posterior$beta2)[[2]]*(x0^2) ## predicted values
lines(x0, y0, col = "blue",lwd=1)
y1 <-  quantile(posterior$alpha)[[3]] + quantile(posterior$beta)[[3]]*x0 + quantile(posterior$beta2)[[3]]*(x0^2) ## predicted values
lines(x0, y0, col = "blue",lwd=1)

plot(posterior$alpha, type = "l")
plot(posterior$beta, type = "l")
plot(posterior$beta2, type = "l")
plot(posterior$sigma, type = "l")

### Now plot predictions vs real value:
china@data$predictions<-mean(posterior$alpha) + mean(posterior$beta)*china@data$BIO_09 + mean(posterior$beta2)*(china@data$BIO_09^2)

head(china@data$predictions)

head(china@data$HrvstAF)

par(mfrow=c(1,2))

#at <- c(0,0.000015,0,0001,0.00015,0.005,0.01,0.015,0.02,0.025,0.03,0.035)
#at <- c(0.0015,0.05,0.1,0.15,0.2,0.25,0.3,0.35)
at<-c(-Inf,-35,-30,-25,-20,-15,-10,-5,0,5,10)
spplot(china['HrvsAF_'], at=at)
spplot(china['predictions'], at=at)

spplot(china['BIO_09'] )

write("// Stan model for simple linear (parabolic) regression

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 vector[N] x1; // Predictor is a vector of the size of sample size
 vector[N] x2; // Predictor is a vector of the size of sample size
 vector[N] x3; // Predictor is a vector of the size of sample size
 vector[N] x4; // Predictor is a vector of the size of sample size
 vector[N] x5; // Predictor is a vector of the size of sample size
 vector[N] x6; // Predictor is a vector of the size of sample size
 vector[N] y; // Outcome is a vector of a size of sample size
}

parameters {
 real alpha; // Intercept is an unconstrained continous value
 real beta1; // Slope (regression coefficients) is an unconstrained continous value
 real beta2; // Slope (regression coefficients) is an unconstrained continous value
 real beta3; // Slope (regression coefficients) is an unconstrained continous value
 real beta4; // Slope (regression coefficients) is an unconstrained continous value
 real beta5; // Slope (regression coefficients) is an unconstrained continous value
 real beta6; // Slope (regression coefficients) is an unconstrained continous value
 real beta7; // Slope (regression coefficients) is an unconstrained continous value
 real beta8; // Slope (regression coefficients) is an unconstrained continous value
 real beta9; // Slope (regression coefficients) is an unconstrained continous value
 real beta10; // Slope (regression coefficients) is an unconstrained continous value
 real beta11; // Slope (regression coefficients) is an unconstrained continous value
 real beta12; // Slope (regression coefficients) is an unconstrained continous value
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous valeu
}

model {
 log (y) ~ normal(alpha + x1 * beta1 + square(x1) * beta2 + x2 * beta3 + square(x2) * beta4 +
                          x3 * beta5 + square(x3) * beta6 + x4 * beta7 + square(x4) * beta8 +
                          x5 * beta9 + square(x5) * beta10 + x6 * beta11 + square(x6) * beta12, sigma); //this seem to declare the model
}
generated quantities {
} // The posterior predictive distribution",

"stan_models\\buckwheat_log_parabolic_regression.stan")

x1<-china@data$BIO_09
x2<-china@data$BIO_02
x3<-china@data$BIO_04
x4<-china@data$BIO_10
x5<-china@data$BIO_17
x6<-china@data$BIO_18
y<-china@data$HrvstAF
y[y == 0] <- 1.0e-14

stan_model <- "stan_models\\buckwheat_log_parabolic_regression.stan"

stan_data <- list(N = N, x1 = x1, y = y,x2=x2,x3=x3,x4=x4,x5=x5,x6=x6)

str(stan_data)

fit <- stan(file = stan_model, data = stan_data, warmup = 2000, iter = 10000, chains = 4, cores = 2, thin = 1)

fit

posterior <- rstan::extract(fit)

plot(posterior$alpha, type = "l")
plot(posterior$beta1, type = "l")
plot(posterior$beta2, type = "l")
plot(posterior$sigma, type = "l")

save(fit, file="stan_models\\buckwheat_log_parabolic_regression.R")

load("stan_models\\buckwheat_simple_BIO9_2.R")

pairs(fit)



stan_model <- "stan_models\\buckwheat_simple_icar1.stan"

icar_stan = stan_model(stan_model);

fit_stan = sampling(icar_stan, data=list(N,N_edges,node1,node2), control=list(adapt_delta = 0.97, stepsize = 0.1), chains=2, warmup=9000, iter=10000, save_warmup=FALSE);

save(fit_stan, file="stan_models\\buckwheat_simple_icar02.R")

write("// Stan model for simple linear regression

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 vector[N] x; // Predictor is a vector of the size of sample size
 vector[N] y; // Outcome is a vector of a size of sample size
}

parameters {
 real alpha; // Intercept is an unconstrained continous value
 real beta; // Slope (regression coefficients) is an unconstrained continous value
 real beta2; // Slope (regression coefficients) is an unconstrained continous value
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous valeu
}

model {
 log (y) ~ normal(alpha + x * beta + square(x) * beta2 , sigma); //this seem to declare the model
}
generated quantities {
} // The posterior predictive distribution",

"stan_models\\buckwheat_simple_log_BIO9_2.stan")

str(fit_stan)


