function outputStrategyTable(dataName, modelName, labelsRow, labelsCol, z1, z2)
% OUTPUTSTRATEGYTABLE Print to file a latex table that gives the
% counts of subjects with each combination of inferred strategies
% across the environemtns
%    outputStrategyTable(dataName, modelName, labelsRow, labelsCol, z1, z2)

nStrategies = numel(labelsRow);

count = nan(nStrategies, nStrategies);
for idx1 = 1:nStrategies
   for idx2 = 1:nStrategies
      count(idx1, idx2) = length(intersect(find(z1 == idx1), find(z2== idx2)));
   end
end

fid = fopen(sprintf('tables/strategyTable_%s_%s', dataName, modelName), 'w');
fprintf(fid, '\\begin{table}\n');
fprintf(fid, '\\begin{center}\n');
fprintf(fid, '\\begin{tabular}{%s}\n', ['r' repmat('c', [1, nStrategies])]);
fprintf(fid, '\\toprule\n');
fprintf(fid, '& \\multicolumn{%d}{c}{Male Env} \\\\ \n', nStrategies);
str = 'Female Env';
for idx = 1:nStrategies
   str = sprintf('%s & %s', str, labelsCol{idx});
end
fprintf(fid, sprintf('%s \\\\\\\\ \n', str));
fprintf(fid, '\\hline\n');
for idx1 = 1:nStrategies
   str = labelsRow{idx1};
   for idx2 = 1:nStrategies
      if count(idx1, idx2) == 0
         str = sprintf('%s & --', str);
      else
         str = sprintf('%s & %d', str, count(idx1, idx2));
      end
   end
   fprintf(fid, sprintf('%s \\\\\\\\ \n', str));
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{center}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);
end

