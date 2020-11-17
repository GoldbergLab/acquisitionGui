function [bStatus, endSamp] = daq_recordStop_triggerOut(endSamp, aiChannels)
%daq_recordStop_triggerOut begins saving a set of channels to a file starting from

[bStatus, endSamp] = daq_recordStop(endSamp, aiChannels);

% Turn off trigger out signal
daq_setSongDetect(false);
