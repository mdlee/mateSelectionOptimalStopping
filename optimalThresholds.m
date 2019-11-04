%% Optimal threshold for fixed but non-stationary Gaussian sequence
% v3 fix the truncation in futureValid issue, using https://en.wikipedia.org/wiki/Truncated_normal_distribution

clear;
close all;

load PantoneSpring2015


%% User input
doPrint = false;

environmentNameList = {...
   % 'marriageFemale' ; ...
   % 'marriageMale'   ; ...
   % 'flat'           ; ...
   % 'test'           ; ...
   % 'airTicket'      ; ...
   };

%% Find optimal thresholds for each environment
for envIdx = 1:numel(environmentNameList)
   
   environmentName = environmentNameList{envIdx};
   
   % mean then standard deviation of Gaussian that generates values for each trial
   switch environmentName
      case 'test'
         environment = [...
            55 05;
            65 15;
            40 15;
            40 10;
            35 10;
            90 05;
            60 05;
            50 05;
            70 10;
            20 10];
         values = 0:100;
         showValuesIdx = 11:10:101;
         goal = 'max';
         
      case 'flat'
         environment = [50*ones(10,1) 30*ones(10, 1)];
         values = 0:100;
         showValuesIdx = 11:10:101;
         goal = 'max';
         
      case 'airTicket'
         environment = [...
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            20 05;
            15 10;
            25 05;
            35 05;
            45 05;
            55 05];
         values = 0:100;
         showValuesIdx = 11:10:101;
         goal = 'min';
         
      case 'marriageMale'
         load ../data/desireData mDesire ages
         idx = 1:2:29;
         ages = ages(idx);
         mDesire = mDesire(idx);
         environment = nan(length(idx), 2);
         environment(:, 1) = mDesire;
         environment(:, 2) = [
            10;    % 18
            10;    % 20
            15;    % 22
            15;    % 24
            20;    % 26
            20;    % 28
            25;    % 30
            30;    % 32
            30;    % 34
            30;    % 36
            25;    % 38
            25;    % 40
            20;    % 42
            20;    % 44
            20];    % 46
         
         values = 0:100;
         showValuesIdx = 11:10:101;
         goal = 'max';
         xLabels = sprintfc('%d', ages);
         environmentColor = pantone.DuskBlue;
         xLabel = 'Age';
         
      case 'marriageFemale'
         load ../data/desireData fDesire ages
         idx = 1:2:29;
         ages = ages(idx);
         fDesire = fDesire(idx);
         environment = nan(length(idx), 2);
         environment(:, 1) = fDesire;
         environment(:, 2) = [
            10;    % 18
            10;    % 20
            15;    % 22
            15;    % 24
            20;    % 26
            20;    % 28
            25;    % 30
            30;    % 32
            30;    % 34
            30;    % 36
            25;    % 38
            25;    % 40
            20;    % 42
            20;    % 44
            20];   % 46
         
         values = 0:100;
         showValuesIdx = 11:10:101;
         goal = 'max';
         xLabels = sprintfc('%d', ages);
         environmentColor = pantone.Tangerine;
         xLabel = 'Age';
         
   end
   
   %% Constants
   mu = environment(:, 1);
   sigma = environment(:, 2);
   nTrials = length(mu);
   nValues = length(values);
   
   %% Graphics constants
   if ~exist('environmentColor', 'var')
      environmentColor = pantone.Titanium;
   end
   if ~exist('xLabel', 'var')
      xLabel = 'Trial';
   end
   if ~exist('yLabel', 'var')
      yLabel = 'Value';
   end
   
   thresholdColor = pantone.Treetop;
   fontSize = 18;
   scaleWidth = 15; height = 1;
   thresholdWidth = 0.5;
   
   % optimal thresholds
   thresholds = findOptimalThresholds(mu, sigma, values, goal);
   
   %% Environment Distribution figure
   F = figure(1); clf; hold on;
   set(F, ...
      'color'             , 'w'           , ...
      'units'             , 'normalized'  , ...
      'position'          , [.1 .1 .7 .7] , ...
      'paperpositionmode' , 'auto'        );
   
   set(gca, ...
      'ylim'              , [0 nValues+1]         , ...
      'ytick'             , values(showValuesIdx) , ...
      'xlim'              , [0 nTrials+1]         , ...
      'xtick'             , 1:nTrials             , ...
      'box'               , 'off'                 , ...
      'tickdir'           , 'out'                 , ...
      'ticklength'        , [0.01 0]              , ...
      'fontsize'          , fontSize              );
   if exist('xLabels', 'var')
      set(gca, 'xticklabel', xLabels);
   end
   xlabel(xLabel, 'fontsize', fontSize+2);
   ylabel(yLabel, 'fontsize', fontSize+2);
   
   % draw environment
   for trialIdx = 1:nTrials
      for valIdx = 1:nValues
         width = scaleWidth * 1/sqrt(2*pi*sigma(trialIdx)^2) * exp(-(mu(trialIdx) - values(valIdx))^2/(2*sigma(trialIdx)^2));
         rectangle(...
            'position'  , [trialIdx-width/2 values(valIdx)-height/2 width height] , ...
            'curvature' , [0 0]                                                   , ...
            'facecolor' , environmentColor                                        , ...
            'edgecolor' , 'none'                                                  );
      end
   end
   
   % print
   if doPrint
      print(['figures/environmentDistribution_' environmentName '.png'], '-dpng');
      print(['figures/environmentDistribution_' environmentName '.eps'], '-depsc');
   end
   
   %% Thresholds figure
   F = figure(2); clf; hold on;
   set(F, ...
      'color'             , 'w'           , ...
      'units'             , 'normalized'  , ...
      'position'          , [.1 .1 .8 .7] , ...
      'paperpositionmode' , 'auto'        );
   
   set(gca, ...
      'ylim'              , [0 nValues+1]         , ...
      'ytick'             , values(showValuesIdx) , ...
      'xlim'              , [0 nTrials+1]         , ...
      'xtick'             , 1:nTrials             , ...
      'box'               , 'off'                 , ...
      'tickdir'           , 'out'                 , ...
      'ticklength'        , [0.01 0]              , ...
      'fontsize'          , fontSize              );
   if exist('xLabels', 'var')
      set(gca, 'xticklabel', xLabels);
   end
   xlabel(xLabel, 'fontsize', fontSize+2);
   ylabel(yLabel, 'fontsize', fontSize+2);
   
   % draw environment
   for trialIdx = 1:nTrials
      for valIdx = 1:nValues
         width = scaleWidth * 1/sqrt(2*pi*sigma(trialIdx)^2) * exp(-(mu(trialIdx) - values(valIdx))^2/(2*sigma(trialIdx)^2));
         rectangle(...
            'position'  , [trialIdx-width/2 values(valIdx)-height/2 width height] , ...
            'curvature' , [0 0]                                                   , ...
            'facecolor' , environmentColor                                        , ...
            'edgecolor' , 'none'                                                  );
      end
   end
   
   % draw thresholds
   for trialIdx = 1:(nTrials-1)
      rectangle(...
         'position'  , [trialIdx-thresholdWidth/2 thresholds(trialIdx)-height/2 thresholdWidth height] , ...
         'curvature' , [0 0]                                                                           , ...
         'facecolor' , thresholdColor                                                                  , ...
         'edgecolor' , 'none'                                                                          );
      text(trialIdx+thresholdWidth/2, thresholds(trialIdx), sprintf('%d', thresholds(trialIdx)), ...
         'fontsize', fontSize);
   end
   
   % print
   if doPrint
      print(['figures/optimalThresholds_' environmentName '.png'], '-dpng');
      print(['figures/optimalThresholds_' environmentName '.eps'], '-depsc');
   end
   
end

