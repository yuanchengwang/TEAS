function mel = hz2mel(hz)
%hz2mel Convert from hertz to mel scale
%   m = hz2mel(f) converts values in hertz to values on the mel frequency
%   scale.
%
%   EXAMPLE: Get 32 frequency values uniformly spaced on the mel scale
%
%   % Convert [20, 8000] to mel scale:
%   m = hz2mel([20,8000]);
%   % Generate a row vector of 32 values linearly spaced on the mel scale:
%   melVect = linspace(m(1),m(2),32);
%   % Get equivalent frequencies in hertz:
%   hzVect = mel2hz(melVect);
%
%   See also MEL2HZ, HZ2BARK, HZ2ERB, BARK2HZ, ERB2HZ.

%   Copyright 2018 The MathWorks, Inc.

%#codegen

validateattributes(hz,{'single','double'}, ...
    {'nonempty','real','nonnan','finite'}, ...
    'hz2mel','x')

mel = 2595 .* log10(1 + (hz./700) );