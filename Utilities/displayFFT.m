function [fftdata, freq] = displayFFT(data, sampleRate)

%freq is measured as number of periods within the length of data.
fftdata = fft(data(:,1),length(data));
freq = (sampleRate/length(data))*(0:length(fftdata)-1); %targetFreq = #ofSeconds in data times 60 cycles per second.
freqNdx = find(freq<(sampleRate/2));
plot(freq(freqNdx), 20*log10(abs(fftdata(freqNdx))))
