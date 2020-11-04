function [windows, counts] = getTriggeredWindows(sig, trigNdx, varargin)
%each window around the triggers is a row of the windows matrix.
%counts returns (for each column in windows) the number of elements which
%do not contain padding, be the padding be zeroes or nan.

%Default Parameters
%TODO add triggering on particular syllable catagory...
P.preSamples = 10000;
P.postSamples = 10000;
P.edgeCases = {'exclude', 'zeroPad', 'NaNPad'};
P = parseargs(P,varargin{:});

%Orient signal and trigNdx
if(size(trigNdx,2) > size(trigNdx,1))
    trigNdx = trigNdx';
end
if(length(trigNdx) == 0)
    windows = [];
    counts = [];
    return;
end
if(size(sig,2) > size(sig,1))
    sig = sig';
end

%Handle edge cases
if(strcmp(P.edgeCases, 'exclude'))
    startWins = trigNdx - P.preSamples;
    endWins = trigNdx + P.postSamples;
    bndx = (startWins >=1) & (startWins<=length(sig)); %logical index
    bndx = bndx & (endWins >=1) & (endWins<=length(sig));
    trigNdx = trigNdx(bndx);
elseif(strcmp(P.edgeCases, 'zeroPad') || strcmp(P.edgeCases, 'NaNPad'))
    sig = [nan(P.preSamples,1); sig; nan(P.postSamples,1)];
    trigNdx = trigNdx + P.preSamples;
end

%Construct a matix of window indicies
template = [-P.preSamples:P.postSamples];
ndx = repmat(template, length(trigNdx), 1)' + repmat(trigNdx, 1, length(template))';
windows = reshape(sig(ndx), length(template), [])';
counts = sum(~isnan(windows), 1);

if(strcmp(P.edgeCases, 'zeroPad'))
    windows(isnan(windows)) = 0;
end



