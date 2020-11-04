function [starttime frametimes data] = Record_webcam(num)
% [starttime frametimes data] = Record_webcam(num)
%   Records num frames from the webcam
%   starttime is the start of the first frame (in absolute Matlab time)
%   frametimes are times of each of the frames relative to the first one
%   data is a 4-dimensional (Y-res)x(X-res)x(3)x(num) matrix, where
%   data(:,:,:,i) is the ith frame (3rd dimension is for color)

adaptors = imaqhwinfo; % get info about installed adaptors
vid = videoinput(adaptors.InstalledAdaptors{3}, 1, 'RGB24_960x720'); % get the first adaptor available

set(vid,'FramesPerTrigger', num);
start(vid);
[data,time,abstime] = getdata(vid, num);
stop(vid);

starttime = datenum(abstime(1).AbsTime);
frametimes = time-time(1);

delete(vid); % clear memory