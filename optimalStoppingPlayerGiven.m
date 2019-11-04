function results = optimalStoppingPlayerGiven(m, thresholds, goal)
% results = optimalStoppingPlayerGiven(m, thresholds, goal)
%  characterizes the performance of a player for given problems
%  in m according to given thresholds a goal of 'min' or 'max',
%
% results.chosen  = the trial chosen by player
% results.value   = the value chosen by player
% results.correct = whether or not the chosen value was maximal

[nProblems, nAges] = size(m);

results.chosen = nan(nProblems, 1);    % trial where choice made
results.correct = nan(nProblems, 1); % whether choice was maximal
results.value = nan(nProblems, 1);   % chosen value

switch goal
   case 'max'
      for idx = 1:nProblems
         % play the problem
         maxSoFar = -1;
         chosen = 0;
         ageIdx = 0;
         while chosen == 0
            ageIdx = ageIdx + 1;
            if (m(idx, ageIdx) > thresholds(ageIdx)) & (m(idx, ageIdx) > maxSoFar)
               chosen = 1;
            end
            if ageIdx == nAges
               chosen = 1;
            end
            if m(idx, ageIdx) > maxSoFar
               maxSoFar = m(idx, ageIdx);
            end
         end
         results.chosen(idx) = ageIdx;
         results.correct(idx) = (m(idx, ageIdx) == max(m(idx, :)));
         results.value(idx) = m(idx, ageIdx);
      end
      
   case 'min'
      for idx = 1:nProblems
         % play the problem
         minSoFar = values(end) + 1;
         chosen = 0;
         ageIdx = 0;
         while chosen == 0
            ageIdx = ageIdx + 1;
            if (m(idx, ageIdx) < thresholds(ageIdx)) & (m(idx, ageIdx) < minSoFar)
               chosen = 1;
            end
            if ageIdx == nAges
               chosen = 1;
            end
            if m(idx, ageIdx) < minSoFar
               minSoFar = m(idx, ageIdx);
            end
         end
         results.chosen(idx) = ageIdx;
         results.correct(idx) = (m(idx, ageIdx) == min(m(idx, :)));
         results.value(idx) = m(idx, ageIdx);
      end
      
end


