function bRecording = daq_isRecording(channel)
%Returns true if recording is currently taking place on specified hardware
%channel.

global BTRIGGER;
global GAICHANS;

matchannel = find(GAICHANS == channel);

bRecording = BTRIGGER(matchannel);
