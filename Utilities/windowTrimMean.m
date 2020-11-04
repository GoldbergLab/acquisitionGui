function u = windowTrimMean(x, winSize, trimPercentile, winStep)
if(~exist('winStep','var'))
    winStep = winSize;
end
if(winSize == 1)
    u = x;
elseif(winStep == winSize)
    n = floor(length(x)/winSize);
    x = x(1:n*winSize);
    u = trimmean(reshape(x,winSize,[]), trimPercentile);
else
    n = 1:winStep:length(x)-winSize+1;
    n = repmat(n,winSize,1) + repmat((0:winSize-1)',1,length(n));
    u = trimmean(x(n), trimPercentile);
end
    