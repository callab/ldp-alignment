data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numParents; // number of unique parents

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_parent[numLengths]; // parent of specific utterance
  
  int utt_session[numLengths];

  //vector[numLengths] utt_session; 

  int<lower=0> parent_indices[numParents]; // vector with parents' indices 

}

parameters {
  real<lower=0> mu_mean; // overall mean mean parameter
  //real<lower=0> sigma_mean; // variance for overall mean

  real<lower=0> mu_over; // overall mean overdispersion parameter
  // real<lower=0> sigma_over; // variance for overall overdispersion parameter

  vector<lower=0>[numParents] mu_p; // for each parent, a mean parameter
  vector[numParents] over_p; // for each parent, an overdispersion parameter

  vector[numParents] alpha_mean_p; //for each parent, a scalar for mean slope
  vector[numParents] alpha_over_p; //for each parent, a scalar for overdispersion slope

  
}

transformed parameters {
  
  //vector<lower=0>[numLengths] mu_p_long; // for each parent a mean length, long form
  //vector[numLengths] over_p_long; // for each parent a dispersion parameter, long form

  real<lower=0> mu_p_long[numLengths];
  real over_p_long[numLengths];
  
  for (p in 1:(numParents-1)) {
    mu_p_long[parent_indices[p]:(parent_indices[p+1]-1)] <- mu_p[p];
    over_p_long[parent_indices[p]:(parent_indices[p+1]-1)] <- over_p[p];
  }
  
  mu_p_long[parent_indices[numParents]: numLengths] <- mu_p[numParents];
  over_p_long[parent_indices[numParents]: numLengths] <- mu_p[numParents];

}

model {

  mu_mean ~ gamma(.01,.01);
  //sigma_mean ~ gamma(.01, .01);

  mu_over ~ gamma(.01,.01);
  //sigma_over ~ gamma(.01, .01);

  mu_p ~ uniform(0, 10);
  over_p ~ uniform(0, 10);

  //mu_p ~ gamma(mu_mean, 1);
  //over_p ~ gamma(mu_over, 1);

  //alpha_mean_p ~ normal(0, .00001); // scalars representing individual parent slopes
  //alpha_over_p ~ normal(0, .00001);

 
 //for (n in 1:numLengths) {
  // estimate linear regression with parent mean, parent slope multiplied by session number
  //utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]] + alpha_mean_p[utt_parent[n]] * utt_session[n], over_p[utt_parent[n]] + alpha_over_p[utt_parent[n]] * utt_session[n]);
  //utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]], over_p[utt_parent[n]]);

 //}

 utt_length ~ neg_binomial_2(mu_p_long, over_p_long);
}

// for each cell, a parent and session
// linear 
// for each session, drawn from parent's mu plus parent's scalar times sessionnumber
// scalar is drawn from normal distribution around 0
// do same thing for overdispersion parameter
// recode sessions to be equally dispersed around 0

// problem with reindexing sessions?

// make normal st dev close to 0 to constrain slope
// try to estimate data itself
// do for one session
// compare to empirical findings


//vectorized version?




