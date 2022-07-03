function hz = mel2hz(mel)
%mel2hz Convert from mel scale to hertz
%   f = mel2hz(m) converts values on the mel frequency scale to values in
%   hertz.
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
%   See also HZ2MEL, BARK2HZ, ERB2HZ, HZ2BARK, HZ2ERB.

%   Copyright 2018 The MathWorks, Inc.

%#codegen

validateattributes(mel,{'single','double'}, ...
    {'nonempty','real','nonnan','finite'}, ...
    'mel2hz','x')

hz = 700 * (10.^ (mel/2595) - 1);