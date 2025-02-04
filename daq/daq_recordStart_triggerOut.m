function [bStatus, startSamp, filenames] = daq_recordStart_triggerOut(startSamp, filename, aiChannels)
%daq_recordStart_triggerOut is a wrapper for daq_recordStart which also turns on a digital channel to signal recording start

[bStatus, startSamp, filenames] = daq_recordStart(startSamp, filename, aiChannels);
if bStatus
    % Turn on trigger out signal
    daq_setSongDetect(true);
end
