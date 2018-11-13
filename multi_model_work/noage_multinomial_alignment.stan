//This is the updated version of the HAM framework used in Yurovsky, Doyle, & Frank 2016 (Cogsci Conference)
//Now estimates usage of LIWC categories for each reply given usage in preceding message

// Baseline prior is uniform, alignment prior is normal
// hierarchy is: marker, marker+group, marker+dyad

data {
  int<lower=0> NumMarkers;                              //Number of marker categories in data
  real<lower=0> MidAge;
  int<lower=0> NumSubPops;                              //Number of groups in the data
  int<lower=0> NumObservations;                         //Number of marker-dyad observations
  int<lower=0> SpeakerSubPop[NumObservations];          //Group number for each observation
  // int<lower=0> SpeakerAge[NumObservations];             //Group number for each observation
  
  int<lower=0> LiwcCounts[NumObservations, NumMarkers+1]; //Counts for Utterances (Responses); includes null category
  int<lower=0> LagCounts[NumObservations, NumMarkers]; //Counts for Lag Utterances (Messages); doesn't include null category

  real<lower=0> StdDev;                                 //SD for each normal dist in the hierarchy (sole free parameter)
}

parameters {      
  real eta_ab_pop;
  // real alpha_pop;
  // real beta_pop;
  real eta_pop_Marker[NumMarkers+1];                      //linear predictor for each marker's baseline
  real eta_ab_subpop[NumSubPops];
  // real alpha_subpop[NumSubPops];
  // real beta_subpop[NumSubPops];

  // matrix[NumSubPops, NumMarkers+1] eta_subpop_Marker;            //lin. pred. for each marker+group baseline
  // matrix[NumSubPops, NumMarkers] eta_ab_subpop_Marker;         //lin. pred. for each marker+group alignment
  // matrix[NumObservations, NumMarkers+1] eta_observation;              //lin. pred. for each marker+dyad baseline
  // matrix[NumObservations, NumMarkers] eta_ab_observation;           //lin. pred. for each marker+dyad alignment


  real eta_subpop_Marker [NumSubPops, NumMarkers+1];            //lin. pred. for each marker+group baseline
  real eta_ab_subpop_Marker [NumSubPops, NumMarkers];         //lin. pred. for each marker+group alignment
  real eta_observation [NumObservations, NumMarkers+1];              //lin. pred. for each marker+dyad baseline
  real eta_ab_observation [NumObservations, NumMarkers];           //lin. pred. for each marker+dyad alignment

}

transformed parameters {

  vector<lower=0,upper=1>[NumMarkers+1] mu[NumObservations]; //inv-logit transform of lin. pred. into probability space

  for (Observation in 1:NumObservations) {

    // vectorizing the inner loop? requires reformatting to eliminate null category as special case
    // maybe have alignment estimation for null cat but stipulate lag counts are always 0 to eliminate impact?


        for (Marker in 1:NumMarkers) {
                   
          mu[Observation, Marker] = inv_logit(eta_observation[Observation, Marker] + 
            (eta_ab_observation[Observation,Marker] * LagCounts[Observation, Marker])); // no age effect on anything


           // mu_notab[Observation,Marker] = inv_logit(eta_observation[Observation,Marker]  + 
           //                          beta_subpop[SpeakerSubPop[Observation,Marker]] * (SpeakerAge[Observation,Marker] - MidAge));

           // mu_ab[Observation, Marker] = inv_logit(eta_ab_observation[Observation, Marker] + eta_observation[Observation,Marker] + 
           //                                ((alpha_subpop[SpeakerSubPop[Observation,Marker]] + beta_subpop[SpeakerSubPop[Observation,Marker]]) * 
           //                                  (SpeakerAge[Observation,Marker] - MidAge)));
        }
        
        // mu_notab[Observation,NumMarkers + 1] = inv_logit(eta_observation[Observation,NumMarkers+1]  + 
                                    // beta_subpop[SpeakerSubPop[Observation,NumMarkers+1]] * (SpeakerAge[Observation,NumMarkers+1] - MidAge)); //for estimating baseline for null category
        mu[Observation, NumMarkers+1] = inv_logit(eta_observation[Observation, NumMarkers+1]);
  }
  

  // mu_ab[Observation,NumMarkers+1] = 0; //no alignment for null category

}

// Multinomal(takes mu parameter for every marker category (including the null LIWC cat.))
// Mu will be a vector of length equal to number of LIWC categories + 1 (for every observation)

model {
  //top level alignment
  eta_ab_pop ~ normal(0, StdDev);
  // alpha_pop ~ normal(0, StdDev);
  // beta_pop ~ normal(0, StdDev);

  eta_pop_Marker ~ uniform(-5,5);     //Note that this distribution may be changed if baselines are expected to be very high/low

  eta_ab_subpop ~ normal(eta_ab_pop, StdDev);

  //marker-group level distributions
  for(SubPop in 1:NumSubPops) {
    eta_subpop_Marker[SubPop] ~ normal(eta_pop_Marker, StdDev);
    eta_ab_subpop_Marker[SubPop] ~ normal(eta_ab_subpop[SubPop], StdDev);
    // alpha_subpop[SubPop] ~ normal(alpha_pop, StdDev);
    // beta_subpop[SubPop] ~ normal(beta_pop, StdDev);
  }

  //marker-dyad level distributions
  for(Observation in 1:NumObservations) {
    for (Marker in 1:NumMarkers){
      eta_observation[Observation, Marker] ~ normal(eta_subpop_Marker[SpeakerSubPop[Observation], Marker], StdDev);
      eta_ab_observation[Observation, Marker] ~ normal(eta_ab_subpop_Marker[SpeakerSubPop[Observation], Marker], StdDev);
    }

    eta_observation[Observation, NumMarkers+1] ~ normal(eta_subpop_Marker[SpeakerSubPop[Observation], NumMarkers+1], StdDev); //for estimating baseline for null category

    
  }

  //drawing LIWC cat. usage counts in reply

  for(Observation in 1:NumObservations){
    // print("Observation probs=", mu[Observation]);
    LiwcCounts[Observation] ~ multinomial(softmax(mu[Observation]));
    // for(Marker in 1:NumMarkers){
    //   LiwcCounts[Observation, NumMarkers] ~ multinomial()
  }

}

    