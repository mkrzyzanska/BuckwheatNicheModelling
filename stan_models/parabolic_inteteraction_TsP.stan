// Stan parabolic model with 5 predictors and an interaction between Temperature seasonality and precipitation

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 int<lower=0> N_edges;
 int<lower=1, upper=N> node1[N_edges];  // node1[i] adjacent to node2[i]
 int<lower=1, upper=N> node2[N_edges];  // and node1[i] < node2[i]
 vector[N] x1; // BIO10 Mean Temperature of Warmest Quarter
 vector[N] x2; // BIO17 Precipitation of Driest Quarter
 vector[N] x3; // BIO4 Temperature Seasonality
 vector[N] x4; // BIO9 Mean Temperature of Driest Quarter
 vector[N] x5; // npp
 vector[N] y; // Outcome is a vector of a size of sample size
}

// this will define interactions included in the model
transformed data { 
 vector[N] inter1 = x3 .* x2; //the '.' makes it work like R
}

parameters {
 real alpha; // Intercept is an unconstrained continous value
 real beta1; // Slope (regression coefficients) is an unconstrained continous value
 real beta2; 
 real beta3; 
 real beta4; 
 real beta5;
 real beta6; 
 real beta7; 
 real beta8; 
 real beta9; 
 real beta10; 
 real beta11;
 real beta12;
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous value
 vector[N] phi;         // spatial effects
}


model {
 y ~ normal(alpha + x1 * beta1 + square(x1) * beta2 + x2 * beta3 + square(x2) * beta4 +
                          x3 * beta5 + square(x3) * beta6 + x4 * beta7 + square(x4) * beta8 +
                          x5 * beta9 + square(x5) * beta10 + inter1*beta11 + square(inter1)*beta12 +                        
                          phi, sigma); //this declares the model
 target += -0.5 * dot_self(phi[node1] - phi[node2]); 
 beta1 ~ normal(0, 1);
 beta2 ~ normal(0, 1);
 beta3 ~ normal(0, 1);
 beta4 ~ normal(0, 1);
 beta5 ~ normal(0, 1);
 beta6 ~ normal(0, 1);
 beta7 ~ normal(0, 1);
 beta8 ~ normal(0, 1);
 beta9 ~ normal(0, 1);
 beta10 ~ normal(0, 1);
 beta11 ~ normal(0, 1);
 beta12 ~ normal(0, 1);
 sigma ~ normal(0.0, 5.0);
 sum(phi) ~ normal(0, 0.001 * N);
}
generated quantities {
} // The posterior predictive distribution