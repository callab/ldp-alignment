//This is the version of the HAM framework used in Yurovsky, Doyle, & Frank 2016 (Cogsci Conference)
// Baseline prior is uniform, alignment prior is normal
// hierarchy is: marker, marker+group, marker+dyad

// Model just estimating session-level subpopulation alignment to validate linear relationship assumption

data {
  int<lower=0> NumMarkers;                              //Number of marker categories in data
  real<lower=0> MidAge;
  int<lower=0> NumSubPops;                              //Number of groups in the data
  int<lower=0> NumSpeakers;                             //Identity of each speaker
  int<lower=0> NumObservations;                         //Number of marker-dyad observations
  int<lower=0> NumSex; 
  int<lower=0> NumMomEd; 
  int<lower=0> NumAges;                                 //Number of Sessions
  int<lower=0> SpeakerSubPop[NumSpeakers];          //Group number for each observation
  int<lower=0> SpeakerSex[NumSpeakers];
  int<lower=0> SpeakerMomEd[NumSpeakers];
  int<lower=0> SpeakerAge[NumObservations];          //Group number for each observation
  int<lower=0> MarkerType[NumObservations];             //Marker number for each observation
  int<lower=0> SpeakerId[NumObservations];
  int<lower=0> NumUtterancesAB[NumObservations];        //Number of times the first message didn't contain the marker
  int<lower=0> NumUtterancesNotAB[NumObservations];     //Number of times the first message did contain the marker
  int<lower=0> CountsAB[NumObservations];               //Number of times the first message didn't contain the marker but the reply did
  int<lower=0> CountsNotAB[NumObservations];            //Number of times the first message did contain the marker and the reply did
  real<lower=0> StdDev;                                 //SD for each normal dist in the hierarchy (sole free parameter)

  int<lower=0>parentid[NumObservations]; //for every utterance, the speakerid for the parent
  int<lower=0>childid[NumObservations]; // for every utterance, the speakerid for the child
}

parameters {

  real eta_subpop[NumSubPops];                                   //lin. pred. for each group baseline
  real eta_ab_subpop[NumSubPops]; // aggregate estimates for parents and children


  vector[NumAges] eta_session[NumSubPops];            //lin. pred. for each marker+group baseline
  vector[NumAges] eta_ab_session[NumSubPops];         //lin. pred. for each marker+group alignment

  vector[NumObservations] eta_observation;              //lin. pred. for each marker+dyad baseline
  vector[NumObservations] eta_ab_observation;           //lin. pred. for each marker+dyad alignment

}

transformed parameters {
  vector<lower=0,upper=1>[NumObservations] mu_notab;    //inv-logit transform of lin. pred. into probability space
  vector<lower=0,upper=1>[NumObservations] mu_ab;

  for (Observation in 1:NumObservations) {
    mu_notab[Observation] = inv_logit(eta_observation[Observation]);

    mu_ab[Observation] = inv_logit(eta_ab_observation[Observation] + eta_observation[Observation]);
  }

}

model {
  //top level alignment
  // eta_ab_pop ~ normal(0, StdDev);
  // alpha_pop ~ normal(0, StdDev);
  // beta_pop ~ normal(0, StdDev);

  eta_ab_subpop ~ normal(0, StdDev);
  eta_subpop ~ normal(0, StdDev); 

  //Subpop-session level distributions
  for(Subpop in 1:NumSubPops) {

    eta_ab_session[Subpop] ~ normal((eta_ab_subpop[Subpop]), StdDev);

    eta_session[Subpop] ~ normal(eta_subpop[Subpop], StdDev);

  }

  //marker-dyad level distributions
  for(Observation in 1:NumObservations) {
    eta_observation[Observation] ~ normal(eta_session[SpeakerSubPop[SpeakerId[Observation]], SpeakerAge[SpeakerId[Observation]]], StdDev);
    eta_ab_observation[Observation] ~ normal(eta_ab_session[SpeakerSubPop[SpeakerId[Observation]], SpeakerAge[SpeakerId[Observation]]], StdDev);
  }

  //drawing reply usage counts given number of msg-reply pairs
  CountsAB ~ binomial(NumUtterancesAB, mu_ab);
  CountsNotAB ~ binomial(NumUtterancesNotAB, mu_notab);
  
}
