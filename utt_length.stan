data {
  int<lower=0> numLengths; // amount of utterance lengths
  int<lower=0> numParents;

  vector[numLengths] lengths; // utterance lengths
  vector[numParents] parents; // parent who uttered
}

parameters {
  real<lower=0> lambda; // overall distribution parameter
  vector<lower=0>[numParents] lambda_p; // for each parent, a distribution parameter
}

model {
  lambda ~ gamma(1,1);

  //for(p in 1:numParents) {  // for each parent, draw a parameter lambda_p and put in vector
  //                          // lambda_p
  //  lambda_p[p] ~ normal(lambda, 1); //made up a standard deviation 
  //}
  lambda_p ~ normal(lambda, 1); // vectorized form

// lambda_p and parents go together by indices - for each parent, a corresponding lambda_p by index
// then, for each parent/lambda_p, draw for each numLengths
//  for (n in 1:numLengths) {
//    lengths[n] ~ exponential(lambda_p[parents[n]]); // 
//  }

  lengths ~ exponential(lambda_p); // vectorized form
}
