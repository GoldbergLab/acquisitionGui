function u = windowMedian(x, winSize, winStep)
if(~exist('winStep','var'))
    winStep = winSize;
end
if(winSize == 1)
    u = x;
elseif(winStep == winSize)
    n = floor(length(x)/winSize);
    x = x(1:n*winSize);
    u = nanmedian(reshape(x,winSize,[]));
else
    n = 1:winStep:length(x)-winSize+1;
    n = repmat(n,winSize,1) + repmat((0:winSize-1)',1,length(n));
    u = nanmedian(x(n));
end
    