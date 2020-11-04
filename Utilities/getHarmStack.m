function sig = getHarmStack(fundamentalFreq, harmAmps, fs, numSamps)
time = linspace(0, numSamps/fs, numSamps);
sig = zeros(1,length(time));
for(nHarm = 1:length(harmAmps))
    sig = sig + harmAmps(nHarm)*sin(2*pi*fundamentalFreq*nHarm*time);
end

