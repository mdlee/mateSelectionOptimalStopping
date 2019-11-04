function thresholds = findOptimalThresholds(mu, sigma, values, goal)
% thresholds = optimalThresholds(mu, sigma, goal)
%  determines the optimal thresholds for an optimal
%  stopping problem in which the presented value from values on each trial
%  is drawn from truncated Gaussians with means mu and standard deviations sigma
%  according to a goal of 'min' or 'max'
 
% Constants and storage
nTrials = length(mu);
thresholds = nan(nTrials, 1);
thresholds(end) = 0;
nValues = length(values);
 
% Derive thresholds
for trialIdx = 1:(nTrials-1)
   % probability will get a better value on later trial
   probBetter = nan(nValues, 1);
   % consider each possible value that could be presented this trial
   for valIdx = 1:nValues
      val = values(valIdx);
      probFuture = nan(nTrials-trialIdx, 1);
      count = 0;
      % probability each future trial is below
      for futureIdx = (trialIdx+1):nTrials
         count = count + 1;
         Z = normcdf(100, mu(futureIdx), sigma(futureIdx)) - normcdf(0, mu(futureIdx), sigma(futureIdx));
         switch goal
            case 'max'
               probFuture(count) = log((normcdf(val, mu(futureIdx), sigma(futureIdx)) - normcdf(0, mu(futureIdx), sigma(futureIdx)))/Z);
            case 'min'
               probFuture(count) = log(1 - (normcdf(val, mu(futureIdx), sigma(futureIdx)) - normcdf(0, mu(futureIdx), sigma(futureIdx)))/Z);
         end
      end
      % probability all future trials are below
      probBetter(valIdx) = exp(sum(probFuture));
   end
   % threshold is lowest one (or highest for min) that has at least 50% chance of not being bettered
   keepIdx = find(probBetter >= 0.5);
   switch goal
      case 'max'
         thresholds(trialIdx) = min(keepIdx);
      case 'min'
         thresholds(trialIdx) = max(keepIdx);
   end
end