data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numParents; // number of unique parents

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_parent[numLengths]; // parent of specific utterance
}

parameters {
  real<lower=0> mu_mean; // overall mean mean parameter
  //real<lower=0> sigma_mean; // variance for overall mean

  real<lower=0> mu_over; // overall mean overdispersion parameter
  // real<lower=0> sigma_over; // variance for overall overdispersion parameter

  vector<lower=0>[numParents] mu_p; // for each parent, a mean parameter
  vector<lower=0>[numParents] over_p; // for each parent, an overdispersion parameter

  //real <lower=0> alphapop;
  //vector <lower=0>[numParents] alphapar;

  //real <lower=0> betapop;
  //vector <lower=0>[numParents] betapar;
}

model {
  mu_mean ~ gamma(.01,.01);
  //sigma_mean ~ gamma(.01, .01);

  mu_over ~ gamma(.01,.01);
  //sigma_over ~ gamma(.01, .01);

  mu_p ~ gamma(mu_mean, 1);
  over_p ~ gamma(mu_over, 1);

  //alphapop ~ gamma(.001, .001);
  //alphapar ~ gamma(alphapop, 1);

  //betapop ~ gamma(.001, .001);
  //betapar ~ gamma(betapop, 1);

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
   utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]],over_p[utt_parent[n]]); 
  
   // utt_length[n] ~ neg_binomial(alphapar[utt_parent[n]], betapar[utt_parent[n]]); // 
 }
}





