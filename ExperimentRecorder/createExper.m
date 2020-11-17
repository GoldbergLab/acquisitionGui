function exper = createExper(rootdir)
%Creates a folder for all files related to this experiment.  Also saves a
%.mat file to this folder containing the experiment description.

if(~exist('rootdir', 'var'))
    rootdir = pwd;
end



debug = true;
if debug
    r = num2str(randi([0, 10000], 1, 1));
    birdname = ['test_bird_', r];
    birddesc = ['test bird description ', r];
    expername = ['test_exper ', r];
    experdesc = ['it is a test exper ', r];
    mkdir(rootdir, birdname);
    mkdir([rootdir,'/',birdname], expername);
    exper.dir = [rootdir,'\',birdname,'\',expername,'\'];
    exper.birdname = birdname;
    exper.birddesc = birddesc;
    exper.expername = expername;
    exper.experdesc = experdesc;
    exper.datecreated = datestr(now,30);
    exper.deviceID = 'Dev1';
    exper.desiredInSampRate = 44100;
    exper.audioCh = 0;
    exper.songDetectCh = 2;
    exper.sigCh = [];
    for(nName = 1:length(exper.sigCh))
        exper.sigName{nName} = ['signal_', num2str(nName)];
        exper.sigDesc{nName} = ['it is signal number ', num2str(nName)];
    end
else
    

fprintf('\n')
disp('Create new experiment:')
fprintf('\n')
birdname = input('Enter a bird name (no spaces or strange characters): ','s');
birddesc = input('Enter a description of the bird: ','s');
expername = input('Enter an experiment name: ','s');
experdesc = input('Enter a description of the exper: ','s');

mkdir(rootdir, birdname);
mkdir([rootdir,'/',birdname], expername);

exper.dir = [rootdir,'\',birdname,'\',expername,'\'];
exper.birdname = birdname;
exper.birddesc = birddesc;
exper.expername = expername;
exper.experdesc = experdesc;
exper.datecreated = datestr(now,30);

exper.deviceID = input('Enter the NI DAQ device ID (eg. ''Dev1''): ', 's');
exper.desiredInSampRate = input('Enter the desired input sampling rate: ');
exper.audioCh = input('What hw channel will audio be on (-1 if no audio): ');
exper.songDetectCh = input('What digital output hw channel should song detect signal go out on (-1 if no song detect output): ');
exper.sigCh = input('Enter vector of other hw channels to be recorded ([] if none): ');

for(nName = 1:length(exper.sigCh))
    exper.sigName{nName} = input(['Enter name of signal on channel ', num2str(exper.sigCh(nName)), ': '],'s');
    exper.sigDesc{nName} = input(['Enter description of signal on channel ', num2str(exper.sigCh(nName)), ': '],'s');
end


end

save([rootdir,'\',birdname,'\',expername,'\exper.mat'], 'exper');
