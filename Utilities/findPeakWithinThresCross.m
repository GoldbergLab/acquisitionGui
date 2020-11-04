function [peakNdx] = findPeakWithinThresCross(sig, fThres, bAbove)

[leading, falling] = detectThresholdCrossings(sig, fThres, bAbove);

peakNdx = [];
for(nCross = 1:length(leading))
    if(bAbove)
        [m,ndx] = max(sig(leading(nCross):falling(nCross)));
    else
        [m,ndx] = min(sig(leading(nCross):falling(nCross)));
    end
    peakNdx(nCross) = leading(nCross) + ndx - 1;
end



