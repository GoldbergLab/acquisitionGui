function acqgui_timerFcnAcqTrigOnSong(obj, evnt, guifig)

%It is crucial, that this function, which accesses daq_data, does not
%interrupt the daq_bufferUpdate.  Interruptions result in crashes and
%freezes.
try
if(daq_isUpdating)
    return;
end

%check out necessary data.
daq_log('Not updating');
handles = guidata(guifig);
tsd = getappdata(guifig, 'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
[recinfo, bStatus] = aa_checkoutAppData(guifig, 'acqrecordinfo');
if(~bStatus)
    return;
end
[params, bStatus] = aa_checkoutAppData(guifig, 'songtrigdata');
if(~bStatus)
    aa_checkinAppData(guifig, 'acqrecordinfo',recinfo);
    return;
end

%grab new data with 100ms overlap
daq_log('Starting Peek.');
%nextPeek that the lowest next peek, they will generally all be equal.
nextPeek = min([params(logical(dgd.bTrigOnSong)).nextPeek]);
if(abs(nextPeek - daq_getCurrSampNum) > dgd.actInSampRate*10)
    beep;
    daq_log('Falling behind.  Skipping data for song detect.');
    warning('Falling behind.  Skipping data for song detect.');
    nextPeek = daq_getCurrSampNum - dgd.songDetectPeriod * dgd.actInSampRate;
end
%nextPeekActualSample = round(nextPeek-dgd.actInSampRate/10);
[data, time, sampNum] = daq_peek(nextPeek);
% disp(sprintf('Peeked: Data size = %s, sampRange = %d-%d, timeRange = %0.2f-%0.2f, timeWindow = %0.2f', num2str(size(data)), sampNum, sampNum+length(time), sampNum/dgd.actInSampRate, (sampNum+length(time))/dgd.actInSampRate, length(time)/dgd.actInSampRate))
for(nExper = find(dgd.bTrigOnSong))
    params(nExper).nextPeek = sampNum+length(time)-round(dgd.actInSampRate*dgd.songDetectPeriod*dgd.songDetectOverlap);
end
daq_log('Peek Completed.');

if(~dgd.bTrigOnSong(dgd.ce))
    set(handles.textSongScore, 'String', ['Song Score: --']);
end
if(isequal(get(handles.textSongScore, 'BackgroundColor'),[1,1,1]))
    set(handles.textSongScore, 'BackgroundColor', [1,1,.5]);
else
    set(handles.textSongScore, 'BackgroundColor', [1,1,1]);
end

bNewFile = false(1,length(dgd.expers));
for(nExper = find(dgd.bTrigOnSong))
    fs = dgd.expers{nExper}.desiredInSampRate;
    audio = data(:,dgd.experData(nExper).ndxOfAudioChan);
    sd = dgd.experData(nExper).songDetection;
    srp = tsd.songTrigParams(nExper);
    %Take specgram and measure power in each time-slice
    [b,f,t] = specgram(audio, sd.windowSize, dgd.actInSampRate, sd.windowSize, sd.windowOverlap);
%    disp(fprintf('size(stft)=%s, sd.minNdx=%s, sd.maxNdx=%s', num2str(size(b)), num2str(sd.minNdx), num2str(sd.maxNdx)))
    % Split the spectrogram by frequency band - song vs non-song frequency band
    %   Then find the mean power in each band for each windowed chunk.
    powerSong = mean(abs(b(sd.minNdx:sd.maxNdx,:)), 1);
    powerNonSong = mean(abs(b([1:sd.minNdx-1,sd.maxNdx+1:end],:)), 1) + eps;
    % Find the ratio between song and non-song power for each  windowed chunk
    songRatio = powerSong./powerNonSong;
    % Determine if the song power ratio is above the detection threshold for each  windowed chunk
    thresCross = double(songRatio>sd.ratioThreshold); % mod by tp
    % Convolve with window that is one windowed chunk long
    songDet = conv((thresCross),sd.windowAvg);

    maxSongScore = max(songDet);
    if(nExper == dgd.ce)
        set(handles.textSongScore, 'String', ['Song Score: ', num2str(maxSongScore)]);
    end
    daq_log('Song score computed');
    bNewFile(nExper) = false;
    % Update refractory period if necessary.
    if (params(nExper).songDetectRefractoryPeriodActive)
        % We have been in a refractory period. Should we still be?
        if (sampNum - params(nExper).stopSamp > srp.songDetectRefractoryPeriod*dgd.actInSampRate)
            % Refractory period completed.
            params(nExper).songDetectRefractoryPeriodActive = false;
            disp('Refractory period ended!')
        end
    end
    if(~recinfo(nExper).bSongTrigRecording & ~recinfo(nExper).bForcedRecording & ~params(nExper).songDetectRefractoryPeriodActive)%(~daq_isRecording(dgd.expers{dgd.ce}.audioCh))
        %Since not currently recording this bird and not in a refractory period, check for song start.
        if( (maxSongScore > sd.durationThreshold) )
            %If sufficient power to signify song, then begin recording
            daq_log('Attempt start song triggered recording.');
            firstCrossTime = t(find(songRatio>sd.ratioThreshold, 1, 'first'));
            firstCrossSamp = floor(firstCrossTime * dgd.actInSampRate) + 1;
            params(nExper).songStartSampNum = sampNum + firstCrossSamp;
            [filenamePrefix, recfilenum] = getNewDatafilePrefix(dgd.expers{nExper});
            recinfo(nExper).recfilenum = recfilenum;
            [bStatus, params(nExper).startSamp, params(nExper).filenames] = daq_recordStart_triggerOut(params(nExper).songStartSampNum - round(srp.preSecs*fs), [dgd.expers{nExper}.dir, filenamePrefix], dgd.experData(nExper).inChans);
            if(~bStatus)
                beep;
                warning('Start recording failed'); %#ok<WNTAG>
            else
                if(nExper == dgd.ce)
                    set(handles.textRecordingStatus, 'String', ['Started recording.', num2str(recinfo(nExper).recfilenum)]);
                    set(handles.textRecordingStatus, 'BackgroundColor', 'red');
                end
                recinfo(nExper).bSongTrigRecording = true;
                daq_log('Started song triggered recordings.');
            end
            params(nExper).stopSamp = sampNum + length(time) - 1;
        end
    elseif(recinfo(nExper).bSongTrigRecording)
        %Since already recording this bird, check for silence and file
        %getting too long.
        if (sampNum - params(nExper).songStartSampNum < round(srp.maxFileLength*fs))
            if (maxSongScore > sd.durationThreshold)
                % Song still detected, and we haven't exceeded maxFileLength, so don't stop recording, push back stopSamp so recording will continue.
                params(nExper).stopSamp = sampNum + length(time) - 1;
            end
        else
            params(nExper).songDetectRefractoryPeriodActive = true;
            disp('Refractory period started!')
        end
        if( (sampNum + length(audio) - 1 - params(nExper).stopSamp > round(srp.postSecs*fs)) || params(nExper).songDetectRefractoryPeriodActive)
            % There has been not-song for a period of more than postSecs seconds, or a refractory period is active, so we should stop recording.
            daq_log('Attempt to stop song triggered recordings.');
            songEndSampNum = sampNum + length(audio) - 1;
            [bStatus, endSamp] = daq_recordStop_triggerOut(songEndSampNum, dgd.experData(nExper).inChans);
            if(~bStatus)
                beep;
                warning('Song stop recording failed.'); %#ok<WNTAG>
            else
                if(nExper == dgd.ce)
                    set(handles.textRecordingStatus, 'String', ['Finished recording.', num2str(recinfo(nExper).recfilenum), '.   Ready to record.']);
                    set(handles.textRecordingStatus, 'BackgroundColor', 'green');
                    %Send Text Message - Teja
%                      sendmail('6077930733@vtext.com', 'Gmail Test', 'Song Recorded');
%                      display('sent text');
                end
                bNewFile(nExper) = true; %#ok<AGROW>
                daq_log('Requested finish song recordings.');
            end
        end
    end
end

%moved to before checkin to make sure that new recording can't begin
%while we wait for recording to complete.
for nExper = find(bNewFile)
    daq_log('Wait for new file to be written.');
    daq_waitForRecording(dgd.experData(nExper).inChans);
    if(dgd.sutterStatus)
        [microsteps, micronsApprox, Status] = sutterGetCurrentPosition(dgd.sutterConnection);
        if(Status)
            daq_appendProperty(params(nExper).filenames{1}, 'SutterMicronsX',  sprintf('%4.2f', micronsApprox(1)));
            daq_appendProperty(params(nExper).filenames{1}, 'SutterMicronsY',  sprintf('%4.2f', micronsApprox(2)));
            daq_appendProperty(params(nExper).filenames{1}, 'SutterMicronsZ',  sprintf('%4.2f', micronsApprox(3)));
        end
    end
    daq_log('File completed.');
    recinfo(nExper).bSongTrigRecording = false;
    recinfo(nExper).filenum = recinfo(nExper).recfilenum;
    recinfo(nExper).recFileTimes = [recinfo(nExper).recFileTimes, now];
    %%check for possible text messages to be sent:
    times = recinfo(nExper).recFileTimes;
    tmp = tsd.txtMessageParams;
    if(~isempty(tmp) && tmp.bOnWake && ~tmp.bSentWakeSong)
        if(length(times) >= tmp.nWakeFiles)
            if((times(end) - times(end - tmp.nWakeFiles + 1))*24*60 < tmp.nWakeMinutes)
                send_text_message(tmp.phonenum, tmp.carrier, [tmp.compName, ': ', dgd.expers{nExper}.birdname, ' has begun singing.']);
                tsd.txtMessageParams.bSentWakeSong = true;
                tsd.txtMessageParams.bSentNextSong = true;
            end
        end
    end
    if(~isempty(tmp) && tmp.bOnSong && ~tmp.bSentNextSong)
        if(length(times) >= tmp.nSongFiles)
            if((times(end) - times(end - tmp.nSongFiles + 1))*24*60 < tmp.nSongMinutes)
                send_text_message(tmp.phonenum, tmp.carrier, [tmp.compName, ': ', dgd.expers{nExper}.birdname, ' is singing.']);
                tsd.txtMessageParams.bSentNextSong = true;
            end
        end
    end
end

setappdata(guifig, 'threadSafeData', tsd);
aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
aa_checkinAppData(guifig, 'songtrigdata', params);

if(bNewFile(dgd.ce) & dgd.experData(dgd.ce).autoUpdate)
    daq_log('Updating Display.');
    acqgui_updateDisplayFile(guifig, recinfo(nExper).filenum);
    daq_log('Completed waiting and display.');
end
catch me
    disp(me.getReport('extended', 'hyperlinks', 'on'));
end
