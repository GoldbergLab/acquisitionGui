function ArgStruct=parseArgsLite(args,ArgStruct)
% PARSEARGSLITE Helper function for parsing varargin. 
%
%  ArgStruct= parseArgsLite(args, ArgStruct);
%
% This is my stripped-down version of parseArgs, written by Aslak Grinsted
% and available from the Mathworks file exchange. It doesn't allow for flag
% arguments, aliases, or abbreviations, but it is way faster.
%
% Author: Tom Davidson, tjd@mit.edu
%
%
% Example code:
%
% function out = testfn(varargin)
% defaults = struct('type', 'tree',...
%                   'name', 'oak')
% out = parseArgsLite(varargin, defaults);
% return;
%
%
%  >> testfn('name', 'maple')
%
%  ans = 
%      type: 'tree'
%      name: 'maple'
%
%
% $Id: parseArgsLite.m 372 2007-03-11 23:14:11Z tjd $

% 'struct', if left to its own devices, will create an *array* of structs when
% given any cell array objects as field values. We have to enclose such
% arguments in a 'value' cell array to avoid this behavior.

for k = 2:2:length(args), % only applies to 'values'
  if iscell(args{k}),
    args(k) = {args(k)};
  end
end

% parse the new inputs
inargs = struct(args{:});

% overwrite defaults
for fn = fieldnames(inargs)',
  fn = fn{:};
  if ~isfield(ArgStruct, fn),
    error(['Unknown named parameter: ' fn])
  end
  ArgStruct.(fn) = inargs.(fn);
end
