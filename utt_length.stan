data {
  int<lower=0> numLengths; // amount of utterance lengths
  int<lower=0> numParents;

  int lengths[numLengths]; // utterance lengths
  int parents[numLengths];
}

parameters {
  real<lower=0> lambda; 
  real<lower=0> lambda_p[numParents]
}
model {
  lambda ~ gamma(1,1);

  for(p in 1:numParents) {
    lambda_p[p] ~ normal(lambda, 1) //made up a standard deviation 
  }

  for (n in 1:numLengths) {

      lengths[n] ~ exponential(lambda_p[parents[n]);
    lengths[n] ~ exponential(lambda_p[parents[n]]); // 
  }

}
