//This is the version of the HAM framework used in Yurovsky, Doyle, & Frank 2016 (Cogsci Conference)
// Baseline prior is uniform, alignment prior is normal
// hierarchy is: marker, marker+group, marker+dyad

data {
  int<lower=0> NumMarkers;                              //Number of marker categories in data
  real<lower=0> MidAge;
  int<lower=0> NumSubPops;                              //Number of groups in the data
  int<lower=0> NumSpeakers;                             //Identity of each speaker
  int<lower=0> NumObservations;                         //Number of marker-dyad observations
  int<lower=0> NumSex; 
  int<lower=0> NumMomEd; 
  int<lower=0> SpeakerSubPop[NumSpeakers];          //Group number for each observation
  int<lower=0> SpeakerSex[NumSpeakers];
  int<lower=0> SpeakerMomEd[NumSpeakers];
  int<lower=0> SpeakerAge[NumObservations];          //Group number for each observation
  int<lower=0> SpeakerId[NumObservations];

  int<lower=0> mother_education[NumObservations];// mother's ed marker for utterance
  int<lower=0> female[NumObservations]; // female marker for utterance

  real current_prop[NumObservations,NumMarkers]; //LOGIT TRANSFORMED proportions for current utterance
  real lag_prop[NumObservations,NumMarkers]; //LOGIT TRANSFORMED proportions for lagging utterance

  // int<lower=0> NumUtterancesAB[NumObservations];        //Number of times the first message didn't contain the marker
  // int<lower=0> NumUtterancesNotAB[NumObservations];     //Number of times the first message did contain the marker
  // int<lower=0> CountsAB[NumObservations];               //Number of times the first message didn't contain the marker but the reply did
  // int<lower=0> CountsNotAB[NumObservations];            //Number of times the first message did contain the marker and the reply did
  real<lower=0> StdDev;                                 //SD for each normal dist in the hierarchy (sole free parameter)


  int<lower=0> NumPPVT; // number of ppvt scores
  real<lower=0>ppvt_vals[NumPPVT];
  // real ppvt_slopes[NumObservations];
  real<lower=0> age_years[NumPPVT];
  // vector<lower=0>[NumObservations] income_category;

  int<lower=0> mother_education_ppvt_data[NumPPVT]; // mother's ed for ppvt scores
  int<lower=0> female_ppvt_data[NumPPVT]; //female marker for ppvt scores


  int<lower=0>parentid[NumPPVT]; //for every ppvt score, the speakerid for the parent
  int<lower=0>childid[NumPPVT]; // for every ppvt score, the speakerid for the child
}

parameters {
  // real eta_ab_pop;
  // real alpha_pop;
  // real beta_pop;
  real eta_pop_Marker[NumMarkers]; //linear predictor for each marker's baseline

  real eta_ab_subpop[NumSubPops]; // aggregate estimates for parents and children
  real alpha_subpop[NumSubPops];
  real beta_subpop[NumSubPops];

  real eta_ab_speaker[NumSpeakers]; // estimates for each speaker
  real alpha_speaker[NumSpeakers];
  real beta_speaker[NumSpeakers];

  // real gender_ab[NumSubPops];
  // real mom_ed_ab[NumSubPops];

  // real gender_alpha[NumSubPops];
  // real mom_ed_alpha[NumSubPops];

  // real gender_beta[NumSubPops];
  // real mom_ed_beta[NumSubPops];

  vector[NumMarkers] eta_subpop_Marker[NumSubPops];            //lin. pred. for each marker+group baseline
  vector[NumMarkers] eta_speaker_Marker[NumSpeakers];            //lin. pred. for each marker+group baseline
  vector[NumMarkers] eta_ab_speaker_Marker[NumSpeakers];         //lin. pred. for each marker+group alignment

  real eta_observation [NumObservations, NumMarkers];              //lin. pred. for each marker+dyad baseline
  real eta_ab_observation [NumObservations, NumMarkers];           //lin. pred. for each marker+dyad alignment

  real<lower=0> sigma; //error term for ppvt linear regression
  real ppvt_intercept; //intercept term for ppvt linear regression

  real<lower=0> prop_sigma; //error term for prop linear regression

  // demographics coefficients for mu - change in baseline; estimated for each subpop
  // real mu_income; 
  // real mu_education[NumSubPops]; //
  // real mu_female[NumSubPops]; // 

  // demographics coefficients for alignment effect; estimated for each subpop
  // real mu_income_ab; 
  // real mu_education_ab[NumSubPops]; 
  // real mu_female_ab[NumSubPops]; 

  // demographics coefficients for ppvt
  real ppvt_age_years;
  // real ppvt_beta_income; 
  real ppvt_education; 
  real ppvt_female; 
  real ppvt_child_align;
  real ppvt_parent_align;
  real ppvt_child_align_slope;
  real ppvt_parent_align_slope;
  real ppvt_mother_ed_slope;
  real ppvt_female_slope;


  
}

model {
  //top level alignment
  // eta_ab_pop ~ normal(0, StdDev);
  // alpha_pop ~ normal(0, StdDev);
  // beta_pop ~ normal(0, StdDev);

  eta_pop_Marker ~ uniform(-5,5);   //Note that this distribution may be changed if baselines are expected to be very high/low

  eta_ab_subpop ~ normal(0, StdDev);

  // gender_ab ~ normal(0,StdDev);
  // mom_ed_ab ~ normal(0,StdDev);

  // gender_alpha ~ normal(0,StdDev);
  // mom_ed_alpha ~ normal(0,StdDev);

  // gender_beta ~ normal(0, StdDev);
  // mom_ed_beta ~ normal(0, StdDev); 

  //marker-group level distributions
  for(SubPop in 1:NumSubPops) {
    eta_subpop_Marker[SubPop] ~ normal(eta_pop_Marker, StdDev);
    alpha_subpop[SubPop] ~ normal(0, StdDev);
    beta_subpop[SubPop] ~ normal(0, StdDev);
    // alpha_subpop[SubPop] ~ normal(alpha_pop, StdDev);
    // beta_subpop[SubPop] ~ normal(beta_pop, StdDev);
  }

  //marker-speaker level distributions
  for(Speaker in 1:NumSpeakers) {
    // eta_ab_speaker[Speaker] ~ normal((eta_ab_subpop[SpeakerSubPop[Speaker]] + 
    //   gender_ab[SpeakerSubPop[Speaker]] * SpeakerSex[Speaker]+
    //   mom_ed_ab[SpeakerSubPop[Speaker]] * SpeakerMomEd[Speaker]), StdDev);

    // eta_speaker_Marker[Speaker] ~ normal(eta_subpop_Marker[SpeakerSubPop[Speaker]], StdDev);
    // eta_ab_speaker_Marker[Speaker] ~ normal(eta_ab_speaker[Speaker], StdDev);

    // alpha_speaker[Speaker] ~ normal(alpha_subpop[SpeakerSubPop[Speaker]]+
    //   gender_alpha[SpeakerSubPop[Speaker]] * SpeakerSex[Speaker]+
    //   mom_ed_alpha[SpeakerSubPop[Speaker]] * SpeakerMomEd[Speaker], StdDev);
    
    // beta_speaker[Speaker] ~ normal(beta_subpop[SpeakerSubPop[Speaker]]+
    //   gender_beta[SpeakerSubPop[Speaker]] * SpeakerSex[Speaker]+
    //   mom_ed_beta[SpeakerSubPop[Speaker]] * SpeakerMomEd[Speaker], StdDev);

    eta_ab_speaker[Speaker] ~ normal((eta_ab_subpop[SpeakerSubPop[Speaker]]), StdDev);

    eta_speaker_Marker[Speaker] ~ normal(eta_subpop_Marker[SpeakerSubPop[Speaker]], StdDev);
    eta_ab_speaker_Marker[Speaker] ~ normal(eta_ab_speaker[Speaker], StdDev);

    alpha_speaker[Speaker] ~ normal(alpha_subpop[SpeakerSubPop[Speaker]], StdDev);
    
    beta_speaker[Speaker] ~ normal(beta_subpop[SpeakerSubPop[Speaker]], StdDev);
  }

  //marker-dyad level distributions
  for(Observation in 1:NumObservations) {
    for (Marker in 1:NumMarkers){
      eta_observation[Observation, Marker] ~ normal(eta_speaker_Marker[SpeakerSubPop[SpeakerId[Observation]], Marker], StdDev);
      eta_ab_observation[Observation, Marker] ~ normal(eta_ab_speaker_Marker[SpeakerSubPop[SpeakerId[Observation]], Marker], StdDev);
    }
  }

  // ADD PARAMETERS ABOVE FROM HERE
  // need to enforce normalization for current_prop draw?

  // try sigmoid instead of linear for alignment by age?



  // Marker-level proportion draw for every utterance

  // predict props in logit space (real values); no prediction for null
  for (Observation in 1:NumObservations) {
    for (Marker in 1:NumMarkers){
      current_prop[Observation, Marker] ~ normal(eta_observation[Observation, Marker] + 
        (alpha_speaker[SpeakerId[Observation]] * (SpeakerAge[Observation] - MidAge)) + 
        (eta_ab_observation[Observation, Marker] * lag_prop[Observation, Marker]) +
        (beta_speaker[SpeakerId[Observation]] * (SpeakerAge[Observation] - MidAge)), prop_sigma);
    }
  }


  // need to do factor analysis on all available outcome measures to create robust language development measure
  // predict ppvt and slope using demos AND parent and child alignment estimate
  for (PPVT in 1:NumPPVT){
    ppvt_vals[PPVT] ~ normal(ppvt_intercept + 
      (age_years[PPVT] * ppvt_age_years) + 
      (mother_education_ppvt_data[PPVT] * ppvt_education)+ 
      (female_ppvt_data[PPVT] * ppvt_female) +
      (eta_ab_speaker[childid[PPVT]] * ppvt_child_align) + 
      (eta_ab_speaker[parentid[PPVT]] * ppvt_parent_align) + 
      (eta_ab_speaker[childid[PPVT]] * age_years[PPVT] * ppvt_child_align_slope) + 
      (eta_ab_speaker[parentid[PPVT]] * age_years[PPVT] * ppvt_parent_align_slope) +
      (mother_education_ppvt_data[PPVT] * age_years[PPVT] * ppvt_mother_ed_slope)+
      (female_ppvt_data[PPVT] * age_years[PPVT] * ppvt_female_slope)
      , sigma);
  }
  
}
