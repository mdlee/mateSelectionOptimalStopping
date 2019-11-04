%% Data analysis of Mate Choice experiment

clear;
close all;

% user input

doPrint = false;

% analyses
analysisList = { ...
   % 'ProcessOutcomeOptimality'   ; ...
   % 'BeforeAfterChosen'          ; ...
   % 'ChosenInPosition'           ; ...
   % 'Learning'                   ; ...
   % 'IndividualByEnvironment'    ; ...
   % 'ConsolidatedResults'        ; ...
   % 'ConsolidatedResults2'       ; ... 
   };

% load data
load('../data/MateChoiceApril1st', 'd');

% color palette
try load pantoneSpring2015 pantone; catch, load PantoneSpring2015 pantone; end

% constants
colors{1} = pantone.Tangerine;
colors{2} = pantone.DuskBlue;
xlabels{1} = 'Female Age';
xlabels{2} = 'Male Age';
xLabels = sprintfc('%d', d.ages);


if exist('removeSubjects', 'var')
   keepSubjects = setdiff(1:d.nSubjects, removeSubjects);
   d.nSubjects = length(keepSubjects);
   d.gender = d.gender(keepSubjects);
   d.age = d.age(keepSubjects);
   d.decision = d.decision(keepSubjects, :, :);
   d.order = d.order(keepSubjects, :, :);
end

for analysisIdx = 1:numel(analysisList)
   
   analysis = analysisList{analysisIdx};
   
   switch analysis
      
      case 'ProcessOutcomeOptimality'
         
         % constants
         step = .025; scale = 0.25;
         fontSize = 12;
         
         % derived constants
         binsC = step/2:step:(1-step/2);
         binsE = 0:step:1;
         edges{1} = binsE;
         edges{2} = binsE;
         
         % figure and axes
         F = figure(1); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.4 0.6] , ...
            'paperpositionmode' , 'auto'            );
         
         set(gca, ...
            'units'         , 'normalized'        , ...
            'position'      , [0.15 0.15 0.7 0.7] , ...
            'xlim'          , [0 1]               , ...
            'xtick'         , 0:0.2:1             , ...
            'ylim'          , [0 1]               , ...
            'ytick'         , 0:0.2:1             , ...
            'box'           , 'off'               , ...
            'tickdir'       , 'out'               , ...
            'layer'         , 'top'               , ...
            'ticklength'    , [0.01 0]            , ...
            'fontsize'      , fontSize            );
         axis square;
         
         xlabel('Proportion Optimal Rule', 'fontsize', fontSize + 2);
         ylabel('Proportion Maximum Value', 'fontsize', fontSize + 2);
         
         % fake legend
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', colors{1}, 'markersize', 8);
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', colors{2}, 'markersize', 8);
         legend('female environment', 'male environment', ...
            'location' , 'northwest' , ...
            'box'      , 'off'       , ...
            'fontsize' , fontSize    );
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, d.nEnvironments);
         propMax = nan(d.nSubjects, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               propOpt(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.optChoice(:, envIdx)')/d.nProblems;
               propMax(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.maxChoice(:, envIdx)')/d.nProblems;
               
               
            end
         end
         
         for envIdx = 1:d.nEnvironments
            count = hist3([propOpt(:, envIdx) propMax(:, envIdx)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , colors{envIdx}  , ...
                        'edgecolor' , 'w'           , ...
                        'curvature' , [1 1]);
                  end
               end
            end
         end
         
         Raxes(gca, 0.02, 0.015);
         
      case 'BeforeAfterChosen'
         
         % constants
         step = 2.5; scaleWR = 10*1.5/5; scaleHR = 80*1.5/5; eps = 0.0; scaleWL = 10*1.5; scaleHL = 80*1.5;
         fontSize = 18;
         
         % derived constants
         binsC = step/2:step:(100-step/2);
         binsE = 0:step:100;
         
         % figure
         F = figure(2); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.1 0.2 0.8 0.5] , ...
            'paperpositionmode' , 'auto'            );
         
         % find values before and after chosen in each position and each environment
         chosenCount = zeros(length(binsC), d.nPositions, d.nEnvironments);
         notChosenCount = zeros(length(binsC), d.nPositions, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               for probIdx = 1:d.nProblems
                  if d.decision(subjIdx, probIdx, envIdx) > 1
                     tmpChosenCount = histc(d.values(probIdx, d.decision(subjIdx, probIdx, envIdx)-1, envIdx), binsE);
                     tmpChosenCount = tmpChosenCount(1:end-1)';
                     chosenCount(:, d.decision(subjIdx, probIdx, envIdx), envIdx) = chosenCount(:, d.decision(subjIdx, probIdx, envIdx), envIdx) + tmpChosenCount;
                  end
                  if d.decision(subjIdx, probIdx, envIdx) > 2
                     for trialIdx = 1:(d.decision(subjIdx, probIdx, envIdx) - 2)
                        tmpNotChosenCount = histc(d.values(probIdx, trialIdx, envIdx), binsE);
                        tmpNotChosenCount = tmpNotChosenCount(1:end-1)';
                        notChosenCount(:, trialIdx+1, envIdx) = notChosenCount(:, trialIdx+1, envIdx) + tmpNotChosenCount;
                     end
                  end
               end
            end
         end
         
         for envIdx = 1:d.nEnvironments
            chosenCount(:, :, envIdx) = chosenCount(:, :, envIdx)/sum(sum(chosenCount(:, :, envIdx)));
            notChosenCount(:, :, envIdx) =  notChosenCount(:, :, envIdx)/sum(sum(notChosenCount(:, :, envIdx)));
         end
         
         % plot in each panel
         for envIdx = 1:d.nEnvironments
            subplot(1, d.nEnvironments, envIdx); cla; hold on;
            set(gca, ...
               'xlim'          , [0 d.nPositions+1]   , ...
               'xtick'         , 1:d.nPositions       , ...
               'xticklabel'    , xLabels              , ...
               'ylim'          , [0 100]              , ...
               'ytick'         , 0:10:100             , ...
               'box'           , 'off'                , ...
               'tickdir'       , 'out'                , ...
               'layer'         , 'top'                , ...
               'ticklength'    , [0.01 0]             , ...
               'fontsize'      , fontSize             );
            xlabel(xlabels{envIdx}, 'fontsize', fontSize+2);
            ylabel('Value', 'fontsize', fontSize+2);
            % title(sprintf('%s environment', d.environmentNames{envIdx}), 'fontweight', 'normal', 'fontsize', fontSize+2);
            
            % fake legend
            if envIdx == d.nEnvironments
               plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', pantone.ClassicBlue);
               plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', pantone.GlacierGray);
               legend('before chosen', 'before not chosen', ...
                  'box'      , 'off'     , ...
                  'fontsize' , fontSize  );
            end
            
            % plot
            for trialIdx = 1:d.nPositions
               for binIdx = 1:length(binsC)
                  tmpVal = chosenCount(binIdx, trialIdx, envIdx);
                  if tmpVal > 0
                     width = scaleWR*sqrt(tmpVal);
                     height = scaleHR*sqrt(tmpVal);
                     rectangle('position', [trialIdx+eps, binsC(binIdx) - height/2, width, height], ...
                        'facecolor' , colors{envIdx} , ...
                        'edgecolor' , 'w'            , ...
                        'curvature' , [1 1]          );
                     
                  end
                  tmpVal = notChosenCount(binIdx, trialIdx, envIdx);
                  if tmpVal > 0
                     width = scaleWL*tmpVal;
                     height = scaleHL*tmpVal;
                     rectangle('position', [trialIdx-eps-width, binsC(binIdx) - height/2, width, height], ...
                        'facecolor' , pantone.GlacierGray  , ...
                        'edgecolor' , 'w'                  , ...
                        'curvature' , [1 1]);
                  end
               end
            end
         end
         
      case 'ChosenInPosition'
         
         % constants
         step = 2.5; scaleW = 10*1.5/5; scaleH = 80*1.5/5;
         fontSize = 18;
         
         % derived constants
         binsC = step/2:step:(100-step/2);
         binsE = 0:step:100;
         
         % figure
         F = figure(3); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.1 0.2 0.8 0.5] , ...
            'paperpositionmode' , 'auto'            );
         
         % find values chosen in each position and each environment
         chosenCount = zeros(length(binsC), d.nPositions, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               for probIdx = 1:d.nProblems
                  if d.decision(subjIdx, probIdx, envIdx) > 0
                     tmpChosenCount = histc(d.values(probIdx, d.decision(subjIdx, probIdx, envIdx), envIdx), binsE);
                     tmpChosenCount = tmpChosenCount(1:end-1)';
                     chosenCount(:, d.decision(subjIdx, probIdx, envIdx), envIdx) = chosenCount(:, d.decision(subjIdx, probIdx, envIdx), envIdx) + tmpChosenCount;
                  end
               end
            end
         end
         
         for envIdx = 1:d.nEnvironments
            chosenCount(:, :, envIdx) = chosenCount(:, :, envIdx)/sum(sum(chosenCount(:, :, envIdx)));
         end
         
         % plot in each panel
         for envIdx = 1:d.nEnvironments
            subplot(1, d.nEnvironments, envIdx); cla; hold on;
            set(gca, ...
               'xlim'          , [0 d.nPositions+1]    , ...
               'xtick'         , 1:d.nPositions        , ...
               'xticklabel'    , xLabels               , ...
               'ylim'          , [0 105]               , ...
               'ytick'         , 0:10:100              , ...
               'box'           , 'off'                 , ...
               'tickdir'       , 'out'                 , ...
               'layer'         , 'top'                 , ...
               'ticklength'    , [0.01 0]              , ...
               'fontsize'      , fontSize              );
            xlabel(xlabels{envIdx}, 'fontsize', fontSize+2);
            ylabel('Value', 'fontsize', fontSize+2);
            
            % plot
            for trialIdx = 1:d.nPositions
               for binIdx = 1:length(binsC)
                  tmpVal = chosenCount(binIdx, trialIdx, envIdx);
                  if tmpVal > 0
                     width = scaleW*sqrt(tmpVal);
                     height = scaleH*sqrt(tmpVal);
                     rectangle('position', [trialIdx-width/2, binsC(binIdx)-height/2, width, height], ...
                        'facecolor' , colors{envIdx} , ...
                        'edgecolor' , 'w'            , ...
                        'curvature' , [1 1]          );
                  end
                  
               end
            end
            
            plot(1:d.nPositions,  d.optimalThresholds{envIdx}, 'k-', ...
               'linewidth', 2);
            
         end
         
      case 'Learning'
         
         % constants
         step = 5;
         eps = 0.25;
         fontSize = 18;
         
         % derived constants
         binsC = step/2:step:(d.nProblems-step/2);
         binsE = 0:step:d.nProblems;
         
         % figure and axes
         F = figure(5); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.6 0.4] , ...
            'paperpositionmode' , 'auto'            );
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, length(binsC), d.nEnvironments);
         propMax = nan(d.nSubjects, length(binsC), d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               for probIdx = 1:length(binsC)
                  probs = d.order(subjIdx, (binsE(probIdx)+1):binsE(probIdx+1), envIdx);
                  propOpt(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.optChoice(probs, envIdx)')/length(probs);
                  propMax(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.maxChoice(probs, envIdx)')/length(probs);
               end
            end
         end
         
         %   plot
         for envIdx = 1:d.nEnvironments
            subplot(1, d.nEnvironments, envIdx); cla; hold on;
            set(gca, ...
               'xlim'          , [0 d.nProblems]   , ...
               'xtick'         , [1 10:10:50]      , ...
               'ylim'          , [0 1]             , ...
               'ytick'         , 0:0.2:1           , ...
               'box'           , 'off'             , ...
               'tickdir'       , 'out'             , ...
               'layer'         , 'top'             , ...
               'ticklength'    , [0.01 0]          , ...
               'fontsize'      , fontSize          );
            
            xlabel('Problem', 'fontsize', fontSize + 2);
            ylabel('Proportion', 'fontsize', fontSize + 2);
            title(sprintf('%s environment', d.environmentNames{envIdx}), 'fontweight', 'normal', 'fontsize', fontSize+2);
            
            % fake legend
            plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', colors{envIdx});
            plot([-100 -100],[0 1], '--', 'linewidth', 2, 'color', colors{envIdx});
            legend('optimal', 'maximum', ...
               'autoupdate', 'off', ...
               'box'      , 'off'     , ...
               'fontsize' , fontSize  );
            
            % plot errorbars
            errorbar(binsC-eps, mean(propOpt(:, :, envIdx)), std(propOpt(:, :, envIdx))/sqrt(d.nSubjects), ...
               'color', colors{envIdx}, 'linewidth', 1);
            errorbar(binsC+eps, mean(propMax(:, :, envIdx)), std(propMax(:, :, envIdx))/sqrt(d.nSubjects), '--', ...
               'color', colors{envIdx}, 'linewidth', 1);
            
            % plot circular mean markers
            plot(binsC-eps, mean(propOpt(:, :, envIdx)), 'o', ...
               'markeredgecolor', colors{envIdx}, ...
               'markerfacecolor', 'w');
            plot(binsC+eps, mean(propMax(:, :, envIdx)), 'o', ...
               'markeredgecolor', colors{envIdx}, ...
               'markerfacecolor', 'w');
            
         end
         
      case 'IndividualByEnvironment'
         
         % constants
         step = .025; scale = 0.25;
         fontSize = 15;
         
         % derived constants
         binsC = step/2:step:(1-step/2);
         binsE = 0:step:1;
         edges{1} = binsE;
         edges{2} = binsE;
         
         % figure and axes
         F = figure(6); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.4 0.6] , ...
            'paperpositionmode' , 'auto'            );
         
         set(gca, ...
            'units'         , 'normalized'        , ...
            'position'      , [0.15 0.15 0.7 0.7] , ...
            'xlim'          , [0 1]               , ...
            'xtick'         , 0:0.2:1             , ...
            'ylim'          , [0 1]               , ...
            'ytick'         , 0:0.2:1             , ...
            'box'           , 'off'               , ...
            'tickdir'       , 'out'               , ...
            'layer'         , 'top'               , ...
            'ticklength'    , [0.01 0]            , ...
            'fontsize'      , fontSize            );
         axis square;
         
         xlabel('Female Environment', 'fontsize', fontSize + 2);
         ylabel('Male Environment', 'fontsize', fontSize + 2);
         
         % fake legend
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', pantone.Treetop, 'markersize', 8);
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', pantone.Custard, 'markersize', 8);
         legend('optimal rule', 'maximum value', ...
            'location' , 'northwest' , ...
            'box'      , 'off'       , ...
            'fontsize' , fontSize    );
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, d.nEnvironments);
         propMax = nan(d.nSubjects, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               propOpt(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.optChoice(:, envIdx)')/d.nProblems;
               propMax(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.maxChoice(:, envIdx)')/d.nProblems;
            end
         end
         
         %   count = histogram2(propOpt*100,propMax*100, binsE, binsE);
         for envIdx = 1:d.nEnvironments
            
            % max
            count = hist3([propMax(:, 1) propMax(:, 2)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , pantone.Custard  , ...
                        'edgecolor' , 'w'           , ...
                        'curvature' , [1 1]);
                  end
               end
            end
            
            % optimal rule
            count = hist3([propOpt(:, 1) propOpt(:, 2)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , pantone.Treetop  , ...
                        'edgecolor' , 'w'           , ...
                        'curvature' , [1 1]);
                  end
               end
            end
            
         end
         
         Raxes(gca, 0.02, 0.015);
         
      case 'ConsolidatedResults'      % optimality and learning in two-panel figure
         
         % figure
         F = figure(5); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.6 0.6] , ...
            'paperpositionmode' , 'auto'            );
         
         % optimality
         
         % constants
         step = .025; scale = 0.25;
         fontSize = 18;
         
         % derived constants
         binsC = step/2:step:(1-step/2);
         binsE = 0:step:1;
         edges{1} = binsE;
         edges{2} = binsE;
         
         % figure
         subplot(1, 2, 1); cla; hold on;
         set(gca, ...
            'xlim'          , [0 1]           , ...
            'xtick'         , 0:0.2:1         , ...
            'ylim'          , [0 1]           , ...
            'ytick'         , 0:0.2:1         , ...
            'box'           , 'off'           , ...
            'tickdir'       , 'out'           , ...
            'layer'         , 'top'           , ...
            'ticklength'    , [0.01 0]        , ...
            'fontsize'      , fontSize        );
         axis square;
         
         xlabel('Proportion Optimal Rule', 'fontsize', fontSize + 2);
         ylabel('Proportion Maximum Value', 'fontsize', fontSize + 2);
         
         % fake legend
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', colors{1}, 'markersize', 8);
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', colors{2}, 'markersize', 8);
         legend('female environment', 'male environment', ...
            'location' , 'northwest' , ...
            'box'      , 'off'       , ...
            'fontsize' , fontSize    );
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, d.nEnvironments);
         propMax = nan(d.nSubjects, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               propOpt(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.optChoice(:, envIdx)')/d.nProblems;
               propMax(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.maxChoice(:, envIdx)')/d.nProblems;
            end
         end
         
         for envIdx = 1:d.nEnvironments
            count = hist3([propOpt(:, envIdx) propMax(:, envIdx)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , colors{envIdx}  , ...
                        'edgecolor' , 'w'           , ...
                        'curvature' , [1 1]);
                  end
               end
            end
         end
         
         % learning
         
         % constants
         step = 5;
         eps = 0.25;
         
         % derived constants
         binsC = step/2:step:(d.nProblems-step/2);
         binsE = 0:step:d.nProblems;
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, length(binsC), d.nEnvironments);
         propMax = nan(d.nSubjects, length(binsC), d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               for probIdx = 1:length(binsC)
                  probs = d.order(subjIdx, (binsE(probIdx)+1):binsE(probIdx+1), envIdx);
                  propOpt(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.optChoice(probs, envIdx)')/length(probs);
                  propMax(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.maxChoice(probs, envIdx)')/length(probs);
               end
            end
         end
         
         %   plot
         subplot(1, 2, 2); cla; hold on;
         set(gca, ...
            'xlim'          , [0 d.nProblems]   , ...
            'xtick'         , [1 10:10:50]      , ...
            'ylim'          , [0 1]             , ...
            'ytick'         , 0:0.2:1           , ...
            'box'           , 'off'             , ...
            'tickdir'       , 'out'             , ...
            'layer'         , 'top'             , ...
            'ticklength'    , [0.01 0]          , ...
            'fontsize'      , fontSize          );
         xlabel('Problem', 'fontsize', fontSize + 2);
         ylabel('Proportion Correct', 'fontsize', fontSize + 2);
         axis square;
         
         % fake legend
         plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', colors{1});
         plot([-100 -100],[0 1], '--', 'linewidth', 2, 'color', colors{1});
         plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', colors{2});
         plot([-100 -100],[0 1], '--', 'linewidth', 2, 'color', colors{2});
         legend('female optimal', 'female maximum', 'male optimal', 'male maximum', ...
            'autoupdate' , 'off'     , ...
            'box'        , 'off'     , ...
            'fontsize'   , fontSize  );         
         
         for envIdx = 1:d.nEnvironments
            
            % plot errorbars
            errorbar(binsC-eps, mean(propOpt(:, :, envIdx)), std(propOpt(:, :, envIdx))/sqrt(d.nSubjects), ...
               'color', colors{envIdx}, 'linewidth', 1.5);
            errorbar(binsC+eps, mean(propMax(:, :, envIdx)), std(propMax(:, :, envIdx))/sqrt(d.nSubjects), '--', ...
               'color', colors{envIdx}, 'linewidth', 1.5);
            
            % plot circular mean markers
            plot(binsC-eps, mean(propOpt(:, :, envIdx)), 'o', ...
               'markeredgecolor' , colors{envIdx} , ...
               'markerfacecolor' , 'w'            );
            plot(binsC+eps, mean(propMax(:, :, envIdx)), 'o', ...
               'markeredgecolor' , colors{envIdx} , ...
               'markerfacecolor' , 'w'            );
            
         end
         
      case 'ConsolidatedResults2'      % optimality (showing within-individual consistency) and learning in two-panel figure
         
         % figure
         F = figure(6); clf; hold on;
         set(F, ...
            'color'             , 'w'               , ...
            'units'             , 'normalized'      , ...
            'position'          , [0.2 0.2 0.6 0.6] , ...
            'paperpositionmode' , 'auto'            );
         
         % optimality
         
         % constants
         step = .025; scale = 0.25;
         fontSize = 15;
         
         % derived constants
         binsC = step/2:step:(1-step/2);
         binsE = 0:step:1;
         edges{1} = binsE;
         edges{2} = binsE;
         
         % subplot
         subplot(1, 2, 1); cla; hold on;
         set(gca, ...
            'xlim'          , [0 1]           , ...
            'xtick'         , 0:0.2:1         , ...
            'ylim'          , [0 1]           , ...
            'ytick'         , 0:0.2:1         , ...
            'box'           , 'off'           , ...
            'tickdir'       , 'out'           , ...
            'layer'         , 'top'           , ...
            'ticklength'    , [0.01 0]        , ...
            'fontsize'      , fontSize        );
         axis square;
         
         xlabel('Female Environment', 'fontsize', fontSize + 2);
         ylabel('Male Environment', 'fontsize', fontSize + 2);
         
         % fake legend
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', pantone.ClassicBlue, 'markersize', 8);
         plot([-100],[0], 'o', 'markeredgecolor', 'w', 'markerfacecolor', pantone.Titanium, 'markersize', 8);
         legend('optimal rule', 'maximum value', ...
            'location' , 'northwest' , ...
            'box'      , 'off'       , ...
            'fontsize' , fontSize    );
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, d.nEnvironments);
         propMax = nan(d.nSubjects, d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               propOpt(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.optChoice(:, envIdx)')/d.nProblems;
               propMax(subjIdx, envIdx) = sum(d.decision(subjIdx, :, envIdx) == d.maxChoice(:, envIdx)')/d.nProblems;
            end
         end
         
         %   count = histogram2(propOpt*100,propMax*100, binsE, binsE);
         for envIdx = 1:d.nEnvironments
            
            % max
            count = hist3([propMax(:, 1) propMax(:, 2)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , pantone.Titanium  , ...
                        'edgecolor' , 'w'               , ...
                        'curvature' , [1 1]             );
                  end
               end
            end
            
            % optimal rule
            count = hist3([propOpt(:, 1) propOpt(:, 2)], 'edges', edges);
            count = count(1:end-1, 1:end-1);
            count = count/sum(count(:));
            
            % plot
            for idx1 = 1:length(binsC)
               for idx2 = 1:length(binsC)
                  if count(idx1, idx2) > 0
                     hw = scale*sqrt(count(idx1, idx2));
                     rectangle('position', [binsC(idx1)-hw/2, binsC(idx2)-hw/2, hw, hw], ...
                        'facecolor' , pantone.ClassicBlue  , ...
                        'edgecolor' , 'w'                  , ...
                        'curvature' , [1 1]                );
                  end
               end
            end
            
         end
         
         % learning
         
         % constants
         step = 5;
         eps = 0.25;
         
         % derived constants
         binsC = step/2:step:(d.nProblems-step/2);
         binsE = 0:step:d.nProblems;
         
         % proportions of process and outcome for each person on each environment
         propOpt = nan(d.nSubjects, length(binsC), d.nEnvironments);
         propMax = nan(d.nSubjects, length(binsC), d.nEnvironments);
         for envIdx = 1:d.nEnvironments
            for subjIdx = 1:d.nSubjects
               for probIdx = 1:length(binsC)
                  probs = d.order(subjIdx, (binsE(probIdx)+1):binsE(probIdx+1), envIdx);
                  propOpt(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.optChoice(probs, envIdx)')/length(probs);
                  propMax(subjIdx, probIdx, envIdx) = sum(d.decision(subjIdx, probs, envIdx) == d.maxChoice(probs, envIdx)')/length(probs);
               end
            end
         end
         
         %   plot
         subplot(1, 2, 2); cla; hold on;
         set(gca, ...
            'xlim'          , [0 d.nProblems]   , ...
            'xtick'         , [1 10:10:50]      , ...
            'ylim'          , [0 1]             , ...
            'ytick'         , 0:0.2:1           , ...
            'box'           , 'off'             , ...
            'tickdir'       , 'out'             , ...
            'layer'         , 'top'             , ...
            'ticklength'    , [0.01 0]          , ...
            'fontsize'      , fontSize          );
         xlabel('Problem', 'fontsize', fontSize + 2);
         ylabel('Proportion Correct', 'fontsize', fontSize + 2);
         axis square;
         
         % fake legend
         plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', colors{1});
         plot([-100 -100],[0 1], '--', 'linewidth', 2, 'color', colors{1});
         plot([-100 -100],[0 1], '-', 'linewidth', 2, 'color', colors{2});
         plot([-100 -100],[0 1], '--', 'linewidth', 2, 'color', colors{2});
         legend('female optimal', 'female maximum', 'male optimal', 'male maximum', ...
            'autoupdate' , 'off'     , ...
            'box'        , 'off'     , ...
            'fontsize'   , fontSize  );         
         
         for envIdx = 1:d.nEnvironments
            
            % plot errorbars
            errorbar(binsC-eps, mean(propOpt(:, :, envIdx)), std(propOpt(:, :, envIdx))/sqrt(d.nSubjects), ...
               'color', colors{envIdx}, 'linewidth', 1.5);
            errorbar(binsC+eps, mean(propMax(:, :, envIdx)), std(propMax(:, :, envIdx))/sqrt(d.nSubjects), '--', ...
               'color', colors{envIdx}, 'linewidth', 1.5);
            
            % plot circular mean markers
            plot(binsC-eps, mean(propOpt(:, :, envIdx)), 'o', ...
               'markeredgecolor', colors{envIdx}, ...
               'markerfacecolor', 'w');
            plot(binsC+eps, mean(propMax(:, :, envIdx)), 'o', ...
               'markeredgecolor', colors{envIdx}, ...
               'markerfacecolor', 'w');
            
         end
         
   end
   
   % print
   if doPrint
      print(sprintf('figures/%s.png', analysis), '-dpng', '-r300');
      print(sprintf('figures/%s.eps', analysis), '-depsc');
   end
   
end
