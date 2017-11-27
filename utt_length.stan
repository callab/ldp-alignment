data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numParents; // number of unique parents

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_parent[numLengths]; // parent of specific utterance
  //int utt_session[numLengths]; // session for specfic utterance
  vector[numLengths] utt_session; 

}

parameters {
  real<lower=0> mu_mean; // overall mean mean parameter
  //real<lower=0> sigma_mean; // variance for overall mean

  real<lower=0> mu_over; // overall mean overdispersion parameter
  // real<lower=0> sigma_over; // variance for overall overdispersion parameter

  vector<lower=0>[numParents] mu_p; // for each parent, a mean parameter
  vector<lower=0>[numParents] over_p; // for each parent, an overdispersion parameter

  vector<lower=0>[numParents] alpha_mean_p; //for each parent, a scalar for mean slope
  vector<lower=0>[numParents] alpha_over_p; //for each parent, a scalar for overdispersion slope
}

model {

  mu_mean ~ gamma(.01,.01);
  //sigma_mean ~ gamma(.01, .01);

  mu_over ~ gamma(.01,.01);
  //sigma_over ~ gamma(.01, .01);

  mu_p ~ gamma(mu_mean, 1);
  over_p ~ gamma(mu_over, 1);

  alpha_mean_p ~ normal(mu_p, 1); // scalars representing individual parent slopes
  alpha_over_p ~ normal(over_p, 1);

 
 for (n in 1:numLengths) {
  // estimate linear regression with parent mean, parent slope multiplied by session number
   utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]] + alpha_mean_p[utt_parent[n]] * utt_session[n], over_p[utt_parent[n]] + alpha_over_p[utt_parent[n]] * utt_session[n]);
 }
}

// for each cell, a parent and session
// linear 
// for each session, drawn from parent's mu plus parent's scalar times sessionnumber
// scalar is drawn from normal distribution around 0
// do same thing for overdispersion parameter
// recode sessions to be equally dispersed around 0

// problem with reindexing sessions?





