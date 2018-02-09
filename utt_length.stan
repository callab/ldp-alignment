data {
  int<lower=0> numLengths; // number of utterances
  int<lower=0> numParents; // number of unique parents

  //vector[numLengths] utt_length; // utterance lengths
  //vector[numLengths] utt_parent; // utterance lengths

  int<lower=0> utt_length[numLengths]; // all utterance lengths
  int<lower=0> utt_parent[numLengths]; // parent of specific utterance
  
  vector[numLengths] utt_session;  // session number of each utterance

}

parameters {
  real<lower=0> p_mu_mean; // for parents, overall mean mean parameter
  //real<lower=0> sigma_mean; // variance for overall mean

  real<lower=0> p_mu_over; // for parents, overall mean overdispersion parameter
  // real<lower=0> sigma_over; // variance for overall overdispersion parameter

  real<lower=0>mu_p_s[numParents]; // for each parent, a mean parameter, short form
  real over_p_s[numParents] ; // for each parent, an overdispersion parameter, short form

  vector[numParents] alpha_mean_p_s; //for each parent, a scalar for mean slope, short form
  vector[numParents] alpha_over_p_s; //for each parent, a scalar for overdispersion slope, short form

  
}

//transformed parameters {
  
  //real<lower=0> mu_p_long[numLengths]; // for each parent a mean length, long form 
  //real over_p_long[numLengths] ; // for each parent a dispersion parameter, long form 
  //real alpha_mean_p_long[numLengths]; // for each parent, a scalar for mean slope, long form
  //real alpha_over_p_long[numLengths]; // for each parent, a scalar for overdispersion slope, long form
  //real over_p_long[numLengths];
  //vector[numLengths] mu_p_long;
  //vector[numLengths] over_p_long;
  //vector[numLengths] alpha_mean_p_long;
  //vector[numLengths] alpha_over_p_long;

  //vector [numLengths] mu_sample;
  //vector [numLengths] over_sample;

  //for (l in 1:(numLengths)){
    //mu_p_long[l] = mu_p_s[utt_parent[l]];
    //over_p_long[l] = over_p_s[utt_parent[l]];

    //alpha_mean_p_long[l] = alpha_mean_p_s[utt_parent[l]];
    //alpha_over_p_long[l] = alpha_over_p_s[utt_parent[l]];

    //mu_sample[l] = fmax(mu_p_long[l] + alpha_mean_p_long[l] * utt_session[l], 0.1);
    //over_sample[l] = fmax(over_p_long[l] + alpha_over_p_long[l] * utt_session[l], 0.1);

   //}

//}

model {

  p_mu_mean ~ gamma(.01,.01);
  //sigma_mean ~ gamma(.01, .01);

  p_mu_over ~ gamma(.01,.01);
  //sigma_over ~ gamma(.01, .01);

  mu_p_s ~ uniform(0, 10);
  over_p_s ~ uniform(0, 10);

  //mu_p ~ gamma(mu_mean, 1);
  //over_p ~ gamma(mu_over, 1);

  alpha_mean_p_s ~ normal(0, 1); // scalars representing individual parent slopes
  alpha_over_p_s ~ normal(0, 1); 

 
 for (n in 1:numLengths) {
  // estimate linear regression with parent mean, parent slope multiplied by session number
  utt_length[n] ~ neg_binomial_2(mu_p_s[utt_parent[n]] + alpha_mean_p_s[utt_parent[n]] * utt_session[n], over_p_s[utt_parent[n]] + alpha_over_p_s[utt_parent[n]] * utt_session[n]);
  //utt_length[n] ~ neg_binomial_2(mu_p[utt_parent[n]], over_p[utt_parent[n]]);

 //}

 //utt_length ~ neg_binomial_2(mu_sample, over_sample);
}

// for each cell, a parent and session
// linear 
// for each session, drawn from parent's mu plus parent's scalar times sessionnumber
// scalar is drawn from normal distribution around 0
// do same thing for overdispersion parameter
// recode sessions to be equally dispersed around 0

// make normal st dev close to 0 to constrain slope
// try to estimate data itself
// do for one session
// compare to empirical findings


// do for all parents across session; and kids



// alignment model
// try running standard alignment model on LDP data 
// try acropolis 
