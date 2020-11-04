function u = windowMeanOfLog(x, winSize)

n = floor(length(x)/winSize);
x = x(1:n*winSize);
u = mean(log10(reshape(x,winSize,[])));