// Stan model for simple linear regression

data {
  int<lower=0> N; //This represents the number of counties in China
  int<lower=0> N_edges; //Number of edges, i.e. the number of connections between counties
  int<lower=1, upper=N> node1[N_edges];  // node1[i] adjacent to node2[i] 
  int<lower=1, upper=N> node2[N_edges];  // and node1[i] < node2[i]
}
parameters {
  vector[N] phi; // Estimate phi (prior iCar for each county in the dataset)
}
model {
  target += -0.5 * dot_self(phi[node1] - phi[node2]); // 
  // soft sum-to-zero constraint on phi)
  sum(phi) ~ normal(0, 0.01 * N);  // equivalent to mean(phi) ~ normal(0,0.01)
  // sum of all the values in the vector is normally distirbuted with mean 0 and the standard deviation of 0.01*numbe of counties

}
