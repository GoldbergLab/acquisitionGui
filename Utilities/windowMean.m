function u = windowMean(x, winSize)
if(winSize == 1)
    u = x;
else
    n = floor(length(x)/winSize);
    x = x(1:n*winSize);
    u = mean(reshape(x,winSize,[]));
end