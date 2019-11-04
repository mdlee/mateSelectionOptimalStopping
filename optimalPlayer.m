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

nAges = length(mu);

thresholds = optimalThresholds(mu, sigma, values, goal);

results.chosen = nan(nReps, 1);    % trial where choice made
results.optimal = nan(nReps, 1); % whether choice was maximal
results.value = nan(nReps, 1);   % chosen value

switch goal
   case 'max'
      for idx = 1:nReps
         % generate a problem
         m = zeros(nAges, 1);
         for ageIdx = 1:nAges
            val = max(values(1), min(values(end), round(randn*sigma(ageIdx) + mu(ageIdx))));
            m(ageIdx) = val;
            while length(unique(m(1:ageIdx))) < ageIdx
               val = max(values(1), min(values(end), round(randn*sigma(ageIdx) + mu(ageIdx))));
               m(ageIdx) = val;
            end
         end
         % now optimal play the problem
         maxSoFar = values(1) - 1;
         chosen = 0;
         ageIdx = 0;
         while chosen == 0
            ageIdx = ageIdx + 1;
            if (m(ageIdx) > thresholds(ageIdx)) & (m(ageIdx) > maxSoFar)
               chosen = 1;
            end
            if ageIdx == nAges
               chosen = 1;
            end
            if m(ageIdx) > maxSoFar
               maxSoFar = m(ageIdx);
            end
         end
         results.chosen(idx) = ageIdx;
         results.optimal(idx) = (m(ageIdx) == max(m));
         results.value(idx) = m(ageIdx);
      end
      
   case 'min'
      for idx = 1:nReps
         % generate a problem
         m = zeros(nAges, 1);
         for ageIdx = 1:nAges
            val = max(values(1), min(values(end), round(randn*sigma(ageIdx) + mu(ageIdx))));
            m(ageIdx) = val;
            while length(unique(m(1:ageIdx))) < ageIdx
               val = max(values(1), min(values(end), round(randn*sigma(ageIdx) + mu(ageIdx))));
               m(ageIdx) = val;
            end
         end
         % now optimal play the problem
         minSoFar = values(end) + 1;
         chosen = 0;
         ageIdx = 0;
         while chosen == 0
            ageIdx = ageIdx + 1;
            if (m(ageIdx) < thresholds(ageIdx)) & (m(ageIdx) < minSoFar)
               chosen = 1;
            end
            if ageIdx == nAges
               
               chosen = 1;
            end
            if m(ageIdx) < minSoFar
               minSoFar = val;
            end
         end
         results.chosen(idx) = ageIdx;
         results.optimal(idx) = (m(ageIdx) == min(m));
         results.value(idx) = m(ageIdx);
      end
      
end


