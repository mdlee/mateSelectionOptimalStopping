%% Find optimal parameters for each cognitive strategy in each environment

clear; close all;

% number of problems
nProblems = 1e3;

% grid to search
alphaList = 70:0.5:100;
betaList = 1:14;
deltaList = 0:0.5:30;

%   SETTING FOR THE FULL RUN
%    % number of problems
%    nProblems = 1e4;
%
%    % grid to search
%    alphaList = 70:0.1:100;
%    betaList = 1:14;
%    deltaList = 0:0.1:20;

% load data
load ../data/MateChoiceApril1st d

if ~exist('optimalStrategies.mat', 'file')
    
    for environmentIdx = 1:2
        
        % generate problems (taken from generateStimuli_2)
        % mean then standard deviation of Gaussian that generates values for each trial
        
        switch environmentIdx
            
            case 1 % 'marriageFemale'
                load('../data/MateChoiceApril1st', 'd');
                environment = d.environmentDistributions{1};
                ages = d.ages;
                goal = 'max';
                values = 1:99;
                
            case 2 % 'marriageMale'
                load('../data/MateChoiceApril1st', 'd');
                environment = d.environmentDistributions{2};
                ages = d.ages;
                goal = 'max';
                values = 1:99;
                
        end
        
        % Generate random set of problems
        m = nan(nProblems, d.nPositions);
        for problemIdx = 1:nProblems
            for ageIdx = 1:d.nPositions
                val = max(values(1), min(values(end), round(randn*environment(ageIdx, 2) + environment(ageIdx, 1))));
                m(problemIdx, ageIdx) = val;
                while length(unique(m(problemIdx, 1:ageIdx))) < ageIdx
                    val = max(values(1), min(values(end), round(randn*environment(ageIdx, 2) + environment(ageIdx, 1))));
                    m(problemIdx, ageIdx) = val;
                end
            end
        end
        
        % best outcome
        bestOutcome_F = 0;
        bestOutcome_L = 0;
        bestOutcome_FTL = 0;
        
        for alphaIdx = 1:length(alphaList)
            
            % fixed
            tauHat = [alphaList(alphaIdx) * ones(d.nPositions-1, 1); 0];
            results = optimalStoppingPlayerGiven(m, tauHat, goal);
            outcome = mean(results.correct);
            if outcome > bestOutcome_F
                a_F = alphaList(alphaIdx)
                bestOutcome_F = outcome
                tauStar_F = tauHat;
            end
            
            for deltaIdx = 1:length(deltaList)
                
                % linear
                tauHat = [(alphaList(alphaIdx) - deltaList(deltaIdx)*(1:d.nPositions-1)) 0];
                tauHat = max(0, tauHat);
                results = optimalStoppingPlayerGiven(m, tauHat, goal);
                outcome = mean(results.correct);
                if outcome > bestOutcome_L
                    a_L = [alphaList(alphaIdx) deltaList(deltaIdx)]
                    bestOutcome_L = outcome
                    tauStar_L = tauHat;
                end
                
                for betaIdx = 1:length(betaList)
                    
                    % fixed then linear
                    tauHat = nan(d.nPositions-1, 1);
                    for idx = 1:betaList(betaIdx)
                        tauHat(idx) = alphaList(alphaIdx);
                    end
                    for idx = betaList(betaIdx)+1:14
                        tauHat(idx) = alphaList(alphaIdx) -(idx - betaList(betaIdx))*deltaList(deltaIdx);
                    end
                    tauHat = [tauHat; 0];
                    tauHat = max(0, tauHat);
                    results = optimalStoppingPlayerGiven(m, tauHat, goal);
                    outcome = mean(results.correct);
                    if outcome > bestOutcome_FTL
                        a_FTL = [alphaList(alphaIdx), betaList(betaIdx), deltaList(deltaIdx)]
                        bestOutcome_FTL = outcome
                        tauStar_FTL = tauHat;
                    end
                end
            end
        end
        
        % store optimal parameters
        optimal.f.alpha(environmentIdx) =  a_F(1);
        optimal.l.alpha(environmentIdx) =  a_L(1);
        optimal.l.delta(environmentIdx) = a_L(2);
        optimal.ftl.alpha(environmentIdx) = a_FTL(1);
        optimal.ftl.beta(environmentIdx) = a_FTL(2);
        optimal.ftl.delta(environmentIdx) = a_FTL(3);
        optimal.f.thresholds{environmentIdx} = tauStar_F;
        optimal.l.thresholds{environmentIdx} = tauStar_L;
        optimal.ftl.thresholds{environmentIdx} = tauStar_FTL;
    end
    
    % save
    save optimalStrategies optimal
    
else
    
    % load
    load optimalStrategies optimal
    
end

% simple plot
figure; hold on;
for environmentIdx = 1:d.nEnvironments
    subplot(1, 2, environmentIdx); hold on;
    plot(1:d.nPositions, d.optimalThresholds{environmentIdx}, '-', 'linewidth', 2);
    plot(1:d.nPositions-1, optimal.f.thresholds{environmentIdx}(1:end-1), '-.');
    plot(1:d.nPositions-1, optimal.l.thresholds{environmentIdx}(1:end-1), '--');
    plot(1:d.nPositions-1, optimal.ftl.thresholds{environmentIdx}(1:end-1), '-');
end


