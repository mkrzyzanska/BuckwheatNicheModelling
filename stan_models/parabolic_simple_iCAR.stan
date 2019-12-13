// Stan model for simple linear regression

data {
 int < lower = 1 > N; // Sample size is an integer with the lowest value of 1 (i.e. positive)
 int<lower=0> N_edges;
 int<lower=1, upper=N> node1[N_edges];  // node1[i] adjacent to node2[i]
 int<lower=1, upper=N> node2[N_edges];  // and node1[i] < node2[i]
 vector[N] x1; // Predictor is a vector of the size of sample size
 vector[N] x2; // Predictor is a vector of the size of sample size
 vector[N] x3; // Predictor is a vector of the size of sample size
 vector[N] x4; // Predictor is a vector of the size of sample size
 vector[N] x5; // Predictor is a vector of the size of sample size
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
 real < lower = 0 > sigma; // Error SD is an unconstrained positive continous valeu
 vector[N] phi;         // spatial effects
}

model {
 y ~ normal(alpha + x1 * beta1 + square(x1) * beta2 + x2 * beta3 + square(x2) * beta4 +
                          x3 * beta5 + square(x3) * beta6 + x4 * beta7 + square(x4) * beta8 +
                          x5 * beta9 + square(x5) * beta10 + phi, sigma); //this seem to declare the model
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
 sigma ~ normal(0.0, 5.0);
 sum(phi) ~ normal(0, 0.001 * N);
}
generated quantities {
} // The posterior predictive distribution
