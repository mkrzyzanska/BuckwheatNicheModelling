
# Set working directory to the github folder:
setwd("G:\\My Drive\\SDM_China")
library("rstan")
library("raster")
library("gdata")
#library("bayesplot")

path2prod<-"data\\buckwheat_production\\china\\buckwheat_Production.tif"
buckwheat<-raster(path2prod)

# Prepares the raster stack with all the data:
path2env<-"data\\environmental\\china\\"
layers<-list.files(path=path2env,pattern='tif$',full.names=TRUE)
d<-stack(c(buckwheat,layers[c(2,4,9,10,17,18)]))

N<-ncell(d[[1]][!is.na(d[[1]])])

#Get the cell numbers which are not na:
cellnb.na <- Which(!is.na(d[[1]]), cells = TRUE) 
N<-length(cellnb.na);

# This creates a neighbourhood matrix with from and to (but only for cells that are not na, with both source and target cells)
neighbors.mat<-adjacent(d, cells=cellnb.na, directions=8, pairs=TRUE, target=cellnb.na, sorted=TRUE) 
neighbors.mat<-subset(neighbors.mat, neighbors.mat[,2]>neighbors.mat[,1])

N_edges <- nrow(neighbors.mat);
node1 <- neighbors.mat[,1];
node2 <- neighbors.mat[,2];

data <- as.data.frame(extract(d,cellnb.na))
data$n<-cellnb.na

head(data)

# Plot
plot(buckwheat_Production ~ wc2.0_bio_5m_09, pch = 20, data = data)

lm1 <- lm(buckwheat_Production ~ wc2.0_bio_5m_09, data = data)
summary(lm1)

plot(buckwheat_Production ~ wc2.0_bio_5m_09, pch = 20, data = data)
abline(lm1, col = 2, lty = 2, lw = 3)

x <- data$wc2.0_bio_5m_09 # Independent variable - will be an equivalent of temperature, etc.
y <- data$buckwheat_Production # Dependent variable  - equivalent of buckwheat production
N <- nrow(data) # Number of observations

stan_data <- list(N = N, x = x, y = y)

write("// Stan model for simple linear regression

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 vector[N] x; // Predictor is a vector of the size of sample size
 vector[N] y; // Outcome is a vector of a size of sample size
}

parameters {
 real alpha; // Intercept is an unconstrained continous value
 real beta; // Slope (regression coefficients) is an unconstrained continous value
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous valeu
}

model {
 y ~ normal(alpha + x * beta , sigma); //this seem to declare the model
}
generated quantities {
} // The posterior predictive distribution",

"stan_model1.stan")

stan_model1 <- "stan_model1.stan"

fit <- stan(file = stan_model1, data = stan_data, warmup = 500, iter = 1000, chains = 4, cores = 2, thin = 1)

fit

posterior <- rstan::extract(fit)
str(posterior)

plot(y ~ x, pch = 20)

abline(lm1, col = 2, lty = 2, lw = 3)
abline( mean(posterior$alpha), mean(posterior$beta), col = 6, lw = 2)

plot(y ~ x, pch = 20)

abline(lm1, col = 2, lty = 2, lw = 3)
abline( mean(posterior$alpha), mean(posterior$beta), col = 6, lw = 2)
for (i in 1:2000) {
 abline(posterior$alpha[i], posterior$beta[i], col = "gray", lty = 1)
}

plot(posterior$alpha, type = "l")
plot(posterior$beta, type = "l")
plot(posterior$sigma, type = "l")


par(mfrow = c(1,3))

plot(density(posterior$alpha), main = "Alpha")
#abline(v = lm_alpha, col = 4, lty = 2)

plot(density(posterior$beta), main = "Beta")
#abline(v = lm_beta, col = 4, lty = 2)

plot(density(posterior$sigma), main = "Sigma")
#abline(v = lm_sigma, col = 4, lty = 2)

writeLines(readLines('stan_models\\simple_iar.stan'))

icar_stan = stan_model("stan_models\\simple_iar.stan")

icar_stan

fit_stan = sampling(icar_stan, data=list(N,N_edges,node1,node1), control=list(adapt_delta = 0.97, stepsize = 0.1), chains=2, warmup=9000, iter=10000, save_warmup=FALSE);

# This can

N
N_edges
length(node1)

fit_icar_stan = sampling(icar_stan, data=list(N,N_edges,node1,node2), chains=3, warmup=4000, iter=5000, save_warmup=FALSE)

N_edges

length(node1)
