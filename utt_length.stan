data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numParents; // number of unique parents

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_parent[numLengths]; // parent of specific utterance
}

parameters {
  real<lower=0> mu_mean; // overall distribution parameter
  real<lower=0> sigma_mean; // overall distribution parameter

  real<lower=0> mu_sd; // overall distribution parameter
  real<lower=0> sigma_sd; // overall distribution parameter

  vector<lower=0>[numParents] mu_p; // for each parent, a distribution parameter
  vector<lower=0>[numParents] sigma_p; // for each parent, a distribution parameter
}

model {
  mu_mean ~ gamma(.01,100);
  sigma_mean ~ gamma(.01, .100);

  mu_sd ~ gamma(.01,100);
  sigma_sd ~ gamma(.01, 100);

  mu_p ~ gamma(mu_mean, sigma_mean);
  sigma_p ~ gamma(mu_sd, sigma_sd);

  //for(p in 1:numParents) {  // for each parent, draw a parameter lambda_p and put in vector
  //                          // lambda_p
  //  lambda_p[p] ~ normal(lambda, 1); //made up a standard deviation 
  //}
  // lambda_p ~ beta(, .01); // vectorized form
  // beta distribution
  // want to be basically uniform; gives us alpha for neg_binomial

// lambda_p and parents go together by indices - for each parent, a corresponding lambda_p by index
// then, for each parent/lambda_p, draw for each numLengths
 for (n in 1:numLengths) {
   utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]],sigma_p[utt_parent[n]]); // 
 }
 // negative binomial distribution instead of exponential

}

  //lengths ~ exponential(lambda_p[utt_parent]); // vectorized form
//}


