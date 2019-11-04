%% Optimal threshold for fixed but non-stationary Gaussian sequence
% v2 characterizes the distribution of optimal stopping trials
%  and allows "representative" stimuli to be chosen on that basis

clear;
close all;

rng(2); % for male
rng(1); % for female

%% User input
environmentName = 'marriageFemale';
nProblems = 50;

% mean then standard deviation of Gaussian that generates values for each trial
switch environmentName
    
    case 'marriageFemale'
        load('../data/MateChoiceApril1st', 'd');
        environment = d.environmentDistributions{1};
        ages = d.ages;
        goal = 'max';
        values = 1:99;
        
    case 'marriageMale'
        load('../data/MateChoiceApril1st', 'd');
        environment = d.environmentDistributions{2};
        ages = d.ages;
        values = 1:99;
        
end

% Constants
nAges = length(ages);

% Optimal thresholds and environment analysis
thresholds = findOptimalThresholds(environment(:, 1), environment(:, 2), values, goal);
resultsGlobal = optimalPlayer(environment(:, 1), environment(:, 2), values, goal, 1e4);
target = hist(resultsGlobal.chosen, 1:nAges);
target = target/sum(target);

thisWillDo = false;

while ~thisWillDo
    
    % Generate problems
    m = nan(nProblems, nAges);
    for problemIdx = 1:nProblems
        for ageIdx = 1:nAges100
            val = max(values(1), min(values(end), round(randn*environment(ageIdx, 2) + environment(ageIdx, 1))));
            m(problemIdx, ageIdx) = val;
            while length(unique(m(problemIdx, 1:ageIdx))) < ageIdx
                val = max(values(1), min(values(end), round(randn*environment(ageIdx, 2) + environment(ageIdx, 1))));
                m(problemIdx, ageIdx) = val;
            end
        end
    end
    
    % Optimal play problems
    resultsLocal = optimalStoppingPlayerGiven(m, thresholds, goal);
    x = hist(resultsLocal.chosen, 1:nAges);
    x = x/sum(x);
    
    
    % see if distribution of optimal choice is close enough
    biggestDifference = max(abs(target - x));
    disp(biggestDifference);
    if biggestDifference < 0.02
        thisWillDo = true;
    end
    
    %   pause
end

% quick and dirty plot
figure(1); clf;
subplot(211); bar(1:nAges, target);
subplot(212); bar(1:nAges, x);

% uncomment to save
% dlmwrite([environmentName '.csv'], m, 'delimiter', ',', 'precision','%d')


