function acquireTriggeredOnSong(exper)
%Start daq and monitor audio for songs.  Acquire songs and signals that
%occur during songs.  Save as files to the exper directory.

%exper: An experiment structured created using createExper.

%Initialize the daq toolbox

%input channels
inChans = [];
if(exper.audioCh>-1)
    inChans = [exper.audioCh];
else
    error('No audio channel.  Cannot monitor for singing.');
end
inChans = [inChans, exper.sigCh];

%parameters
buffer= 90; %Seconds
updateFreq = 4; %Hz
[ai, ao, dio, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(exper.deviceID, inChans, exper.desiredInSampRate, [], 1, exper.songDetectCh, buffer, updateFreq);

daqSetup.actInSampleRate = actInSampleRate;
daqSetup.actOutSampleRate = actOutSampleRate;
daqSetup.buffer = buffer;
daqSetup.actUpdateFreq = actUpdateFreq;
save([exper.dir,'daqSetup',datestr(now,30),'.mat'], 'daqSetup');

%Start data acquisition
daq_Start;
disp('Filling buffer.');
pause(5);
disp('Starting audio monitoring.');


%Song Detection Parameters
%These parameters are currently fixed, but in the future they could be
%included in the birdSongDesc variable.
minFreq = 2000; %Frequency range in which song has power
maxFreq = 6000;
pwThres = .2; %Power threshold for song trigger
preSamps = ceil(2*actInSampleRate); %Save data 5 seconds prior song start.
postSamps = ceil(2*actInSampleRate); %Save date 3 seconds after song end.
windowSize = fix(actInSampleRate/3); %spectragram window size.

%Convert frequency range to indices in fft.
minNdx = floor((windowSize/actInSampleRate)*minFreq + 1);
maxNdx = ceil((windowSize/actInSampleRate)*maxFreq + 1);

%Monitor channels for song like audio, and save as songs:
filenum = getLatestDatafileNumber(exper)
currnum = filenum; %Number of currently selected datafile.
plotnum = 0; %Number of currently displayed datafile.
if(length(exper.sigCh) > 0)
    currchan = exper.sigCh(1);
else
    currchan = exper.audioCh;
end
plotchan = currchan;
[data, time, sampNum] = daq_peekLast(ceil(actInSampleRate)); %grab last second of data
nextPeek = sampNum+length(time);
bPaused = false;
try
while(true)
    tic
    audio = data(:,1);

    %Take specgram and measure power in each time-slice
    [b,f,t] = specgram(audio, windowSize, actInSampleRate);
    power = mean(abs(b(minNdx:maxNdx,:)), 1);

    if(~daq_isRecording(exper.audioCh))
        %Since not currently recording this bird, check for song start.
        if( max(power) > pwThres )
            %If sufficient power to signify song, then begin recording
            songStartSampNum = sampNum;
            [filenamePrefix, filenum] = getNewDatafilePrefix(exper);
            [bStatus, startSamp, filenames] = daq_recordStart_triggerOut(songStartSampNum - preSamps, [exper.dir, filenamePrefix], inChans);
            if(~bStatus)
                warning('Start recording failed' );
            else
                disp(['Started recording.', num2str(filenum)]);
            end
            stopSamp = sampNum + length(time) - 1;
        end
    else
        %Since already recording this bird, check for song ending.
        if( max(power) >  pwThres )
            stopSamp = sampNum + length(time) - 1;
            %Send Text Message - Teja
            sendmail('6077930733@vtext.com', 'Gmail Test', 'Song Recorded');
        end
        if( sampNum + length(audio) - 1 - stopSamp > postSamps )
            songEndSampNum = sampNum + length(audio) - 1;
            [bStatus, endSamp] = daq_recordStop_triggerOut(songEndSampNum, inChans);
            % Turn off song detect signal
            putvalue(dio, 0);
            if(~bStatus)
                warning('Song stop recording failed.');
            else
                disp('Stopped recording.');
            %Send Text Message - Teja
            sendmail('6077930733@vtext.com', 'Gmail Test', 'Song Recorded');
            end
            currnum = filenum;
        end
    end

    %Wait for new samples to be collected
    while(toc < .9)
        if(~daq_isRecording(exper.audioCh))
            t_start = toc;

            h = figure(1000);
            if(toc < .9)
                char = get(h, 'CurrentCharacter');
                set(h,'CurrentCharacter','~');
                if(char == 'p')
                    playAudio(exper, currnum);
                elseif(char == ',')
                    currnum = currnum -1;
                    if(currnum < 1 )
                        currnum = 1;
                    end
                elseif(char == '.')
                    currnum = currnum + 1;
                    if(currnum > filenum)
                        currnum = filenum;
                    end
                elseif(char == '1')
                    currchan = 1;
                elseif(char == '2')
                    currchan = 2;
                elseif(char == 'y')
                    if(~bPaused)
                        bPaused = true;
                        disp('paused.');
                        oldThres = pwThres;
                        pwThres = 300000;
                    else
                        bPaused = false;
                        disp('restarted.');
                        pwThres = oldThres;
                        nextPeek = daq_getCurrSampNum;
                    end
                elseif(char == 'r' | char == 't')
                    recSampNum = daq_getCurrSampNum;
                    [filenamePrefix, filenum] = getNewDatafilePrefix(exper);
                    [bStatus, startSamp, filenames] = daq_recordStart_triggerOut(recSampNum, [exper.dir, filenamePrefix], inChans);
                    if(~bStatus)
                        warning('Forced Start recording failed' );
                    else
                        disp(['Forced Started recording.', num2str(filenum)]);
                    end
                    if(char == 't')
                        disp('Recording for 60 seconds');
                        pause(60);
                    elseif(char == 'r')
                        pause(.01);
                        char = '';
                        while(true)
                            pause(.05);
                            char = get(h, 'CurrentCharacter');
                            set(h,'CurrentCharacter','~');
                            if(char == 'r')
                                break;
                            end
                        end
                    end
                    recSampNum = daq_getCurrSampNum;
                    [bStatus, endSamp] = daq_recordStop_triggerOut(recSampNum, inChans);
                    if(~bStatus)
                        warning('Song stop recording failed.');
                    else
                        disp('Forced Stopped recording.');
                    end
                    currnum = filenum;
                    nextPeek = recSampNum;
                elseif(char == 'q')
                    daqreset;
                    return;
                end
                pause(.05);
            end

            if(toc < .9)
                h = figure(1000);
                if( currnum~=0 & (plotnum ~= currnum | plotchan~= currchan))

                     audio = loadAudio(exper,currnum);
                     [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper,currnum,currchan);
                     subplot(2,1,1);
                     if(length(audio)>0)
                        displayAudioSpecgram(audio, exper.desiredInSampRate);
                     end
                     title(['AUDIO: ', exper.birdname, exper.expername, ' ',num2str(currnum), ' ', timeCreated]);
                     timeAxis = [0:length(audio)-1]/exper.desiredInSampRate;
                     subplot(2,1,2);
                     if(length(sig)>0)
                         plot(timeAxis,sig);
                         axis tight;
                     else
                         warning('Length 0 recorded');
                         currnum
                     end
                     title(['SIGNAL: ', exper.birdname, exper.expername, ' ',num2str(currnum), ' ', timeCreated]);
                     plotnum = currnum;
                     plotchan = currchan;

                     if((toc) - t_start > .9)
                        disp(['warning: display code running too slowly:', num2str((toc) - t_start)]);
                     end
                end
            end
        end
    end

    %grab new data with 100ms overlap
    [data, time, sampNum] = daq_peek(round(nextPeek-actInSampleRate/10));
    nextPeek = sampNum+length(time);
end
catch ME
    % Ensure trigger out gets turned off
    putvalue(dio, 0);
    rethrow(ME);
end
% Ensure trigger out gets turned off
putvalue(dio, 0);
