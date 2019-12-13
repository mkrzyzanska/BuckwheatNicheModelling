// Stan model for simple linear (parabolic) regression

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
} // The posterior predictive distribution
