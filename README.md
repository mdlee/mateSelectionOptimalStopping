# Mate Selection Optimal Stopping

## General

Many of these files use the color palette in `PantoneSpring2015.mat` and the `RAxes.m` function for graphs.

## Data

`generateStimuli.m` is  script for generating a representative set of problems for an environment

The experimental data are in the MATLAB file `MateChoiceApril1st.mat`which contains a single structured variable `d` with the fields:

```
                   nProblems: 50
                  nPositions: 15
               nEnvironments: 2
                      values: [50×15×2 double]
                     nValues: 99
            environmentNames: {'female'  'male'}
                   nSubjects: 55
                      gender: [55×1 double]
                         age: [55×1 double]
                    decision: [55×50×2 double]
                   startTime: {1×55 cell}
                    stopTime: {1×55 cell}
                        ages: [18 20 22 24 26 28 30 32 34 36 38 40 42 44 46]
    environmentDistributions: {[15×2 double]  [15×2 double]}
       environmentOrderNames: '1 is female first, 2 is male first'
            environmentOrder: [55×1 double]
                       order: [55×50×2 double]
                   maxChoice: [50×2 double]
           optimalThresholds: {[15×1 double]  [15×1 double]}
                   optChoice: [50×2 double]
```

The field variables contain the following information

* `nProblems` is the number of optimal stopping problems given to each participant in each environment
* `nPositions` is the number of alternatives (ages) in each problem
* `ages` gives the ages used to label each alternative
* `nEnvironments` is the number of environments
* `environmentNames` describes the environments
* `values`gives the value presented for each problem for each alternative in each environment
* `nValues` gives the number of unique possible values (there are 99 since the value 100 was not used)
* `maxChoice`is the alternative corresponding to the maximum value for each problem in each environment
* `optChoice`is the alternative corresponding to the the optimal decision process for each problem in each environment
* `optimalThresholds` is a cell variable containing a vector for each environment. Each vector lists the sequence of optimal thresholds for that environment.
* `nSubjects` is the number of participants in the experiment
* `gender` is the gender of each participant (1=female, 2=male)
* `age` is the age of each participant in years
* `decision` is the option chosen by each participant on each problem in each environment
* `startTime`gives the experiment starting time for each participant, in a day and time format
* `stopTime`gives the experiment finishing time for each participant, in a day and time format
* `environmentDistributions`is a cell structure containing a matrix for each environment, giving details of the statistical distributions from which values are drawn For each matrix, the rows corresponding to alternatives, the first column corresponding to the mode of the truncated Gaussian distribution, and the second column corresponding to the standard deviation of the truncated Gaussian distribution.
* `environmentOrder`is the order in which each participants completed the problems in the environments
* `environmentOrderNames` is the coding used to represent the order in which environments were completed
* `order`is the sequence of problems completed by each participant in each environment

## Statistical Analysis

* `drawMateChoice.m` is a script that draws basic data analysis figures.
  
  ```
  analysisList = { ...
     % 'ProcessOutcomeOptimality'   ; ...
     % 'BeforeAfterChosen'          ; ...
     % 'ChosenInPosition'           ; ...
     % 'Learning'                   ; ...
     % 'IndividualByEnvironment'    ; ...
     % 'ConsolidatedResults'        ; ...
     % 'ConsolidatedResults2'       ; ... 
     };
  ```
  
* `optimalThresholds.m` is a script finds the optimal thresholds for a given environment, and draws the environment, and the environment with the optimal thresholds. It uses the `findOptimalThresholds.m` function. The following environments are currently included.

  ```
  environmentNameList = {...
      % 'marriageFemale' ; ...
      % 'marriageMale'   ; ...
      % 'flat'           ; ...
      % 'test'           ; ...
      % 'airTicket'      ; ...
      };
  ```
## Modeling Analysis

* `optimalPlayer.m` is a function that applies the optimal decision process to an environment

  ```
  function results = optimalPlayer(mu, sigma, values, goal, nReps)
  % results = optimalPlayer(mu, sigma, values, goal)
  %  characterizes the performance of the optimal player for an optimal
  %  stopping problem in which the presented value from values on each trial
  %  is drawn from truncated Gaussians with means mu and standard deviations sigma
  %  according to a goal of 'min' or 'max', based on nReps simulated problems
  %
  % results.chosen  = the trial chosen by optimal player
  % results.value   = the value chosen by optimal player
  % results.optimal = whether or not the chosen value was maximal
  ```

* `optimalStoppingPlayerGiven.m` is a function that applies a given set of thresholds to an environment

    ```
    function results = optimalStoppingPlayerGiven(m, thresholds, goal)
    % results = optimalStoppingPlayerGiven(m, thresholds, goal)
    %  characterizes the performance of a player for given problems
    %  in m according to given thresholds a goal of 'min' or 'max',
    %
    % results.chosen  = the trial chosen by player
    % results.value   = the value chosen by player
    % results.correct = whether or not the chosen value was maximal
    ```

 * `thresholdIndependent.m` is a script that applies the general independent-threshold model in `thresholdIndependent.txt` to data, and generates a variety of analyses and plots. It also saves the posterior predictive descriptive accuracies for each participant to a `predy_.mat`file. The analyses and figures are chosen by setting the data and options in the first code block

    ```
    dataName = 'mateChoice2019'; subjectList = 1:55;
    % dataName = 'mateChoice2019'; subjectList = [1 8 44]; nRows = 2; nCols = 3; % for draw select individuals option
    % dataName = 'mateChoice2019'; subjectList = [44]; nRows = 1; nCols = 2; % for draw select individuals option
    
    drawIndividuals = false;
    drawSelectIndividuals = true;
    drawGroup = false;
    ```

    

`