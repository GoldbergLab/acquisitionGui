function acqgui_restartGUI(obj, event, guifig)
%Callback function that invokes acquisition with Stim.

if(daq_isUpdating)
    %the restart timer will try again in 5 seconds.
    return;
end

handles = guidata(guifig);
tsd = getappdata(guifig,'threadSafeData');
dgd = aa_getAppDataReadOnly(guifig, 'acqguidata');
[recinfo, status] = aa_checkoutAppData(guifig, 'acqrecordinfo');
if(~status)
    return;
end

if(~isempty(timerfind('Name','trigOnSong')))
    if(([recinfo(:).bSongTrigRecording]) | ([recinfo(:).bForcedRecording]))
        %the restart timer will try again in 5 seconds.
        aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);
        return;
    end
    stop(timerfind('Name','trigOnSong'));
    delete(timerfind('Name','trigOnSong'));
end
daqreset;
aa_checkinAppData(guifig, 'acqrecordinfo', recinfo);

%stop the restart-timer from trying to restart.  The deed is done.
stop(obj);
delete(obj);

%extract info needed for restart.
startHour = str2double(get(handles.editStartTime, 'String'));
stopHour = str2double(get(handles.editStopTime, 'String'));

%close the gui.
close(guifig);
daqreset;

%can't pause here, can't just wait, because timers are stop and deleted
%asynchronously.  Not sure why matlab does that.
n = now;
[y, mn, d, h, m, s] = datevec(n);
if(startHour >((n-floor(n))*24))
    startTime = datenum(y,mn,d,startHour,0,0);
else
    startTime = datenum(y,mn,d+1,startHour,0,0);
end

for(nExper = 1:length(dgd.expers))
    songDetection(nExper).songDensity = dgd.experData(nExper).songDetection.durationThreshold; %#ok<AGROW>
    songDetection(nExper).powerThres = dgd.experData(nExper).songDetection.ratioThreshold; %#ok<AGROW>
    songDetection(nExper).songLength = dgd.experData(nExper).songDetection.songDuration; %#ok<AGROW>
    dispchanAudio(nExper) = dgd.experData(nExper).dddbackground.dispchanAudio;
    dispchan(nExper) = dgd.experData(nExper).dddbackground.dispchan;
    dispchan2(nExper) = dgd.experData(nExper).dddbackground.dispchan2;
    dispchan3(nExper) = dgd.experData(nExper).dddbackground.dispchan3;
end

t_startExper = timer;
set(t_startExper, 'Name', 'acqguiStartExperHelper');
set(t_startExper,'TimerFcn',{@startExperHelper, dgd.bTrigOnSong, ...
                                                dgd.expers, ...
                                                dgd.logfile, ...
                                                dispchanAudio, ...
                                                dispchan, ...
                                                dispchan2, ...
                                                dispchan3, ...
                                                songDetection, ...
                                                startHour, ...
                                                stopHour, ...
                                                tsd});
set(t_startExper,'ExecutionMode','singleShot');
set(t_startExper,'BusyMode', 'queue');
startat( t_startExper, startTime);

try
    acqgui_overnightBatch(dgd.expers);
catch
    warning(['Overnight batch failed: ', lasterr]);
end

function startExperHelper(obj, event, bTrigOnSong, cexpers, logfile, dispchanAudio, dispchan, dispchan2, dispchan3, songDetection, startHour, stopHour, tsd)
%create new days exper and restart gui.
for(nExper = 1:length(cexpers))
    rootndx = strfind(cexpers{nExper}.dir,cexpers{nExper}.birdname);
    rootdir = cexpers{nExper}.dir(1:rootndx-2);
    expers(nExper) = createExperAuto(rootdir, cexpers{nExper}.birdname, datestr(now,29), cexpers{nExper}.desiredInSampRate, cexpers{nExper}.audioCh, cexpers{nExper}.sigCh);
end
acquisitionGui('bTrigOnSong', bTrigOnSong, ...
               'logfile', logfile, ...
               'expers', expers, ...
               'dispchanAudio', dispchanAudio, ...
               'dispchan', dispchan, ...
               'dispchan2', dispchan2, ...
               'dispchan3', dispchan3, ...
               'songDetection', songDetection, ...
               'bRestartInMorning', true, ...
               'startHour', startHour, ...
               'stopHour', stopHour, ...
               'threadSafeData', tsd);