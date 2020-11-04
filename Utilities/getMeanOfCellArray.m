function [mu, med] = getMeanOfCellArray(c)
lens = cellfun('length', c);
m = nan(length(c),max(lens));
for(i = 1:length(c))
    curr = c{i};
    if(size(curr,1)>1)
        curr = curr';
    end
    m(i,1:length(curr)) = curr;
end
mu = nanmean(m);
med = nanmedian(m);
