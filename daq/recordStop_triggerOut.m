function [bStatus, endSamp] = daq_recordStop(endSamp, channels, dio)
%daq_recordStart_triggerOut begins saving a set of channels to a file starting from

[bStatus, startSamp, filenames] = daq_recordStart(startSamp, filename, aiChannels);
if bStatus
    % Turn off trigger out signal
    putvalue(dio, 0);
end
