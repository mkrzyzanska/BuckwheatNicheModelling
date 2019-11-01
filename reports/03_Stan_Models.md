

```R
setwd("G:\\My Drive\\SDM_China")
library("rstan")
library(gdata)
#library(bayesplot)
library(raster)
library(rgdal)
library(sp)
library(spdep)
library(data.table)
```

    Warning message:
    "package 'rstan' was built under R version 3.4.4"Loading required package: ggplot2
    Warning message:
    "package 'ggplot2' was built under R version 3.4.4"Loading required package: StanHeaders
    Warning message:
    "package 'StanHeaders' was built under R version 3.4.4"rstan (Version 2.18.2, GitRev: 2e1f913d3ca3)
    For execution on a local, multicore CPU with excess RAM we recommend calling
    options(mc.cores = parallel::detectCores()).
    To avoid recompilation of unchanged Stan programs, we recommend calling
    rstan_options(auto_write = TRUE)
    For improved execution time, we recommend calling
    Sys.setenv(LOCAL_CPPFLAGS = '-march=native')
    although this causes Stan to throw an error on a few processors.
    Warning message:
    "package 'gdata' was built under R version 3.4.4"gdata: Unable to locate valid perl interpreter
    gdata: 
    gdata: read.xls() will be unable to read Excel XLS and XLSX files
    gdata: unless the 'perl=' argument is used to specify the location of a
    gdata: valid perl intrpreter.
    gdata: 
    gdata: (To avoid display of this message in the future, please ensure
    gdata: perl is installed and available on the executable search path.)
    gdata: Unable to load perl libaries needed by read.xls()
    gdata: to support 'XLX' (Excel 97-2004) files.
    
    gdata: Unable to load perl libaries needed by read.xls()
    gdata: to support 'XLSX' (Excel 2007+) files.
    
    gdata: Run the function 'installXLSXsupport()'
    gdata: to automatically download and install the perl
    gdata: libaries needed to support Excel XLS and XLSX formats.
    
    Attaching package: 'gdata'
    
    The following object is masked from 'package:stats':
    
        nobs
    
    The following object is masked from 'package:utils':
    
        object.size
    
    The following object is masked from 'package:base':
    
        startsWith
    
    Warning message:
    "package 'raster' was built under R version 3.4.4"Loading required package: sp
    Warning message:
    "package 'sp' was built under R version 3.4.4"
    Attaching package: 'raster'
    
    The following objects are masked from 'package:gdata':
    
        resample, trim
    
    The following object is masked from 'package:rstan':
    
        extract
    
    Warning message:
    "package 'rgdal' was built under R version 3.4.4"rgdal: version: 1.3-6, (SVN revision 773)
     Geospatial Data Abstraction Library extensions to R successfully loaded
     Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
     Path to GDAL shared files: D:/Programs/R/R-3.4.1/library/rgdal/gdal
     GDAL binary built with GEOS: TRUE 
     Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
     Path to PROJ.4 shared files: D:/Programs/R/R-3.4.1/library/rgdal/proj
     Linking to sp version: 1.3-1 
    Warning message:
    "package 'spdep' was built under R version 3.4.4"Loading required package: spData
    Warning message:
    "package 'spData' was built under R version 3.4.4"To access larger datasets in this package, install the spDataLarge
    package with: `install.packages('spDataLarge',
    repos='https://nowosad.github.io/drat/', type='source')`
    Loading required package: sf
    Warning message:
    "package 'sf' was built under R version 3.4.4"Linking to GEOS 3.6.1, GDAL 2.2.3, proj.4 4.9.3
    Warning message:
    "package 'data.table' was built under R version 3.4.4"
    Attaching package: 'data.table'
    
    The following object is masked from 'package:raster':
    
        shift
    
    The following objects are masked from 'package:gdata':
    
        first, last
    
    


```R
### Get data on China
china<-readOGR(dsn = "data\\china_counties", layer = "china_counties")
```

    OGR data source with driver: ESRI Shapefile 
    Source: "G:\My Drive\SDM_China\data\china_counties", layer: "china_counties"
    with 2409 features
    It has 39 fields
    


```R
### Get the data on counties adjacency
adjacency<-read.csv("data\\china_counties\\adjacency.csv")
node1<-adjacency$node1
node2<-adjacency$node2
N_edges<-length(node1)
N<-nrow(china@data)
```


```R
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
```


```R
stan_model <- "stan_models\\buckwheat_simple_log_BIO9_2.stan"
```


```R
colnames(china@data)
```


<ol class=list-inline>
	<li>'ID_0'</li>
	<li>'ISO'</li>
	<li>'NAME_0'</li>
	<li>'ID_1'</li>
	<li>'NAME_1'</li>
	<li>'ID_2'</li>
	<li>'NAME_2'</li>
	<li>'ID_3'</li>
	<li>'NAME_3'</li>
	<li>'TYPE_3'</li>
	<li>'ENGTYPE'</li>
	<li>'NL_NAME'</li>
	<li>'VARNAME'</li>
	<li>'BIO_01'</li>
	<li>'BIO_02'</li>
	<li>'BIO_03'</li>
	<li>'BIO_04'</li>
	<li>'BIO_05'</li>
	<li>'BIO_06'</li>
	<li>'BIO_07'</li>
	<li>'BIO_08'</li>
	<li>'BIO_09'</li>
	<li>'BIO_10'</li>
	<li>'BIO_11'</li>
	<li>'BIO_12'</li>
	<li>'BIO_13'</li>
	<li>'BIO_14'</li>
	<li>'BIO_15'</li>
	<li>'BIO_16'</li>
	<li>'BIO_17'</li>
	<li>'BIO_18'</li>
	<li>'BIO_19'</li>
	<li>'HrvstAF'</li>
	<li>'HrvsAHS'</li>
	<li>'HrvsAHM'</li>
	<li>'PrdctnS'</li>
	<li>'PrdctnM'</li>
	<li>'YldPrHc'</li>
	<li>'HrvsAF_'</li>
</ol>




```R
x<-china@data$BIO_09
y<-china@data$HrvstAF
y[y == 0] <- 1.0e-14
logy<-log(y)
```


```R
stan_data <- list(N = N, x = x, y = y)
```


```R
colnames(china@data)
```


<ol class=list-inline>
	<li>'ID_0'</li>
	<li>'ISO'</li>
	<li>'NAME_0'</li>
	<li>'ID_1'</li>
	<li>'NAME_1'</li>
	<li>'ID_2'</li>
	<li>'NAME_2'</li>
	<li>'ID_3'</li>
	<li>'NAME_3'</li>
	<li>'TYPE_3'</li>
	<li>'ENGTYPE'</li>
	<li>'NL_NAME'</li>
	<li>'VARNAME'</li>
	<li>'BIO_01'</li>
	<li>'BIO_02'</li>
	<li>'BIO_03'</li>
	<li>'BIO_04'</li>
	<li>'BIO_05'</li>
	<li>'BIO_06'</li>
	<li>'BIO_07'</li>
	<li>'BIO_08'</li>
	<li>'BIO_09'</li>
	<li>'BIO_10'</li>
	<li>'BIO_11'</li>
	<li>'BIO_12'</li>
	<li>'BIO_13'</li>
	<li>'BIO_14'</li>
	<li>'BIO_15'</li>
	<li>'BIO_16'</li>
	<li>'BIO_17'</li>
	<li>'BIO_18'</li>
	<li>'BIO_19'</li>
	<li>'HrvstAF'</li>
	<li>'HrvsAHS'</li>
	<li>'HrvsAHM'</li>
	<li>'PrdctnS'</li>
	<li>'PrdctnM'</li>
	<li>'YldPrHc'</li>
	<li>'HrvsAF_'</li>
</ol>




```R
str(stan_data)
```

    List of 3
     $ N: int 2409
     $ x: num [1:2409] 5.76 6.29 4.86 7.84 7.11 ...
     $ y: num [1:2409] 0.000684 0.000457 0.000234 0.000237 0.000249 ...
    


```R
fit <- stan(file = stan_model, data = stan_data, warmup = 500, iter = 1000, chains = 4, cores = 8, thin = 1)
```

    
    SAMPLING FOR MODEL 'buckwheat_simple_log_BIO9_2' NOW (CHAIN 1).
    Chain 1: 
    Chain 1: Gradient evaluation took 0 seconds
    Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
    Chain 1: Adjust your expectations accordingly!
    Chain 1: 
    Chain 1: 
    Chain 1: Iteration:   1 / 1000 [  0%]  (Warmup)
    Chain 1: Iteration: 100 / 1000 [ 10%]  (Warmup)
    Chain 1: Iteration: 200 / 1000 [ 20%]  (Warmup)
    Chain 1: Iteration: 300 / 1000 [ 30%]  (Warmup)
    Chain 1: Iteration: 400 / 1000 [ 40%]  (Warmup)
    Chain 1: Iteration: 500 / 1000 [ 50%]  (Warmup)
    Chain 1: Iteration: 501 / 1000 [ 50%]  (Sampling)
    Chain 1: Iteration: 600 / 1000 [ 60%]  (Sampling)
    Chain 1: Iteration: 700 / 1000 [ 70%]  (Sampling)
    Chain 1: Iteration: 800 / 1000 [ 80%]  (Sampling)
    Chain 1: Iteration: 900 / 1000 [ 90%]  (Sampling)
    Chain 1: Iteration: 1000 / 1000 [100%]  (Sampling)
    Chain 1: 
    Chain 1:  Elapsed Time: 3.911 seconds (Warm-up)
    Chain 1:                3.372 seconds (Sampling)
    Chain 1:                7.283 seconds (Total)
    Chain 1: 
    


```R
save(fit, file="stan_models\\buckwheat_simple_log_BIO9_2.R")
```


```R
### Extract posterios distribution
posterior <- rstan::extract(fit)
str(posterior)
```

    List of 5
     $ alpha: num [1:500(1d)] -6.72 -6.7 -6.73 -6.85 -6.81 ...
      ..- attr(*, "dimnames")=List of 1
      .. ..$ iterations: NULL
     $ beta : num [1:500(1d)] -0.01978 -0.00411 0.00347 -0.02031 -0.00375 ...
      ..- attr(*, "dimnames")=List of 1
      .. ..$ iterations: NULL
     $ beta2: num [1:500(1d)] -0.00948 -0.01023 -0.00931 -0.00959 -0.00895 ...
      ..- attr(*, "dimnames")=List of 1
      .. ..$ iterations: NULL
     $ sigma: num [1:500(1d)] 2.81 2.74 2.71 2.71 2.8 ...
      ..- attr(*, "dimnames")=List of 1
      .. ..$ iterations: NULL
     $ lp__ : num [1:500(1d)] -3648 -3648 -3650 -3650 -3647 ...
      ..- attr(*, "dimnames")=List of 1
      .. ..$ iterations: NULL
    


```R
fit
```


    Inference for Stan model: buckwheat_simple_log_BIO9_2.
    1 chains, each with iter=1000; warmup=500; thin=1; 
    post-warmup draws per chain=500, total post-warmup draws=500.
    
              mean se_mean   sd     2.5%      25%      50%      75%    97.5% n_eff
    alpha    -6.80    0.01 0.08    -6.96    -6.85    -6.80    -6.75    -6.64   234
    beta     -0.01    0.00 0.01    -0.02    -0.02    -0.01    -0.01     0.00   320
    beta2    -0.01    0.00 0.00    -0.01    -0.01    -0.01    -0.01    -0.01   341
    sigma     2.76    0.00 0.04     2.69     2.74     2.76     2.79     2.84   301
    lp__  -3647.68    0.10 1.40 -3650.94 -3648.58 -3647.40 -3646.57 -3645.81   194
          Rhat
    alpha 1.02
    beta  1.00
    beta2 1.02
    sigma 1.00
    lp__  1.00
    
    Samples were drawn using NUTS(diag_e) at Thu Oct 03 15:00:48 2019.
    For each parameter, n_eff is a crude measure of effective sample size,
    and Rhat is the potential scale reduction factor on split chains (at 
    convergence, Rhat=1).



```R
colnames(china@data)
```


<ol class=list-inline>
	<li>'ID_0'</li>
	<li>'ISO'</li>
	<li>'NAME_0'</li>
	<li>'ID_1'</li>
	<li>'NAME_1'</li>
	<li>'ID_2'</li>
	<li>'NAME_2'</li>
	<li>'ID_3'</li>
	<li>'NAME_3'</li>
	<li>'TYPE_3'</li>
	<li>'ENGTYPE'</li>
	<li>'NL_NAME'</li>
	<li>'VARNAME'</li>
	<li>'BIO_01'</li>
	<li>'BIO_02'</li>
	<li>'BIO_03'</li>
	<li>'BIO_04'</li>
	<li>'BIO_05'</li>
	<li>'BIO_06'</li>
	<li>'BIO_07'</li>
	<li>'BIO_08'</li>
	<li>'BIO_09'</li>
	<li>'BIO_10'</li>
	<li>'BIO_11'</li>
	<li>'BIO_12'</li>
	<li>'BIO_13'</li>
	<li>'BIO_14'</li>
	<li>'BIO_15'</li>
	<li>'BIO_16'</li>
	<li>'BIO_17'</li>
	<li>'BIO_18'</li>
	<li>'BIO_19'</li>
	<li>'HrvstAF'</li>
	<li>'HrvsAHS'</li>
	<li>'HrvsAHM'</li>
	<li>'PrdctnS'</li>
	<li>'PrdctnM'</li>
	<li>'YldPrHc'</li>
	<li>'HrvsAF_'</li>
</ol>




```R
plot(logy ~ x, pch = 20)

## This predicts the values for lm model:
x0 <- seq(min(x), max(x), length = 20)  ## prediction grid
y0 <-  mean(posterior$alpha) + mean(posterior$beta)*x0 + mean(posterior$beta2)*(x0^2) ## predicted values
lines(x0, y0, col = "red",lwd=3)
y1 <-  quantile(posterior$alpha)[[2]] + quantile(posterior$beta)[[2]]*x0 + quantile(posterior$beta2)[[2]]*(x0^2) ## predicted values
lines(x0, y0, col = "blue",lwd=1)
y1 <-  quantile(posterior$alpha)[[3]] + quantile(posterior$beta)[[3]]*x0 + quantile(posterior$beta2)[[3]]*(x0^2) ## predicted values
lines(x0, y0, col = "blue",lwd=1)
```


![png](output_15_0.png)



```R
plot(posterior$alpha, type = "l")
plot(posterior$beta, type = "l")
plot(posterior$beta2, type = "l")
plot(posterior$sigma, type = "l")
```


![png](output_16_0.png)



![png](output_16_1.png)



![png](output_16_2.png)



![png](output_16_3.png)



```R
### Now plot predictions vs real value:
china@data$predictions<-mean(posterior$alpha) + mean(posterior$beta)*china@data$BIO_09 + mean(posterior$beta2)*(china@data$BIO_09^2)
```


```R
head(china@data$predictions)
```


<ol class=list-inline>
	<li>-7.16084034489498</li>
	<li>-7.22522050803564</li>
	<li>-7.0649429293122</li>
	<li>-7.44124247652948</li>
	<li>-7.33308170198906</li>
	<li>-7.10565475580264</li>
</ol>




```R
head(china@data$HrvstAF)
```


<ol class=list-inline>
	<li>0.000683868987229</li>
	<li>0.00045742504426</li>
	<li>0.00023373143983</li>
	<li>0.000236599516688</li>
	<li>0.000248556666891</li>
	<li>0.00010852533055</li>
</ol>




```R
par(mfrow=c(1,2))

#at <- c(0,0.000015,0,0001,0.00015,0.005,0.01,0.015,0.02,0.025,0.03,0.035)
#at <- c(0.0015,0.05,0.1,0.15,0.2,0.25,0.3,0.35)
at<-c(-Inf,-35,-30,-25,-20,-15,-10,-5,0,5,10)
spplot(china['HrvsAF_'], at=at)
spplot(china['predictions'], at=at)

spplot(china['BIO_09'] )
```






![png](output_20_2.png)





![png](output_20_4.png)



![png](output_20_5.png)



```R
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
```


```R
x1<-china@data$BIO_09
x2<-china@data$BIO_02
x3<-china@data$BIO_04
x4<-china@data$BIO_10
x5<-china@data$BIO_17
x6<-china@data$BIO_18
y<-china@data$HrvstAF
y[y == 0] <- 1.0e-14
```


```R
stan_model <- "stan_models\\buckwheat_log_parabolic_regression.stan"
```


```R
stan_data <- list(N = N, x1 = x1, y = y,x2=x2,x3=x3,x4=x4,x5=x5,x6=x6)
```


```R
str(stan_data)
```

    List of 8
     $ N : int 2409
     $ x1: num [1:2409] 5.76 6.29 4.86 7.84 7.11 ...
     $ y : num [1:2409] 0.000684 0.000457 0.000234 0.000237 0.000249 ...
     $ x2: num [1:2409] 7.99 8.82 8.7 8.12 8.69 ...
     $ x3: num [1:2409] 887 887 868 896 879 ...
     $ x4: num [1:2409] 27.5 27.4 26.1 27.8 26.8 ...
     $ x5: num [1:2409] 138 138 133 154 142 ...
     $ x6: num [1:2409] 591 600 630 540 608 ...
    


```R
fit <- stan(file = stan_model, data = stan_data, warmup = 2000, iter = 10000, chains = 4, cores = 2, thin = 1)
```

    recompiling to avoid crashing R session
    Warning message:
    "There were 7904 divergent transitions after warmup. Increasing adapt_delta above 0.8 may help. See
    http://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup"Warning message:
    "There were 16026 transitions after warmup that exceeded the maximum treedepth. Increase max_treedepth above 10. See
    http://mc-stan.org/misc/warnings.html#maximum-treedepth-exceeded"Warning message:
    "There were 3 chains where the estimated Bayesian Fraction of Missing Information was low. See
    http://mc-stan.org/misc/warnings.html#bfmi-low"Warning message:
    "Examine the pairs() plot to diagnose sampling problems
    "


```R
fit
```


    Inference for Stan model: buckwheat_log_parabolic_regression.
    4 chains, each with iter=10000; warmup=2000; thin=1; 
    post-warmup draws per chain=8000, total post-warmup draws=32000.
    
                  mean    se_mean         sd         2.5%         25%      50%
    alpha        -0.69       0.25       0.36        -1.22       -0.89    -0.65
    beta1        -0.55       0.80       1.13        -1.73       -1.67    -0.53
    beta2        -0.41       0.48       0.69        -1.60       -0.45    -0.02
    beta3         0.21       0.98       1.39        -1.99       -0.39     0.53
    beta4        -0.13       0.18       0.26        -0.58       -0.17    -0.01
    beta5        -0.22       0.23       0.33        -0.83       -0.25    -0.06
    beta6         0.00       0.00       0.00         0.00        0.00     0.00
    beta7        -0.22       0.18       0.25        -0.45       -0.40    -0.31
    beta8        -0.15       0.22       0.31        -0.74       -0.16     0.01
    beta9         0.40       0.38       0.54        -0.07       -0.03     0.36
    beta10        0.00       0.00       0.00         0.00        0.00     0.00
    beta11        0.10       0.11       0.16        -0.01       -0.01     0.01
    beta12        0.00       0.00       0.00         0.00        0.00     0.00
    sigma         3.10       0.82       1.16         1.36        2.43     3.01
    lp__   -3951426.63 4784352.09 7183359.56 -22894374.31 -2739254.70 -4831.34
                75%    97.5% n_eff    Rhat
    alpha     -0.44    -0.24     2  276.70
    beta1      0.58     0.61     2  545.82
    beta2     -0.01     0.00     2  483.60
    beta3      1.13     1.76     2 1001.94
    beta4      0.06     0.09     2   77.60
    beta5     -0.02     0.01     2   49.04
    beta6      0.00     0.00     2   48.45
    beta7     -0.13     0.20     2  275.82
    beta8      0.04     0.05     2   37.07
    beta9      0.66     1.29     2   32.60
    beta10     0.00     0.00     2   12.10
    beta11     0.11     0.38     2   73.72
    beta12     0.00     0.00     2   26.89
    sigma      4.75     4.81     2   14.25
    lp__   -3929.94 -3700.78     2    6.68
    
    Samples were drawn using NUTS(diag_e) at Fri Oct 04 00:27:04 2019.
    For each parameter, n_eff is a crude measure of effective sample size,
    and Rhat is the potential scale reduction factor on split chains (at 
    convergence, Rhat=1).



```R
posterior <- rstan::extract(fit)
```


```R
plot(posterior$alpha, type = "l")
plot(posterior$beta1, type = "l")
plot(posterior$beta2, type = "l")
plot(posterior$sigma, type = "l")
```


![png](output_29_0.png)



![png](output_29_1.png)



![png](output_29_2.png)



![png](output_29_3.png)



```R
save(fit, file="stan_models\\buckwheat_log_parabolic_regression.R")
```


```R
load("stan_models\\buckwheat_simple_BIO9_2.R")
```


```R
pairs(fit)
```


![png](output_32_0.png)


### Adding a spatial random effect to the model:


```R

```


```R
stan_model <- "stan_models\\buckwheat_simple_icar1.stan"
```


```R
icar_stan = stan_model(stan_model);
```


```R
fit_stan = sampling(icar_stan, data=list(N,N_edges,node1,node2), control=list(adapt_delta = 0.97, stepsize = 0.1), chains=2, warmup=9000, iter=10000, save_warmup=FALSE);
```

    
    SAMPLING FOR MODEL 'buckwheat_simple_icar1' NOW (CHAIN 1).
    Chain 1: 
    Chain 1: Gradient evaluation took 0 seconds
    Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
    Chain 1: Adjust your expectations accordingly!
    Chain 1: 
    Chain 1: 
    Chain 1: Iteration:    1 / 10000 [  0%]  (Warmup)
    Chain 1: Iteration: 1000 / 10000 [ 10%]  (Warmup)
    Chain 1: Iteration: 2000 / 10000 [ 20%]  (Warmup)
    Chain 1: Iteration: 3000 / 10000 [ 30%]  (Warmup)
    Chain 1: Iteration: 4000 / 10000 [ 40%]  (Warmup)
    Chain 1: Iteration: 5000 / 10000 [ 50%]  (Warmup)
    Chain 1: Iteration: 6000 / 10000 [ 60%]  (Warmup)
    Chain 1: Iteration: 7000 / 10000 [ 70%]  (Warmup)
    Chain 1: Iteration: 8000 / 10000 [ 80%]  (Warmup)
    Chain 1: Iteration: 9000 / 10000 [ 90%]  (Warmup)
    Chain 1: Iteration: 9001 / 10000 [ 90%]  (Sampling)
    Chain 1: Iteration: 10000 / 10000 [100%]  (Sampling)
    Chain 1: 
    Chain 1:  Elapsed Time: 1524.01 seconds (Warm-up)
    Chain 1:                177.189 seconds (Sampling)
    Chain 1:                1701.2 seconds (Total)
    Chain 1: 
    
    SAMPLING FOR MODEL 'buckwheat_simple_icar1' NOW (CHAIN 2).
    Chain 2: 
    Chain 2: Gradient evaluation took 0 seconds
    Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
    Chain 2: Adjust your expectations accordingly!
    Chain 2: 
    Chain 2: 
    Chain 2: Iteration:    1 / 10000 [  0%]  (Warmup)
    Chain 2: Iteration: 1000 / 10000 [ 10%]  (Warmup)
    Chain 2: Iteration: 2000 / 10000 [ 20%]  (Warmup)
    Chain 2: Iteration: 3000 / 10000 [ 30%]  (Warmup)
    Chain 2: Iteration: 4000 / 10000 [ 40%]  (Warmup)
    Chain 2: Iteration: 5000 / 10000 [ 50%]  (Warmup)
    Chain 2: Iteration: 6000 / 10000 [ 60%]  (Warmup)
    Chain 2: Iteration: 7000 / 10000 [ 70%]  (Warmup)
    Chain 2: Iteration: 8000 / 10000 [ 80%]  (Warmup)
    Chain 2: Iteration: 9000 / 10000 [ 90%]  (Warmup)
    Chain 2: Iteration: 9001 / 10000 [ 90%]  (Sampling)
    Chain 2: Iteration: 10000 / 10000 [100%]  (Sampling)
    Chain 2: 
    Chain 2:  Elapsed Time: 1578.53 seconds (Warm-up)
    Chain 2:                173.119 seconds (Sampling)
    Chain 2:                1751.65 seconds (Total)
    Chain 2: 
    

    Warning message:
    "There were 2000 transitions after warmup that exceeded the maximum treedepth. Increase max_treedepth above 10. See
    http://mc-stan.org/misc/warnings.html#maximum-treedepth-exceeded"Warning message:
    "Examine the pairs() plot to diagnose sampling problems
    "


```R
save(fit_stan, file="stan_models\\buckwheat_simple_icar02.R")
```

### Write iCAR model with temperature as predictor:


```R
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
```


```R
str(fit_stan)
```

    Formal class 'stanfit' [package "rstan"] with 10 slots
      ..@ model_name: chr "buckwheat_simple_icar1"
      ..@ model_pars: chr [1:2] "phi" "lp__"
      ..@ par_dims  :List of 2
      .. ..$ phi : num 2409
      .. ..$ lp__: num(0) 
      ..@ mode      : int 0
      ..@ sim       :List of 12
      .. ..$ samples    :List of 2
      .. .. ..$ :List of 2410
      .. .. .. ..$ phi[1]   : num [1:1000] -0.959 -0.976 -0.972 -0.98 -0.962 ...
      .. .. .. ..$ phi[2]   : num [1:1000] -0.907 -0.902 -0.907 -0.932 -0.945 ...
      .. .. .. ..$ phi[3]   : num [1:1000] -1.87 -1.86 -1.86 -1.87 -1.87 ...
      .. .. .. ..$ phi[4]   : num [1:1000] -1.69 -1.68 -1.68 -1.66 -1.66 ...
      .. .. .. ..$ phi[5]   : num [1:1000] -0.933 -0.909 -0.922 -0.923 -0.917 ...
      .. .. .. ..$ phi[6]   : num [1:1000] -0.191 -0.205 -0.207 -0.201 -0.199 ...
      .. .. .. ..$ phi[7]   : num [1:1000] -1.04 -1.04 -1.03 -1.02 -1.03 ...
      .. .. .. ..$ phi[8]   : num [1:1000] -0.622 -0.624 -0.622 -0.637 -0.638 ...
      .. .. .. ..$ phi[9]   : num [1:1000] -1.06 -1.05 -1.06 -1.07 -1.06 ...
      .. .. .. ..$ phi[10]  : num [1:1000] -0.334 -0.355 -0.369 -0.359 -0.374 ...
      .. .. .. ..$ phi[11]  : num [1:1000] -0.775 -0.778 -0.768 -0.772 -0.78 ...
      .. .. .. ..$ phi[12]  : num [1:1000] -1.25 -1.25 -1.24 -1.25 -1.25 ...
      .. .. .. ..$ phi[13]  : num [1:1000] -1.015 -1.012 -1.001 -0.999 -0.991 ...
      .. .. .. ..$ phi[14]  : num [1:1000] -1.15 -1.16 -1.15 -1.14 -1.15 ...
      .. .. .. ..$ phi[15]  : num [1:1000] -1.16 -1.15 -1.15 -1.14 -1.14 ...
      .. .. .. ..$ phi[16]  : num [1:1000] -0.898 -0.881 -0.881 -0.876 -0.875 ...
      .. .. .. ..$ phi[17]  : num [1:1000] -1.27 -1.26 -1.26 -1.27 -1.28 ...
      .. .. .. ..$ phi[18]  : num [1:1000] -0.846 -0.857 -0.862 -0.851 -0.853 ...
      .. .. .. ..$ phi[19]  : num [1:1000] -1.46 -1.45 -1.45 -1.45 -1.46 ...
      .. .. .. ..$ phi[20]  : num [1:1000] -1.22 -1.21 -1.2 -1.19 -1.2 ...
      .. .. .. ..$ phi[21]  : num [1:1000] -0.68 -0.667 -0.675 -0.693 -0.669 ...
      .. .. .. ..$ phi[22]  : num [1:1000] -1.24 -1.24 -1.22 -1.24 -1.25 ...
      .. .. .. ..$ phi[23]  : num [1:1000] -0.776 -0.775 -0.77 -0.772 -0.782 ...
      .. .. .. ..$ phi[24]  : num [1:1000] -0.941 -0.93 -0.937 -0.936 -0.953 ...
      .. .. .. ..$ phi[25]  : num [1:1000] -0.87 -0.883 -0.881 -0.888 -0.891 ...
      .. .. .. ..$ phi[26]  : num [1:1000] -1.71 -1.71 -1.72 -1.71 -1.73 ...
      .. .. .. ..$ phi[27]  : num [1:1000] -0.841 -0.833 -0.84 -0.844 -0.842 ...
      .. .. .. ..$ phi[28]  : num [1:1000] -0.134 -0.143 -0.144 -0.156 -0.149 ...
      .. .. .. ..$ phi[29]  : num [1:1000] -0.771 -0.772 -0.78 -0.785 -0.794 ...
      .. .. .. ..$ phi[30]  : num [1:1000] -0.54 -0.542 -0.555 -0.565 -0.563 ...
      .. .. .. ..$ phi[31]  : num [1:1000] -1.51 -1.49 -1.5 -1.5 -1.5 ...
      .. .. .. ..$ phi[32]  : num [1:1000] -0.853 -0.859 -0.845 -0.847 -0.857 ...
      .. .. .. ..$ phi[33]  : num [1:1000] -1.17 -1.16 -1.16 -1.17 -1.19 ...
      .. .. .. ..$ phi[34]  : num [1:1000] -0.462 -0.461 -0.456 -0.445 -0.443 ...
      .. .. .. ..$ phi[35]  : num [1:1000] -0.744 -0.74 -0.738 -0.746 -0.743 ...
      .. .. .. ..$ phi[36]  : num [1:1000] -0.673 -0.653 -0.637 -0.629 -0.635 ...
      .. .. .. ..$ phi[37]  : num [1:1000] -0.505 -0.503 -0.505 -0.512 -0.505 ...
      .. .. .. ..$ phi[38]  : num [1:1000] -0.722 -0.703 -0.701 -0.7 -0.7 ...
      .. .. .. ..$ phi[39]  : num [1:1000] 0.155 0.163 0.165 0.162 0.15 ...
      .. .. .. ..$ phi[40]  : num [1:1000] -0.835 -0.838 -0.849 -0.834 -0.83 ...
      .. .. .. ..$ phi[41]  : num [1:1000] -0.769 -0.753 -0.762 -0.756 -0.75 ...
      .. .. .. ..$ phi[42]  : num [1:1000] -1.52 -1.52 -1.53 -1.52 -1.53 ...
      .. .. .. ..$ phi[43]  : num [1:1000] -1.05 -1.05 -1.04 -1.04 -1.03 ...
      .. .. .. ..$ phi[44]  : num [1:1000] -2.07 -2.05 -2.06 -2.05 -2.02 ...
      .. .. .. ..$ phi[45]  : num [1:1000] -1.83 -1.83 -1.82 -1.79 -1.76 ...
      .. .. .. ..$ phi[46]  : num [1:1000] -1.17 -1.16 -1.16 -1.16 -1.15 ...
      .. .. .. ..$ phi[47]  : num [1:1000] -1.2 -1.21 -1.2 -1.2 -1.2 ...
      .. .. .. ..$ phi[48]  : num [1:1000] 0.146 0.151 0.156 0.164 0.168 ...
      .. .. .. ..$ phi[49]  : num [1:1000] -1.29 -1.27 -1.27 -1.27 -1.28 ...
      .. .. .. ..$ phi[50]  : num [1:1000] -0.759 -0.744 -0.743 -0.748 -0.744 ...
      .. .. .. ..$ phi[51]  : num [1:1000] -1.69 -1.69 -1.7 -1.71 -1.72 ...
      .. .. .. ..$ phi[52]  : num [1:1000] -0.75 -0.74 -0.745 -0.754 -0.755 ...
      .. .. .. ..$ phi[53]  : num [1:1000] -1.54 -1.54 -1.55 -1.55 -1.55 ...
      .. .. .. ..$ phi[54]  : num [1:1000] -0.954 -0.951 -0.953 -0.967 -0.971 ...
      .. .. .. ..$ phi[55]  : num [1:1000] -1.62 -1.63 -1.64 -1.64 -1.64 ...
      .. .. .. ..$ phi[56]  : num [1:1000] -0.695 -0.68 -0.688 -0.679 -0.67 ...
      .. .. .. ..$ phi[57]  : num [1:1000] -1.16 -1.15 -1.15 -1.15 -1.17 ...
      .. .. .. ..$ phi[58]  : num [1:1000] -0.646 -0.628 -0.639 -0.633 -0.637 ...
      .. .. .. ..$ phi[59]  : num [1:1000] -0.811 -0.828 -0.821 -0.819 -0.803 ...
      .. .. .. ..$ phi[60]  : num [1:1000] -1.59 -1.6 -1.59 -1.59 -1.59 ...
      .. .. .. ..$ phi[61]  : num [1:1000] -1.35 -1.36 -1.37 -1.39 -1.4 ...
      .. .. .. ..$ phi[62]  : num [1:1000] -1.62 -1.63 -1.62 -1.59 -1.58 ...
      .. .. .. ..$ phi[63]  : num [1:1000] -0.837 -0.831 -0.823 -0.835 -0.826 ...
      .. .. .. ..$ phi[64]  : num [1:1000] -0.897 -0.902 -0.918 -0.909 -0.917 ...
      .. .. .. ..$ phi[65]  : num [1:1000] -1.29 -1.28 -1.27 -1.26 -1.26 ...
      .. .. .. ..$ phi[66]  : num [1:1000] -1.22 -1.24 -1.23 -1.23 -1.25 ...
      .. .. .. ..$ phi[67]  : num [1:1000] -1.57 -1.58 -1.58 -1.59 -1.6 ...
      .. .. .. ..$ phi[68]  : num [1:1000] -1.22 -1.25 -1.25 -1.26 -1.28 ...
      .. .. .. ..$ phi[69]  : num [1:1000] -0.979 -0.981 -0.975 -0.973 -0.972 ...
      .. .. .. ..$ phi[70]  : num [1:1000] -1.4 -1.4 -1.4 -1.39 -1.39 ...
      .. .. .. ..$ phi[71]  : num [1:1000] -1.96 -1.98 -1.99 -1.98 -1.98 ...
      .. .. .. ..$ phi[72]  : num [1:1000] -1.4 -1.42 -1.39 -1.4 -1.4 ...
      .. .. .. ..$ phi[73]  : num [1:1000] -1.14 -1.14 -1.14 -1.15 -1.13 ...
      .. .. .. ..$ phi[74]  : num [1:1000] -1.62 -1.62 -1.63 -1.63 -1.63 ...
      .. .. .. ..$ phi[75]  : num [1:1000] -2 -1.98 -1.97 -1.97 -1.98 ...
      .. .. .. ..$ phi[76]  : num [1:1000] -1.08 -1.08 -1.09 -1.09 -1.1 ...
      .. .. .. ..$ phi[77]  : num [1:1000] -1.67 -1.66 -1.66 -1.67 -1.68 ...
      .. .. .. ..$ phi[78]  : num [1:1000] 0.0947 0.1001 0.1107 0.1259 0.1141 ...
      .. .. .. ..$ phi[79]  : num [1:1000] -0.585 -0.58 -0.551 -0.581 -0.584 ...
      .. .. .. ..$ phi[80]  : num [1:1000] -0.0926 -0.0748 -0.0687 -0.035 -0.0275 ...
      .. .. .. ..$ phi[81]  : num [1:1000] -0.472 -0.494 -0.49 -0.466 -0.469 ...
      .. .. .. ..$ phi[82]  : num [1:1000] 0.366 0.364 0.367 0.384 0.38 ...
      .. .. .. ..$ phi[83]  : num [1:1000] -0.02407 -0.03905 -0.02279 -0.00889 -0.00864 ...
      .. .. .. ..$ phi[84]  : num [1:1000] 0.459 0.451 0.436 0.435 0.421 ...
      .. .. .. ..$ phi[85]  : num [1:1000] -0.685 -0.68 -0.679 -0.695 -0.704 ...
      .. .. .. ..$ phi[86]  : num [1:1000] -0.452 -0.452 -0.448 -0.448 -0.452 ...
      .. .. .. ..$ phi[87]  : num [1:1000] -0.932 -0.931 -0.941 -0.949 -0.946 ...
      .. .. .. ..$ phi[88]  : num [1:1000] 0.0588 0.0634 0.045 0.0281 0.0409 ...
      .. .. .. ..$ phi[89]  : num [1:1000] -0.505 -0.523 -0.534 -0.541 -0.554 ...
      .. .. .. ..$ phi[90]  : num [1:1000] -0.857 -0.849 -0.848 -0.836 -0.823 ...
      .. .. .. ..$ phi[91]  : num [1:1000] -0.53 -0.556 -0.552 -0.543 -0.533 ...
      .. .. .. ..$ phi[92]  : num [1:1000] -0.664 -0.673 -0.679 -0.655 -0.655 ...
      .. .. .. ..$ phi[93]  : num [1:1000] -0.262 -0.282 -0.273 -0.273 -0.311 ...
      .. .. .. ..$ phi[94]  : num [1:1000] -0.806 -0.809 -0.827 -0.82 -0.812 ...
      .. .. .. ..$ phi[95]  : num [1:1000] -0.692 -0.68 -0.69 -0.691 -0.695 ...
      .. .. .. ..$ phi[96]  : num [1:1000] -1.34 -1.33 -1.33 -1.32 -1.3 ...
      .. .. .. ..$ phi[97]  : num [1:1000] -1.55 -1.54 -1.52 -1.54 -1.55 ...
      .. .. .. ..$ phi[98]  : num [1:1000] -0.702 -0.702 -0.714 -0.713 -0.707 ...
      .. .. .. ..$ phi[99]  : num [1:1000] -0.792 -0.784 -0.799 -0.801 -0.806 ...
      .. .. .. .. [list output truncated]
      .. .. .. ..- attr(*, "test_grad")= logi FALSE
      .. .. .. ..- attr(*, "args")=List of 16
      .. .. .. .. ..$ append_samples    : logi FALSE
      .. .. .. .. ..$ chain_id          : num 1
      .. .. .. .. ..$ control           :List of 12
      .. .. .. .. .. ..$ adapt_delta      : num 0.97
      .. .. .. .. .. ..$ adapt_engaged    : logi TRUE
      .. .. .. .. .. ..$ adapt_gamma      : num 0.05
      .. .. .. .. .. ..$ adapt_init_buffer: num 75
      .. .. .. .. .. ..$ adapt_kappa      : num 0.75
      .. .. .. .. .. ..$ adapt_t0         : num 10
      .. .. .. .. .. ..$ adapt_term_buffer: num 50
      .. .. .. .. .. ..$ adapt_window     : num 25
      .. .. .. .. .. ..$ max_treedepth    : int 10
      .. .. .. .. .. ..$ metric           : chr "diag_e"
      .. .. .. .. .. ..$ stepsize         : num 0.1
      .. .. .. .. .. ..$ stepsize_jitter  : num 0
      .. .. .. .. ..$ enable_random_init: logi TRUE
      .. .. .. .. ..$ init              : chr "random"
      .. .. .. .. ..$ init_list         : NULL
      .. .. .. .. ..$ init_radius       : num 2
      .. .. .. .. ..$ iter              : int 10000
      .. .. .. .. ..$ method            : chr "sampling"
      .. .. .. .. ..$ random_seed       : chr "700675590"
      .. .. .. .. ..$ refresh           : int 1000
      .. .. .. .. ..$ sampler_t         : chr "NUTS(diag_e)"
      .. .. .. .. ..$ save_warmup       : logi FALSE
      .. .. .. .. ..$ test_grad         : logi FALSE
      .. .. .. .. ..$ thin              : int 1
      .. .. .. .. ..$ warmup            : int 9000
      .. .. .. ..- attr(*, "inits")= num [1:2409] 1.407 1.069 -0.885 -0.541 0.13 ...
      .. .. .. ..- attr(*, "mean_pars")= num [1:2409] -1.198 -0.668 -1.5 -1.343 -0.827 ...
      .. .. .. ..- attr(*, "mean_lp__")= num -1239
      .. .. .. ..- attr(*, "adaptation_info")= chr "# Adaptation terminated\n# Step size = 5.72318e-005\n# Diagonal elements of inverse mass matrix:\n# 0.244912, 0"| __truncated__
      .. .. .. ..- attr(*, "elapsed_time")= Named num [1:2] 1524 177
      .. .. .. .. ..- attr(*, "names")= chr [1:2] "warmup" "sample"
      .. .. .. ..- attr(*, "sampler_params")=List of 6
      .. .. .. .. ..$ accept_stat__: num [1:1000] 0.935 0.905 0.993 0.999 0.999 ...
      .. .. .. .. ..$ stepsize__   : num [1:1000] 5.72e-05 5.72e-05 5.72e-05 5.72e-05 5.72e-05 ...
      .. .. .. .. ..$ treedepth__  : num [1:1000] 10 10 10 10 10 10 10 10 10 10 ...
      .. .. .. .. ..$ n_leapfrog__ : num [1:1000] 1023 1023 1023 1023 1023 ...
      .. .. .. .. ..$ divergent__  : num [1:1000] 0 0 0 0 0 0 0 0 0 0 ...
      .. .. .. .. ..$ energy__     : num [1:1000] 2391 2448 2425 2487 2426 ...
      .. .. .. ..- attr(*, "return_code")= int 0
      .. .. ..$ :List of 2410
      .. .. .. ..$ phi[1]   : num [1:1000] -0.925 -0.954 -0.966 -0.983 -0.972 ...
      .. .. .. ..$ phi[2]   : num [1:1000] -0.947 -0.965 -0.98 -0.985 -0.983 ...
      .. .. .. ..$ phi[3]   : num [1:1000] -0.206 -0.249 -0.215 -0.178 -0.177 ...
      .. .. .. ..$ phi[4]   : num [1:1000] -1.08 -1.08 -1.09 -1.07 -1.07 ...
      .. .. .. ..$ phi[5]   : num [1:1000] -0.693 -0.647 -0.669 -0.648 -0.636 ...
      .. .. .. ..$ phi[6]   : num [1:1000] -1.07 -1.08 -1.1 -1.11 -1.09 ...
      .. .. .. ..$ phi[7]   : num [1:1000] -0.878 -0.864 -0.866 -0.84 -0.861 ...
      .. .. .. ..$ phi[8]   : num [1:1000] -1.27 -1.26 -1.27 -1.31 -1.3 ...
      .. .. .. ..$ phi[9]   : num [1:1000] -1.33 -1.31 -1.31 -1.32 -1.33 ...
      .. .. .. ..$ phi[10]  : num [1:1000] -0.407 -0.454 -0.441 -0.461 -0.474 ...
      .. .. .. ..$ phi[11]  : num [1:1000] -0.294 -0.314 -0.316 -0.294 -0.247 ...
      .. .. .. ..$ phi[12]  : num [1:1000] -0.887 -0.87 -0.874 -0.892 -0.872 ...
      .. .. .. ..$ phi[13]  : num [1:1000] -0.807 -0.813 -0.838 -0.838 -0.875 ...
      .. .. .. ..$ phi[14]  : num [1:1000] -0.601 -0.633 -0.658 -0.646 -0.653 ...
      .. .. .. ..$ phi[15]  : num [1:1000] -1.29 -1.26 -1.25 -1.24 -1.18 ...
      .. .. .. ..$ phi[16]  : num [1:1000] -0.226 -0.212 -0.228 -0.21 -0.226 ...
      .. .. .. ..$ phi[17]  : num [1:1000] -1.22 -1.25 -1.25 -1.24 -1.21 ...
      .. .. .. ..$ phi[18]  : num [1:1000] -0.965 -0.944 -0.958 -0.982 -1.035 ...
      .. .. .. ..$ phi[19]  : num [1:1000] -1.41 -1.4 -1.43 -1.46 -1.45 ...
      .. .. .. ..$ phi[20]  : num [1:1000] -0.702 -0.738 -0.731 -0.765 -0.772 ...
      .. .. .. ..$ phi[21]  : num [1:1000] -0.476 -0.503 -0.493 -0.452 -0.452 ...
      .. .. .. ..$ phi[22]  : num [1:1000] -1.13 -1.12 -1.12 -1.1 -1.1 ...
      .. .. .. ..$ phi[23]  : num [1:1000] -1.35 -1.35 -1.34 -1.28 -1.29 ...
      .. .. .. ..$ phi[24]  : num [1:1000] -0.991 -0.941 -0.97 -0.977 -0.933 ...
      .. .. .. ..$ phi[25]  : num [1:1000] 0.0118 0.0304 0.0269 0.0548 0.0934 ...
      .. .. .. ..$ phi[26]  : num [1:1000] -0.646 -0.642 -0.647 -0.629 -0.625 ...
      .. .. .. ..$ phi[27]  : num [1:1000] -0.542 -0.526 -0.543 -0.547 -0.545 ...
      .. .. .. ..$ phi[28]  : num [1:1000] -1.02 -1.07 -1.07 -1.11 -1.12 ...
      .. .. .. ..$ phi[29]  : num [1:1000] -1.18 -1.19 -1.18 -1.18 -1.2 ...
      .. .. .. ..$ phi[30]  : num [1:1000] 0.452 0.454 0.456 0.458 0.459 ...
      .. .. .. ..$ phi[31]  : num [1:1000] -0.478 -0.475 -0.484 -0.47 -0.502 ...
      .. .. .. ..$ phi[32]  : num [1:1000] -1.28 -1.28 -1.29 -1.26 -1.25 ...
      .. .. .. ..$ phi[33]  : num [1:1000] 0.158 0.157 0.132 0.129 0.134 ...
      .. .. .. ..$ phi[34]  : num [1:1000] -0.11 -0.152 -0.157 -0.156 -0.168 ...
      .. .. .. ..$ phi[35]  : num [1:1000] -0.822 -0.807 -0.814 -0.85 -0.836 ...
      .. .. .. ..$ phi[36]  : num [1:1000] -0.228 -0.276 -0.3 -0.261 -0.266 ...
      .. .. .. ..$ phi[37]  : num [1:1000] 0.1109 0.103 0.0941 0.0957 0.0633 ...
      .. .. .. ..$ phi[38]  : num [1:1000] 0.01083 -0.00532 -0.02272 -0.04262 -0.05357 ...
      .. .. .. ..$ phi[39]  : num [1:1000] -0.642 -0.634 -0.674 -0.65 -0.596 ...
      .. .. .. ..$ phi[40]  : num [1:1000] -1.44 -1.45 -1.43 -1.44 -1.47 ...
      .. .. .. ..$ phi[41]  : num [1:1000] -1.08 -1.09 -1.1 -1.11 -1.11 ...
      .. .. .. ..$ phi[42]  : num [1:1000] -1.039 -1.035 -1.037 -0.999 -0.98 ...
      .. .. .. ..$ phi[43]  : num [1:1000] -1.85 -1.87 -1.88 -1.91 -1.96 ...
      .. .. .. ..$ phi[44]  : num [1:1000] 0.247 0.248 0.29 0.35 0.397 ...
      .. .. .. ..$ phi[45]  : num [1:1000] -0.000842 -0.037876 -0.035453 -0.032444 -0.042958 ...
      .. .. .. ..$ phi[46]  : num [1:1000] -0.604 -0.608 -0.622 -0.606 -0.615 ...
      .. .. .. ..$ phi[47]  : num [1:1000] -1.32 -1.29 -1.31 -1.27 -1.26 ...
      .. .. .. ..$ phi[48]  : num [1:1000] -0.451 -0.427 -0.423 -0.395 -0.403 ...
      .. .. .. ..$ phi[49]  : num [1:1000] 0.822 0.839 0.846 0.874 0.863 ...
      .. .. .. ..$ phi[50]  : num [1:1000] 0.297 0.285 0.281 0.276 0.267 ...
      .. .. .. ..$ phi[51]  : num [1:1000] -0.02251 -0.02859 -0.02954 -0.0148 -0.00849 ...
      .. .. .. ..$ phi[52]  : num [1:1000] -0.42 -0.421 -0.425 -0.431 -0.464 ...
      .. .. .. ..$ phi[53]  : num [1:1000] 0.183 0.194 0.205 0.172 0.177 ...
      .. .. .. ..$ phi[54]  : num [1:1000] -1.2 -1.19 -1.17 -1.18 -1.2 ...
      .. .. .. ..$ phi[55]  : num [1:1000] -1.06 -1.029 -0.997 -0.982 -0.969 ...
      .. .. .. ..$ phi[56]  : num [1:1000] -0.471 -0.486 -0.49 -0.499 -0.475 ...
      .. .. .. ..$ phi[57]  : num [1:1000] -1.41 -1.42 -1.38 -1.39 -1.38 ...
      .. .. .. ..$ phi[58]  : num [1:1000] -1.11 -1.1 -1.09 -1.09 -1.08 ...
      .. .. .. ..$ phi[59]  : num [1:1000] -0.695 -0.697 -0.692 -0.67 -0.637 ...
      .. .. .. ..$ phi[60]  : num [1:1000] -0.816 -0.801 -0.797 -0.822 -0.824 ...
      .. .. .. ..$ phi[61]  : num [1:1000] -0.788 -0.766 -0.767 -0.784 -0.785 ...
      .. .. .. ..$ phi[62]  : num [1:1000] -0.891 -0.916 -0.923 -0.91 -0.906 ...
      .. .. .. ..$ phi[63]  : num [1:1000] -0.0319 -0.0159 -0.0443 0.0336 0.0196 ...
      .. .. .. ..$ phi[64]  : num [1:1000] -0.0564 -0.047 -0.056 -0.0484 -0.0551 ...
      .. .. .. ..$ phi[65]  : num [1:1000] -0.267 -0.278 -0.263 -0.264 -0.295 ...
      .. .. .. ..$ phi[66]  : num [1:1000] -0.31 -0.304 -0.333 -0.327 -0.349 ...
      .. .. .. ..$ phi[67]  : num [1:1000] -0.767 -0.752 -0.769 -0.756 -0.759 ...
      .. .. .. ..$ phi[68]  : num [1:1000] -1.5 -1.51 -1.51 -1.53 -1.52 ...
      .. .. .. ..$ phi[69]  : num [1:1000] -0.469 -0.478 -0.482 -0.528 -0.508 ...
      .. .. .. ..$ phi[70]  : num [1:1000] -0.951 -0.936 -0.947 -0.944 -0.946 ...
      .. .. .. ..$ phi[71]  : num [1:1000] -0.774 -0.783 -0.787 -0.757 -0.792 ...
      .. .. .. ..$ phi[72]  : num [1:1000] 0.0282 -0.0189 -0.0259 0.0132 0.0221 ...
      .. .. .. ..$ phi[73]  : num [1:1000] 0.027516 0.024022 0.013072 0.000344 -0.030018 ...
      .. .. .. ..$ phi[74]  : num [1:1000] 0.49 0.462 0.445 0.514 0.532 ...
      .. .. .. ..$ phi[75]  : num [1:1000] -1.18 -1.2 -1.19 -1.2 -1.17 ...
      .. .. .. ..$ phi[76]  : num [1:1000] -0.372 -0.393 -0.389 -0.396 -0.366 ...
      .. .. .. ..$ phi[77]  : num [1:1000] -0.407 -0.369 -0.352 -0.405 -0.424 ...
      .. .. .. ..$ phi[78]  : num [1:1000] -0.728 -0.711 -0.721 -0.747 -0.737 ...
      .. .. .. ..$ phi[79]  : num [1:1000] 0.02308 0.00981 0.0209 0.01092 0.00474 ...
      .. .. .. ..$ phi[80]  : num [1:1000] -0.0725 -0.0548 -0.0656 -0.0609 -0.1116 ...
      .. .. .. ..$ phi[81]  : num [1:1000] -0.182 -0.167 -0.133 -0.128 -0.119 ...
      .. .. .. ..$ phi[82]  : num [1:1000] -0.491 -0.531 -0.539 -0.529 -0.539 ...
      .. .. .. ..$ phi[83]  : num [1:1000] 0.11 0.111 0.112 0.117 0.105 ...
      .. .. .. ..$ phi[84]  : num [1:1000] -0.00263 -0.01262 -0.01384 0.01849 0.02397 ...
      .. .. .. ..$ phi[85]  : num [1:1000] 0.568 0.593 0.598 0.582 0.599 ...
      .. .. .. ..$ phi[86]  : num [1:1000] 0.241 0.247 0.256 0.292 0.277 ...
      .. .. .. ..$ phi[87]  : num [1:1000] 0.307 0.307 0.304 0.286 0.285 ...
      .. .. .. ..$ phi[88]  : num [1:1000] -0.492 -0.5 -0.497 -0.486 -0.477 ...
      .. .. .. ..$ phi[89]  : num [1:1000] -1.26 -1.27 -1.29 -1.29 -1.31 ...
      .. .. .. ..$ phi[90]  : num [1:1000] -1.74 -1.72 -1.72 -1.7 -1.71 ...
      .. .. .. ..$ phi[91]  : num [1:1000] -1.67 -1.63 -1.63 -1.66 -1.64 ...
      .. .. .. ..$ phi[92]  : num [1:1000] -0.772 -0.768 -0.747 -0.742 -0.741 ...
      .. .. .. ..$ phi[93]  : num [1:1000] -1.5 -1.52 -1.52 -1.5 -1.52 ...
      .. .. .. ..$ phi[94]  : num [1:1000] -0.506 -0.48 -0.489 -0.501 -0.515 ...
      .. .. .. ..$ phi[95]  : num [1:1000] -1.87 -1.86 -1.85 -1.83 -1.82 ...
      .. .. .. ..$ phi[96]  : num [1:1000] -0.676 -0.666 -0.667 -0.679 -0.688 ...
      .. .. .. ..$ phi[97]  : num [1:1000] -1.008 -0.977 -0.986 -0.973 -1.004 ...
      .. .. .. ..$ phi[98]  : num [1:1000] -1.76 -1.79 -1.79 -1.79 -1.8 ...
      .. .. .. ..$ phi[99]  : num [1:1000] -1.25 -1.21 -1.23 -1.22 -1.23 ...
      .. .. .. .. [list output truncated]
      .. .. .. ..- attr(*, "test_grad")= logi FALSE
      .. .. .. ..- attr(*, "args")=List of 16
      .. .. .. .. ..$ append_samples    : logi FALSE
      .. .. .. .. ..$ chain_id          : num 2
      .. .. .. .. ..$ control           :List of 12
      .. .. .. .. .. ..$ adapt_delta      : num 0.97
      .. .. .. .. .. ..$ adapt_engaged    : logi TRUE
      .. .. .. .. .. ..$ adapt_gamma      : num 0.05
      .. .. .. .. .. ..$ adapt_init_buffer: num 75
      .. .. .. .. .. ..$ adapt_kappa      : num 0.75
      .. .. .. .. .. ..$ adapt_t0         : num 10
      .. .. .. .. .. ..$ adapt_term_buffer: num 50
      .. .. .. .. .. ..$ adapt_window     : num 25
      .. .. .. .. .. ..$ max_treedepth    : int 10
      .. .. .. .. .. ..$ metric           : chr "diag_e"
      .. .. .. .. .. ..$ stepsize         : num 0.1
      .. .. .. .. .. ..$ stepsize_jitter  : num 0
      .. .. .. .. ..$ enable_random_init: logi TRUE
      .. .. .. .. ..$ init              : chr "random"
      .. .. .. .. ..$ init_list         : NULL
      .. .. .. .. ..$ init_radius       : num 2
      .. .. .. .. ..$ iter              : int 10000
      .. .. .. .. ..$ method            : chr "sampling"
      .. .. .. .. ..$ random_seed       : chr "700675590"
      .. .. .. .. ..$ refresh           : int 1000
      .. .. .. .. ..$ sampler_t         : chr "NUTS(diag_e)"
      .. .. .. .. ..$ save_warmup       : logi FALSE
      .. .. .. .. ..$ test_grad         : logi FALSE
      .. .. .. .. ..$ thin              : int 1
      .. .. .. .. ..$ warmup            : int 9000
      .. .. .. ..- attr(*, "inits")= num [1:2409] 0.755 -1.404 0.925 -0.501 1.333 ...
      .. .. .. ..- attr(*, "mean_pars")= num [1:2409] -0.914 -0.482 -0.238 -0.611 -0.373 ...
      .. .. .. ..- attr(*, "mean_lp__")= num -1150
      .. .. .. ..- attr(*, "adaptation_info")= chr "# Adaptation terminated\n# Step size = 0.0001054\n# Diagonal elements of inverse mass matrix:\n# 0.252308, 0.08"| __truncated__
      .. .. .. ..- attr(*, "elapsed_time")= Named num [1:2] 1579 173
      .. .. .. .. ..- attr(*, "names")= chr [1:2] "warmup" "sample"
      .. .. .. ..- attr(*, "sampler_params")=List of 6
      .. .. .. .. ..$ accept_stat__: num [1:1000] 1 0.999 0.986 0.986 0.997 ...
      .. .. .. .. ..$ stepsize__   : num [1:1000] 0.000105 0.000105 0.000105 0.000105 0.000105 ...
      .. .. .. .. ..$ treedepth__  : num [1:1000] 10 10 10 10 10 10 10 10 10 10 ...
      .. .. .. .. ..$ n_leapfrog__ : num [1:1000] 1023 1023 1023 1023 1023 ...
      .. .. .. .. ..$ divergent__  : num [1:1000] 0 0 0 0 0 0 0 0 0 0 ...
      .. .. .. .. ..$ energy__     : num [1:1000] 2343 2369 2411 2428 2439 ...
      .. .. .. ..- attr(*, "return_code")= int 0
      .. ..$ iter       : num 10000
      .. ..$ thin       : num 1
      .. ..$ warmup     : num 9000
      .. ..$ chains     : num 2
      .. ..$ n_save     : num [1:2] 1000 1000
      .. ..$ warmup2    : int [1:2] 0 0
      .. ..$ permutation:List of 2
      .. .. ..$ : int [1:1000] 645 667 501 512 172 30 423 541 138 380 ...
      .. .. ..$ : int [1:1000] 375 148 178 27 313 113 213 354 463 487 ...
      .. ..$ pars_oi    : chr [1:2] "phi" "lp__"
      .. ..$ dims_oi    :List of 2
      .. .. ..$ phi : num 2409
      .. .. ..$ lp__: num(0) 
      .. ..$ fnames_oi  : chr [1:2410] "phi[1]" "phi[2]" "phi[3]" "phi[4]" ...
      .. ..$ n_flatnames: int 2410
      ..@ inits     :List of 2
      .. ..$ :List of 1
      .. .. ..$ phi: num [1:2409(1d)] 1.407 1.069 -0.885 -0.541 0.13 ...
      .. ..$ :List of 1
      .. .. ..$ phi: num [1:2409(1d)] 0.755 -1.404 0.925 -0.501 1.333 ...
      ..@ stan_args :List of 2
      .. ..$ :List of 10
      .. .. ..$ chain_id   : int 1
      .. .. ..$ iter       : int 10000
      .. .. ..$ thin       : int 1
      .. .. ..$ seed       : int 700675590
      .. .. ..$ warmup     : num 9000
      .. .. ..$ init       : chr "random"
      .. .. ..$ algorithm  : chr "NUTS"
      .. .. ..$ save_warmup: logi FALSE
      .. .. ..$ method     : chr "sampling"
      .. .. ..$ control    :List of 2
      .. .. .. ..$ adapt_delta: num 0.97
      .. .. .. ..$ stepsize   : num 0.1
      .. ..$ :List of 10
      .. .. ..$ chain_id   : int 2
      .. .. ..$ iter       : int 10000
      .. .. ..$ thin       : int 1
      .. .. ..$ seed       : int 700675590
      .. .. ..$ warmup     : num 9000
      .. .. ..$ init       : chr "random"
      .. .. ..$ algorithm  : chr "NUTS"
      .. .. ..$ save_warmup: logi FALSE
      .. .. ..$ method     : chr "sampling"
      .. .. ..$ control    :List of 2
      .. .. .. ..$ adapt_delta: num 0.97
      .. .. .. ..$ stepsize   : num 0.1
      ..@ stanmodel :Formal class 'stanmodel' [package "rstan"] with 5 slots
      .. .. ..@ model_name  : chr "buckwheat_simple_icar1"
      .. .. ..@ model_code  : atomic [1:1] // Stan model for simple linear regression
    
    data {
      int<lower=0> N; //This represents the number of counties in | __truncated__
      .. .. .. ..- attr(*, "model_name2")= chr "buckwheat_simple_icar1"
      .. .. ..@ model_cpp   :List of 2
      .. .. .. ..$ model_cppname: chr "model960534c18a8_buckwheat_simple_icar1"
      .. .. .. ..$ model_cppcode: chr "// Code generated by Stan version 2.18.1\n\n#include <stan/model/model_header.hpp>\n\nnamespace model960534c18a"| __truncated__
      .. .. ..@ mk_cppmodule:function (object)  
      .. .. ..@ dso         :Formal class 'cxxdso' [package "rstan"] with 7 slots
      .. .. .. .. ..@ sig         :List of 1
      .. .. .. .. .. ..$ file96073007907: chr(0) 
      .. .. .. .. ..@ dso_saved   : logi TRUE
      .. .. .. .. ..@ dso_filename: chr "file96073007907"
      .. .. .. .. ..@ modulename  : chr "stan_fit4model960534c18a8_buckwheat_simple_icar1_mod"
      .. .. .. .. ..@ system      : chr "x86_64, mingw32"
      .. .. .. .. ..@ cxxflags    : chr "CXXFLAGS=-O3 -Wno-unused-variable -Wno-unused-function"
      .. .. .. .. ..@ .CXXDSOMISC :<environment: 0x00000000087e29b0> 
      ..@ date      : chr "Thu Oct 03 16:30:00 2019"
      ..@ .MISC     :<environment: 0x000000002766a348> 
    


```R

```
