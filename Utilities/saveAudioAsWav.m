function saveAudioAsWav(wavFileName, wavSampleRate, exper, filenum)

audio = loadAudio(exper,filenum);
[p, q] = rat(wavSampleRate / exper.desiredInSampRate);
wavAudio = resample(audio, p, q);
wavwrite(wavAudio, wavSampleRate, wavFileName);



