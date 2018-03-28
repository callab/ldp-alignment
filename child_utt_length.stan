data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numChildren; // number of unique children

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_child[numLengths]; // child of specific utterance
  
  
  vector[numLengths] utt_session;  // session number of each utterance

}

parameters {
  real<lower=0> c_mu_mean; // for children, overall mean mean parameter
  //real<lower=0> sigma_mean; // for children, variance for overall mean

  real<lower=0> c_mu_over; // overall mean overdispersion parameter
  // real<lower=0> sigma_over; // variance for overall overdispersion parameter

  real<lower=0>mu_c_s[numChildren]; // for each child, a mean parameter
  real over_c_s[numChildren] ; // for each child, an overdispersion parameter

  vector[numChildren] alpha_mean_c_s; //for each child, a scalar for mean slope
  vector[numChildren] alpha_over_c_s; //for each child, a scalar for overdispersion slope

  
}

// transformed parameters {
//   vector[numLengths] mu_c_long; // for each child a mean length, long form 
//   vector[numLengths] over_c_long; // for each child a dispersion parameter, long form 
//   vector[numLengths] alpha_mean_c_long; // for each child, a scalar for mean slope, long form
//   vector[numLengths] alpha_over_c_long;  // for each child, a scalar for overdispersion slope, long form


//   for (l in 1:(numLengths)){
//     mu_c_long[l] = mu_c_s[utt_child[l]];
//     over_c_long[l] = over_c_s[utt_child[l]];

//     alpha_mean_c_long[l] = alpha_mean_c_s[utt_child[l]];
//     alpha_over_c_long[l] = alpha_over_c_s[utt_child[l]];
//   }

// }

model {

  c_mu_mean ~ gamma(.01,.01);
  //sigma_mean ~ gamma(.01, .01);

  c_mu_over ~ gamma(.01,.01);
  //sigma_over ~ gamma(.01, .01);

  mu_c_s ~ uniform(0, 10);
  over_c_s ~ uniform(0, 10);

  //mu_p ~ gamma(mu_mean, 1);
  //over_p ~ gamma(mu_over, 1);

  alpha_mean_c_s ~ normal(0, 1); // scalars representing individual parent slopes
  alpha_over_c_s ~ normal(0, 1); 

 
 // for (n in 1:numLengths) {
 //  estimate linear regression with parent mean, parent slope multiplied by session number
 //  utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]] + alpha_mean_p[utt_parent[n]] * utt_session[n], over_p[utt_parent[n]] + alpha_over_p[utt_parent[n]] * utt_session[n]);
 //  utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]], over_p[utt_parent[n]]);

 // }
 for (n in 1:numLengths) {
    utt_length[n] ~ neg_binomial_2(mu_c_s[utt_child[n]] + alpha_mean_c_s[utt_child[n]] * utt_session[n], over_c_s[utt_child[n]] + alpha_over_c_s[utt_child[n]] * utt_session[n]);

 }

 // utt_length ~ neg_binomial_2(mu_c_long + alpha_mean_c_long .* utt_session, over_c_long + alpha_over_c_long .* utt_session);
}

// for each cell, a child and session
// linear 
// for each session, drawn from child's mu plus child's scalar times sessionnumber
// scalar is drawn from normal distribution around 0
// do same thing for overdispersion parameter
// recode sessions to be equally dispersed around 0

// problem with reindexing sessions?

// make normal st dev close to 0 to constrain slope
// try to estimate data itself
// do for one session
// compare to empirical findings




