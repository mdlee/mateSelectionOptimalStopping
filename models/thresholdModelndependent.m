%% independent-threshold model

clear; close all;

%% User input
% all participants using drawIndividuals = true
dataName = 'mateChoice2019'; subjectList = 1:55;
% a subset of select participants using drawSelectIndividuals = true
% dataName = 'mateChoice2019'; subjectList = [1 8 44]; nRows = 2; nCols = 3; % for draw select individuals option
drawSelectIndividuals = false;
drawGroup = true;
doPrint = false;
drawIndividuals = false;

fontSize = 20;
eps = 1; scale = 5; shift = 0.2; threshold = 0.0;
credibleInterval = [2.5 97.5];
rangeLim = 50;

%% Constants
try load pantoneSpring2015; catch load PantoneSpring2015; end
modelName = 'thresholdIndependent';
engine = 'jags';
colorsLight{1} = pantone.Tangerine;
colorsLight{2} = pantone.DuskBlue;
colorsHeavy{1} = pantone.Marsala;
colorsHeavy{2} = pantone.ClassicBlue;
xlabels{1} = 'Female Age';
xlabels{2} = 'Male Age';

%% Derived constants
nSubjects = length(subjectList);
binsE = 0:eps:100;
binsC = eps/2:eps:100-eps/2;

%% Data
switch dataName
    case   'mateChoice2019'
        load ../data/MateChoiceApril1st d
end

%% Graphical model setup

% parameters to monitor
params = {'predy', 'tau', 'alpha', 'z', 'gamma'};

% MCMC properties
nChains    = 6;   % number of MCMC chains
nBurnin    = 5e3;   % number of discarded burn-in samples
nSamples   = 2e3;   % number of collected samples
nThin      = 10;   % number of samples between those collected
doParallel = 1;   % whether MATLAB parallel toolbox parallizes chains

% nChains    = 5;   % number of MCMC chains
% nBurnin    = 5e3;   % number of discarded burn-in samples
% nSamples   = 2e3;   % number of collected samples
% nThin      = 1;   % number of samples between those collected
% doParallel = 1;   % whether MATLAB parallel toolbox parallizes chains
%
% nChains    = 4;   % number of MCMC chains
% nBurnin    = 0;   % number of discarded burn-in samples
% nSamples   = 1e2;   % number of collected samples
% nThin      = 1;   % number of samples between those collected
% doParallel = 0;   % whether MATLAB parallel toolbox parallizes chains

if drawGroup
    % figure and axes
    F = figure(100); clf; hold on;
    set(F, ...
        'renderer'          , 'painters'        , ...
        'color'             , 'w'               , ...
        'units'             , 'normalized'      , ...
        'position'          , [0.1 0.2 0.8 0.55] , ...
        'paperpositionmode' , 'auto'            );
    
    % constants
    whiskers = 0.1;
    offset = 0.01;
    mn = length(subjectList)/2;
    
end

if drawSelectIndividuals
    
    % figure and axes
    F = figure(200); clf; hold on;
    set(F, ...
        'renderer'          , 'painters'        , ...
        'color'             , 'w'               , ...
        'units'             , 'normalized'      , ...
        'position'          , [0.1 0.2 0.8 0.65] , ...
        'paperpositionmode' , 'auto'            );
    
    if nRows == 1
        set(F, 'position', [0.1 0.2 0.8 0.5]);
    end
    
    for idx = 1:length(subjectList)*2
        
        subplot(nRows, nCols, idx); hold on;
        
        set(gca, ...
            'xlim'               , [0 d.nPositions+1]  , ...
            'xtick'              , 1:d.nPositions      , ...
            'xticklabel'         , num2cell(d.ages)    , ...
            'xticklabelrotation' , 90                  , ...
            'ylim'               , [0 100]             , ...
            'ytick'              , 0:20:100            , ...
            'box'                , 'off'               , ...
            'tickdir'            , 'out'               , ...
            'layer'              , 'top'               , ...
            'ticklength'         , [0.01 0]            , ...
            'fontsize'           ,  fontSize-2           );
        
    end
end

% storage
predy = nan(length(subjectList), d.nProblems, d.nEnvironments);

for environment = 1:d.nEnvironments
    
    % generator for initialization
    generator = @()struct('alpha', rand(1, length(subjectList))*0.3 + 0.6);
    
    % input for graphical model
    data = struct(...
        'nSubjects'   , nSubjects                               , ...
        'nPositions'  , d.nPositions                            , ...
        'nProblems'   , d.nProblems                             , ...
        'y'           , d.decision(subjectList, :, environment) , ...
        'v'           , d.values(:, :, environment)             );
    
    if exist(['storage/' modelName '_' dataName '_env' int2str(environment) '.mat'], 'file')
        load(['storage/' modelName '_' dataName '_env' int2str(environment)], 'stats', 'chains', 'diagnostics', 'info');
    else
        tic; % start clock
        [stats, chains, diagnostics, info] = callbayes(engine, ...
            'model'           ,  [modelName '.txt']                        , ...
            'data'            ,  data                                      , ...
            'outputname'      ,  'samples'                                 , ...
            'init'            ,  generator                                 , ...
            'datafilename'    ,  modelName                                 , ...
            'initfilename'    ,  modelName                                 , ...
            'scriptfilename'  ,  modelName                                 , ...
            'logfilename'     ,  modelName                                 , ...
            'nchains'         ,  nChains                                   , ...
            'nburnin'         ,  nBurnin                                   , ...
            'nsamples'        ,  nSamples                                  , ...
            'monitorparams'   ,  params                                    , ...
            'thin'            ,  nThin                                     , ...
            'workingdir'      ,  ['tmp/' modelName]                        , ...
            'verbosity'       ,  0                                         , ...
            'saveoutput'      ,  true                                      , ...
            'allowunderscores',  1                                         , ...
            'parallel'        ,  doParallel                                , ...
            'modules'         ,  {'wfComboPack', 'dic'}                    );
        fprintf('%s took %f seconds!\n', upper(engine), toc); % show timing
        save(['storage/' modelName '_' dataName '_env' int2str(environment)], 'stats', 'chains', 'diagnostics', 'info');
    end
    
    %% Inspect the results
    % First, inspect the convergence of each parameter
    disp('Convergence statistics:')
    grtable(chains, 1.05)
    
    % for the plotted variables, find the subset of chains with acceptable MCMC convergence
    [keepDevianceChains, devianceRhat] = findKeepChains(chains.deviance, 2, 1.1);
    
    tau = nan(d.nSubjects, d.nPositions, 3); % 1 = mean, 2 = lower CI, 3 = higher CI
    for i = 1:length(subjectList)
        for j = 1:d.nPositions
            x = reshape(chains.(sprintf('tau_%d_%d', subjectList(i), j))(:, keepDevianceChains), 1, []);
            tau(i, j, 1) = mean(x);
            tmp = prctile(x, credibleInterval);
            tau(i, j, 2) = max(0, min(100, tmp(1)));
            tau(i, j, 3) = max(0, min(100, tmp(2)));
        end
    end
    
    
    alpha = nan(d.nSubjects, 3);
    for idx = 1:length(subjectList)
        keepChains = findKeepChains(chains.(sprintf('alpha_%d', subjectList(idx))), 2, 1.1);
        x = reshape(chains.(sprintf('alpha_%d', subjectList(idx)))(:, keepChains), 1, []);
        alpha(idx, 1) = mean(x);
        tmp = prctile(x, credibleInterval);
        alpha(idx, 2) = max(0, min(100, tmp(1)));
        alpha(idx, 3) = max(0, min(100, tmp(2)));
    end
    
    if length(subjectList) > 1
       predy(:, :, environment) = get_matrix_from_coda(chains, 'predy', @mean);
    end
    gamma = codatable(chains, 'gamma', @mean);
    z = codatable(chains, 'z', @mean);
    zMode = codatable(chains, 'z', @mode);
    
    
    fprintf('Average posterior predictive agreement = %1.2f\n', mean(mean(predy(:, :, environment))));
    fprintf('Total of %d contaminants\n', sum(zMode==2));
    
    
    if drawGroup
        
        subplot(1, 2, environment); hold on;
        
        set(gca, ...
            'xlim'          , [0 d.nPositions+1]     , ...
            'xtick'         , 1:d.nPositions         , ...
            'xticklabel'    , num2cell(d.ages)       , ...
            'ylim'          , [0 100]                , ...
            'ytick'         , 0:20:100               , ...
            'box'           , 'off'               , ...
            'tickdir'       , 'out'               , ...
            'layer'         , 'top'               , ...
            'ticklength'    , [0.01 0]           , ...
            'fontsize'      ,  fontSize           );
        
        for i = 1:length(subjectList)
            if z(i) == 0
                tmpMean = nan(d.nPositions, 1);
                for j = 1:d.nPositions
                    x = reshape(chains.(sprintf('tau_%d_%d', subjectList(i), j)), 1, []);
                    if range(x) < rangeLim
                        tmpMean(j) = mean(x);
                    end
                    plot((1:d.nPositions)-offset*(i-mn), tmpMean, '-', ...
                        'color', colorsLight{environment});
                end
            end
        end
        
        for i = 1:length(subjectList)
            if z(i) == 0
                tmpMean = nan(d.nPositions, 1);
                for j = 1:d.nPositions
                    x = reshape(chains.(sprintf('tau_%d_%d', subjectList(i), j)), 1, []);
                    if range(x) < rangeLim
                        tmpMean(j) = mean(x);
                    end
                    plot((1:d.nPositions)-offset*(i-mn), tmpMean, 'o', ...
                        'markeredgecolor', 'none', ...
                        'markerfacecolor', colorsHeavy{environment}, ...
                        'markersize', 3);
                end
            end
        end
        
        plot(1:d.nPositions,  d.optimalThresholds{environment}, 'k-', ...
            'linewidth', 2);
        
        xlabel(sprintf('%s Age', regexprep(d.environmentNames{environment},'(\<[a-z])','${upper($1)}')), ...
            'fontsize', fontSize+2);
        
        if environment == 1
            ylabel('Value', 'fontsize', fontSize+2);
        end
        
    end
    
    if drawIndividuals
        for i = 1:length(subjectList)
            
            % figure and axes
            F = figure(i); clf; hold on;
            set(F, ...
                'renderer'          , 'painters'        , ...
                'color'             , 'w'               , ...
                'units'             , 'normalized'      , ...
                'position'          , [0.2 0.2 0.5 0.7] , ...
                'paperpositionmode' , 'auto'            );
            
            set(gca, ...
                'xlim'          , [0 d.nPositions+1]     , ...
                'xtick'         , 1:d.nPositions         , ...
                'xticklabel'    , num2cell(d.ages)       , ...
                'ylim'          , [0 100]                , ...
                'ytick'         , 0:20:100               , ...
                'box'           , 'off'               , ...
                'tickdir'       , 'out'               , ...
                'layer'         , 'top'               , ...
                'ticklength'    , [0.01 0]           , ...
                'fontsize'      ,  fontSize           );
            xlabel(xlabels{environment}, 'fontsize', fontSize + 2);
            ylabel('Value', 'fontsize', fontSize + 2);
            
            for k = 1:d.nPositions
                eval(sprintf('count = histc(chains.tau_%d_%d(:), binsE);', i, k));
                count = count(1:end-1);
                count = count/sum(count);
                for idx = 1:length(binsC)
                    if count(idx) > threshold
                        rectangle('position', [k-scale*count(idx) binsC(idx)-eps/2 2*scale*count(idx) eps], ...
                            'curvature' , [0 0]            , ...
                            'edgecolor' , colorsLight{environment} , ...
                            'facecolor' , colorsLight{environment} );
                    end
                end
            end
            
            for j = 1:d.nProblems
                for k = 1:d.decision(i, j, environment)
                    if ~isnan(k)
                        if d.decision(i, j, environment) == k
                            plot(k, d.values(j, k, environment), 'o', ...
                                'markerfacecolor', 'none' , ...
                                'markeredgecolor', 'k'    , ...
                                'linewidth'      , 0.5    , ...
                                'markersize'     , 8      );
                        else
                            plot(k, d.values(j, k, environment), '+', ...
                                'color' , pantone.Titanium , ...
                                'markersize'      , 8                );
                        end
                    end
                end
            end
            
            % Print
            if doPrint
                print(sprintf('figures/%s_env%d_subject%d.png', modelName, environment, subjectList(i)), '-dpng');
                print(sprintf('figures/%s_env%d_subject%d.eps', modelName, environment, subjectList(i)), '-depsc');
            end
            
        end
        
    end
    
    if drawSelectIndividuals
        
        figure(200);
        
        
        for i = 1:length(subjectList)
            
            subplot(nRows, nCols, (environment-1)*length(subjectList) + i); hold on;
            
            for k = 1:d.nPositions
                
                eval(sprintf('count = histc(chains.tau_%d_%d(:, keepDevianceChains), binsE);', subjectList(i), k));
                count = count(1:end-1);
                count = count/sum(count);
                for idx = 1:length(binsC)
                    if count(idx) > threshold
                        rectangle('position', [k-scale*count(idx) binsC(idx)-eps/2 2*scale*count(idx) eps], ...
                            'curvature' , [0 0]            , ...
                            'edgecolor' , colorsLight{environment} , ...
                            'facecolor' , colorsLight{environment} );
                    end
                end
            end
            
            for j = 1:d.nProblems
                for k = 1:d.decision(subjectList(i), j, environment)
                    if ~isnan(k)
                        if d.decision(subjectList(i), j, environment) == k
                            plot(k, d.values(j, k, environment), 'o', ...
                                'markerfacecolor', 'k' , ...
                                'markeredgecolor', 'w'    , ...
                                'linewidth'      , 0.5    , ...
                                'markersize'     , 6      );
                        else
                            plot(k, d.values(j, k, environment), '+', ...
                                'color' , pantone.Titanium , ...
                                'markersize'      , 3                );
                        end
                    end
                end
            end
        end
    end
end

if drawSelectIndividuals
    figure(200); hold on;
    
    subplot(nRows, nCols, nRows*nCols);
    xlabel('Male Age', 'fontsize', fontSize+2);
    subplot(nRows, nCols, nRows*nCols-1);
    xlabel('Female Age', 'fontsize', fontSize+2);
    [~, H] = suplabel('Value', 'y');
    set(H, 'fontsize', fontSize+2);
    set(H, 'vert', 'mid');
    
    if doPrint
        print(sprintf('figures/%s_selectIndividuals.png', modelName), '-dpng');
        print(sprintf('figures/%s_selectIndividuals.eps', modelName), '-depsc');
    end
end


if drawGroup & doPrint
    figure(100);
    print(sprintf('figures/groupThresholds.png'), '-dpng');
    print(sprintf('figures/groupThresholds.eps'), '-depsc');
end

save(sprintf('predySaturated_%s', modelName), 'predy');