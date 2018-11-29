//This is the updated version of the HAM framework used in Yurovsky, Doyle, & Frank 2016 (Cogsci Conference)
//Now estimates usage of LIWC categories for each reply given usage in preceding message

// Baseline prior is uniform, alignment prior is normal
// hierarchy is: marker, marker+group, marker+dyad

data {
  int<lower=0> NumMarkers;                              //Number of marker categories in data
  vector <lower=0> [NumMarkers+1] MidAge;
  int<lower=0> NumSubPops;                              //Number of groups in the data
  int<lower=0> NumObservations;                         //Number of marker-dyad observations
  int<lower=0> SpeakerSubPop[NumObservations];          //Group number for each observation
  vector<lower=0>[NumMarkers+1]SpeakerAge[NumObservations];             //Group number for each observation

  // matrix<lower=0>[NumObservations, NumMarkers+1] LiwcCounts; //Counts for Utterances (Responses); includes null category
  // matrix<lower=0>[NumObservations, NumMarkers] LagCounts; //Counts for Lag Utterances (Messages); doesn't include null category

  int<lower=0> LiwcCounts[NumObservations, NumMarkers+1]; //Counts for Utterances (Responses); includes null category
  // SAME DIMENSION FOR VECTORIZING; LagCounts entry for null should ALWAYS be 0
  vector<lower=0>[NumMarkers+1] LagCounts[NumObservations]; //Counts for Lag Utterances (Messages); doesn't include null category

  real<lower=0> StdDev;                                 //SD for each normal dist in the hierarchy (sole free parameter)
}

parameters {      
  real eta_ab_pop;
  real alpha_pop;
  real beta_pop;
  real eta_pop_Marker[NumMarkers+1];                      //linear predictor for each marker's baseline
  real eta_ab_subpop[NumSubPops];
  vector [NumMarkers+1] alpha_subpop[NumSubPops];
  vector [NumMarkers+1] beta_subpop[NumSubPops];

  // matrix[NumSubPops, NumMarkers+1] eta_subpop_Marker;            //lin. pred. for each marker+group baseline
  // matrix[NumSubPops, NumMarkers] eta_ab_subpop_Marker;         //lin. pred. for each marker+group alignment
  // matrix[NumObservations, NumMarkers+1] eta_observation;              //lin. pred. for each marker+dyad baseline
  // matrix[NumObservations, NumMarkers] eta_ab_observation;           //lin. pred. for each marker+dyad alignment


  real eta_subpop_Marker [NumSubPops, NumMarkers+1];            //lin. pred. for each marker+group baseline
  real eta_ab_subpop_Marker [NumSubPops, NumMarkers+1];         //lin. pred. for each marker+group alignment
  vector [NumMarkers+1] eta_observation [NumObservations];              //lin. pred. for each marker+dyad baseline
  vector [NumMarkers+1] eta_ab_observation [NumObservations] ;              //lin. pred. for each marker+dyad baseline

}

transformed parameters {

  // matrix<lower=0,upper =1>[NumObservations, NumMarkers+1] mu; //inv-logit transform of lin. pred. into probability space

  // real<lower=0,upper =1> mu[NumObservations, NumMarkers+1]; //inv-logit transform of lin. pred. into probability space

  vector<lower=0,upper=1>[NumMarkers+1] mu[NumObservations]; //inv-logit transform of lin. pred. into probability space
  

  // int ones[NumMarkers+1];
  // ones = rep_array(1, NumMarkers+1);
  // real ones[NumMarkers+1]; 
  // ones = 1;

  // simplex[NumMarkers+1] mu[NumObservations]; //inv-logit transform of lin. pred. into probability space


  // ATTEMPT AT VECTORIZING INNER LOOP
  for (Observation in 1:NumObservations) {

    mu[Observation] = inv_logit(eta_observation[Observation] + 
      (alpha_subpop[SpeakerSubPop[Observation]] .* (SpeakerAge[Observation] - MidAge)) +
      (eta_ab_observation[Observation] .* LagCounts[Observation]) + 
      (beta_subpop[SpeakerSubPop[Observation]] .* (SpeakerAge[Observation] - MidAge)));


    // no log transform for lag counts since adding ones is an ordeal apparently

    // mu[Observation] = inv_logit(eta_observation[Observation] + 
    //   (alpha_subpop[SpeakerSubPop[Observation]] * (SpeakerAge[Observation] - MidAge)) +
    //   (eta_ab_observation[Observation] * log(LagCounts[Observation] + ones)) + 
    //   (beta_subpop[SpeakerSubPop[Observation]] * (SpeakerAge[Observation] - MidAge)));


        // for (Marker in 1:NumMarkers) {

        //   mu[Observation, Marker] = inv_logit(eta_observation[Observation, Marker] + 
        //     (alpha_subpop[SpeakerSubPop[Observation]] * (SpeakerAge[Observation] - MidAge)) +
        //     (eta_ab_observation[Observation,Marker] * log(LagCounts[Observation, Marker] + 1)) + 
        //     (beta_subpop[SpeakerSubPop[Observation]] * (SpeakerAge[Observation] - MidAge)));


        //    // mu_notab[Observation,Marker] = inv_logit(eta_observation[Observation,Marker]  + 
        //    //                          beta_subpop[SpeakerSubPop[Observation,Marker]] * (SpeakerAge[Observation,Marker] - MidAge));

        //    // mu_ab[Observation, Marker] = inv_logit(eta_ab_observation[Observation, Marker] + eta_observation[Observation,Marker] + 
        //    //                                ((alpha_subpop[SpeakerSubPop[Observation,Marker]] + beta_subpop[SpeakerSubPop[Observation,Marker]]) * 
        //    //                                  (SpeakerAge[Observation,Marker] - MidAge)));
        // }
        
        // // mu_notab[Observation,NumMarkers + 1] = inv_logit(eta_observation[Observation,NumMarkers+1]  + 
        //                             // beta_subpop[SpeakerSubPop[Observation,NumMarkers+1]] * (SpeakerAge[Observation,NumMarkers+1] - MidAge)); //for estimating baseline for null category
        // mu[Observation, NumMarkers+1] = inv_logit(eta_observation[Observation, NumMarkers+1] + 
        //   ((beta_subpop[SpeakerSubPop[Observation]]) * (SpeakerAge[Observation] - MidAge)));

    mu[Observation] = mu[Observation] / sum(mu[Observation]); // for normalizing probability vector

  }
  

  // mu_ab[Observation,NumMarkers+1] = 0; //no alignment for null category

}

// Multinomal(takes mu parameter for every marker category (including the null LIWC cat.))
// Mu will be a vector of length equal to number of LIWC categories + 1 (for every observation)

model {
  //top level alignment
  eta_ab_pop ~ normal(0, StdDev);
  alpha_pop ~ normal(0, StdDev);
  beta_pop ~ normal(0, StdDev);

  eta_pop_Marker ~ uniform(-20, 20);     //Note that this distribution may be changed if baselines are expected to be very high/low

  eta_ab_subpop ~ normal(eta_ab_pop, StdDev);

  //marker-group level distributions
  for(SubPop in 1:NumSubPops) {
    eta_subpop_Marker[SubPop] ~ normal(eta_pop_Marker, StdDev);
    eta_ab_subpop_Marker[SubPop] ~ normal(eta_ab_subpop[SubPop], StdDev);
    alpha_subpop[SubPop] ~ normal(alpha_pop, StdDev);
    beta_subpop[SubPop] ~ normal(beta_pop, StdDev);
  }

  //marker-dyad level distributions
  for(Observation in 1:NumObservations) {
    eta_observation[Observation] ~ normal(eta_subpop_Marker[SpeakerSubPop[Observation]], StdDev);
    eta_ab_observation[Observation] ~ normal(eta_ab_subpop_Marker[SpeakerSubPop[Observation]], StdDev);

    // for (Marker in 1:NumMarkers){
    //   eta_observation[Observation, Marker] ~ normal(eta_subpop_Marker[SpeakerSubPop[Observation], Marker], StdDev);
    //   eta_ab_observation[Observation, Marker] ~ normal(eta_ab_subpop_Marker[SpeakerSubPop[Observation], Marker], StdDev);
    // }

    // eta_observation[Observation, NumMarkers+1] ~ normal(eta_subpop_Marker[SpeakerSubPop[Observation], NumMarkers+1], StdDev); //for estimating baseline for null category

    
  }

  //drawing LIWC cat. usage counts in reply

  for(Observation in 1:NumObservations){
    // print("Observation probs=", mu[Observation]);
    LiwcCounts[Observation] ~ multinomial(mu[Observation]);
    // for(Marker in 1:NumMarkers){
    //   LiwcCounts[Observation, NumMarkers] ~ multinomial()
  }

}

    