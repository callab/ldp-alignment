//This is the version of the HAM framework used in Yurovsky, Doyle, & Frank 2016 (Cogsci Conference)
// Baseline prior is uniform, alignment prior is normal
// hierarchy is: marker, marker+group, marker+dyad

data {
  int<lower=0> NumMarkers;                              //Number of marker categories in data
  real<lower=0> MidAge;
  int<lower=0> NumSubPops;                              //Number of groups in the data
  int<lower=0> NumSpeakers;                             //Identity of each speaker
  int<lower=0> NumObservations;                         //Number of marker-dyad observations
  int<lower=0> SpeakerSubPop[NumSpeakers];          //Group number for each observation
  int<lower=0> SpeakerAge[NumObservations];          //Group number for each observation
  int<lower=0> MarkerType[NumObservations];             //Marker number for each observation
  int<lower=0> SpeakerId[NumObservations];
  int<lower=0> NumUtterancesAB[NumObservations];        //Number of times the first message didn't contain the marker
  int<lower=0> NumUtterancesNotAB[NumObservations];     //Number of times the first message did contain the marker
  int<lower=0> CountsAB[NumObservations];               //Number of times the first message didn't contain the marker but the reply did
  int<lower=0> CountsNotAB[NumObservations];            //Number of times the first message did contain the marker and the reply did
  real<lower=0> StdDev;                                 //SD for each normal dist in the hierarchy (sole free parameter)


  vector<lower=0>[NumObservations] ppvt_vals;
  vector<lower=0>[NumObservations] age_years;
  // vector<lower=0>[NumObservations] income_category;
  vector<lower=0>[NumObservations] mother_education;
  vector<lower=0>[NumObservations] female;
  
}

parameters {
  real eta_ab_pop;
  real alpha_pop;
  real beta_pop;
  real eta_pop_Marker[NumMarkers]; //linear predictor for each marker's baseline

  real eta_ab_subpop[NumSubPops];
  real alpha_subpop[NumSubPops];
  real beta_subpop[NumSubPops];

  real eta_ab_speaker[NumSpeakers];
  real alpha_speaker[NumSpeakers];
  real beta_speaker[NumSpeakers];

  vector[NumMarkers] eta_subpop_Marker[NumSubPops];            //lin. pred. for each marker+group baseline
  vector[NumMarkers] eta_speaker_Marker[NumSpeakers];            //lin. pred. for each marker+group baseline
  vector[NumMarkers] eta_ab_speaker_Marker[NumSpeakers];         //lin. pred. for each marker+group alignment

  vector[NumObservations] eta_observation;              //lin. pred. for each marker+dyad baseline
  vector[NumObservations] eta_ab_observation;           //lin. pred. for each marker+dyad alignment

  real<lower=0> sigma; //error term for ppvt linear regression
  real ppvt_intercept; //intercept term for ppvt linear regression

  // demographics coefficients for mu - change in baseline 
  // real mu_income; 
  real mu_education; 
  real mu_female; 

  // demographics coefficients for alignment effect
  // real mu_income_ab; 
  real mu_education_ab; 
  real mu_female_ab; 

  // demographics coefficients for ppvt
  real ppvt_beta_age_years;
  // real ppvt_beta_income; 
  real ppvt_beta_education; 
  real ppvt_beta_female; 

}

transformed parameters {
  vector<lower=0,upper=1>[NumObservations] mu_notab;    //inv-logit transform of lin. pred. into probability space
  vector<lower=0,upper=1>[NumObservations] mu_ab;

  for (Observation in 1:NumObservations) {
    // include mother_ed, SES, sex in mean estimation as scalar values (simple linear predictors)
    mu_notab[Observation] = inv_logit(eta_observation[Observation]  +
                                    beta_speaker[SpeakerId[Observation]] * (SpeakerAge[Observation] - MidAge) +
                                    (mother_education[Observation] * mu_education)+ 
                                    (female[Observation] * mu_female));
    mu_ab[Observation] = inv_logit(eta_ab_observation[Observation] + eta_observation[Observation] +
                                    ((alpha_speaker[SpeakerId[Observation]] + beta_speaker[SpeakerId[Observation]]) *
                                      (SpeakerAge[Observation] - MidAge)) +
                                    (mother_education[Observation] * mu_education)+ 
                                    (female[Observation] * mu_female) +
                                    (mother_education[Observation] * mu_education_ab)+ 
                                    (female[Observation] * mu_female_ab));
  }

}

model {

  //top level alignment
  eta_ab_pop ~ normal(0, StdDev);
  alpha_pop ~ normal(0, StdDev);
  beta_pop ~ normal(0, StdDev);

  eta_pop_Marker ~ uniform(-5,5);   //Note that this distribution may be changed if baselines are expected to be very high/low

  eta_ab_subpop ~ normal(eta_ab_pop, StdDev);

  //marker-group level distributions
  for(SubPop in 1:NumSubPops) {
    eta_subpop_Marker[SubPop] ~ normal(eta_pop_Marker, StdDev);
    alpha_subpop[SubPop] ~ normal(alpha_pop, StdDev);
    beta_subpop[SubPop] ~ normal(beta_pop, StdDev);
  }

  //marker-speaker level distributions
  for(Speaker in 1:NumSpeakers) {
    eta_ab_speaker[Speaker] ~ normal(eta_ab_subpop[SpeakerSubPop[Speaker]], StdDev);

    eta_speaker_Marker[Speaker] ~ normal(eta_subpop_Marker[SpeakerSubPop[Speaker]], StdDev);
    eta_ab_speaker_Marker[Speaker] ~ normal(eta_ab_speaker[Speaker], StdDev);

    alpha_speaker[Speaker] ~ normal(alpha_subpop[SpeakerSubPop[Speaker]], StdDev);
    beta_speaker[Speaker] ~ normal(beta_subpop[SpeakerSubPop[Speaker]], StdDev);
  }

  //marker-dyad level distributions
  for(Observation in 1:NumObservations) {
    eta_observation[Observation] ~ normal(eta_speaker_Marker[SpeakerId[Observation], MarkerType[Observation]], StdDev);
    eta_ab_observation[Observation] ~ normal(eta_ab_speaker_Marker[SpeakerId[Observation], MarkerType[Observation]], StdDev);
  }

  //drawing reply usage counts given number of msg-reply pairs
  CountsAB ~ binomial(NumUtterancesAB, mu_ab);
  CountsNotAB ~ binomial(NumUtterancesNotAB, mu_notab);


  // drawing ppvt values from demographics & alignment estimates - effective linear regression
  ppvt_vals ~ normal(ppvt_intercept + (age_years * ppvt_beta_age_years) +
    (mother_education * ppvt_beta_education)+ 
    (female * ppvt_beta_female), sigma);
}
