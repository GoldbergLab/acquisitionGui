function [bStatus] = daq_setSongDetect(songDetect)
% Set songDetect digital output to the value in songDetect (should be 0 or 1)

global GDIO
% Set trigger out signal
try
    putvalue(GDIO, 0);
    bStatus = true;
    disp(sprintf('SONG DETECT SET: %d', songDetect));
catch
    beep;
    bStatus = false;
    disp(sprintf('WARNING! POSSIBLY FAILED TO SET SONG DETECT to %d', songDetect));
end
