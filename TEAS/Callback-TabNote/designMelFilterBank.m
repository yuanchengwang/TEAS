function [filterBank,centerFrequencies,FFTLengthTooSmall] = designMelFilterBank( ...
    fs,bandEdges,NFFT,sumExponent,normalization,designDomain,dataType)
%
% This function is for internal use and may change in a future release.
%
% fs            - Sample rate of audio input
% NFFT          - Number of bins in the DTFT
% bandEdges     - Band edges of filter bank
% sumExponent   - Exponent used for normalization. This controls whether you
%                 are analyzing in magnitude, power, or some random exponent.
% normalization - Type of normalization, specified as Area or Bandwidth.
% designDomain  - Domain in which the triangles are drawn, specified as
%                 'bin' (ETSI-style) or 'Hz' (Slaney-style).
% dataType      - Data type

%   Copyright 2017-2019 The MathWorks, Inc.
%#codegen

zeroCast  = cast(0,dataType);
oneCast   = cast(1,dataType);
twoCast   = cast(2,dataType);
threeCast = cast(3,dataType);
NFFTCast  = cast(NFFT,dataType);

% Determine the number of bands
numEdges = cast(numel(bandEdges),dataType);
numBands = numEdges - twoCast;

% Determine the number of valid bands
validNumEdges = sum( (bandEdges-(fs/twoCast)) < sqrt(eps(dataType)) );
validNumBands = validNumEdges - twoCast;

% Preallocate the filter bank
filterBank = zeros(NFFT,numBands,dataType);

centerFrequencies = bandEdges(2:end-1);

% Set this flag to true if the number of FFT length is insufficient to
% compute the specified number of mel bands
FFTLengthTooSmall = false;

if strcmpi(designDomain,'bin') %--------------------------------------------
    % This algorithm is specified by the ETSI standard: ETSI ES 201 108
    % V1.1.3 (2003-09)
    
    % Convert Band Edges from Hertz to Bins
    binBandEdges = round((bandEdges./fs)*NFFT)+oneCast;
    
    % Create triangular filters for each band
    for edgeNumber = oneCast:validNumBands
        
        % Rising side of triangle
        for i = binBandEdges(edgeNumber):binBandEdges(edgeNumber+oneCast)
            filterBank(i,edgeNumber) = (i - binBandEdges(edgeNumber))/ ...
                (binBandEdges(edgeNumber+oneCast)-binBandEdges(edgeNumber));
        end
        
        % Falling side of triangle
        for i = (binBandEdges(edgeNumber+oneCast)+oneCast):binBandEdges(edgeNumber+twoCast)
            filterBank(i,edgeNumber) = ...
                oneCast ...
                - (i - binBandEdges(edgeNumber+oneCast))/(binBandEdges(edgeNumber+twoCast) ...
                - binBandEdges(edgeNumber+oneCast));
        end
    end
else % 'Hz' %--------------------------------------------------------------
    % This algorithm is specified by the documentation of Slaney's Auditory
    % Toolbox.
    linFq = (zeroCast:NFFTCast-oneCast)/NFFTCast*fs;
    
    % Determine inflection points
    assert(validNumEdges<=numEdges)
    p = zeros(validNumEdges,oneCast,dataType);
    for edgeNumber = oneCast:validNumEdges
        p(edgeNumber) = find(linFq > bandEdges(edgeNumber),oneCast,'first');
    end
    
    % Create triangular filters for each band
    bw = diff(bandEdges);
    for k = oneCast:validNumBands
        % Rising side of triangle
        filterBank(p(k):p(k+oneCast)-oneCast,k) = ...
            (linFq(p(k):p(k+oneCast)-oneCast) - bandEdges(k)) / bw(k);
        
        % Falling side of triangle
        filterBank(p(k+oneCast):p(k+twoCast)-oneCast,k) = ...
            (bandEdges(k+twoCast) - linFq(p(k+oneCast):p(k+twoCast)-oneCast)) / bw(k+oneCast);
        
        if ~FFTLengthTooSmall && (isempty(p(k):p(k+oneCast)-oneCast) || isempty(p(k+oneCast):p(k+twoCast)-oneCast))
            FFTLengthTooSmall = true;
        end

    end
end

%--------------------------------------------------------------------------
% Apply normalization
%--------------------------------------------------------------------------
if strcmp(normalization,'Area')
    % Weight by area
    weightPerBand = sum(filterBank.^sumExponent);
    for i = oneCast:numBands
        filterBank(:,i) = filterBank(:,i)./weightPerBand(i);
    end
elseif strcmp(normalization,'Bandwidth')
    % Weight by bandwidth
    filterBandWidth = bandEdges(threeCast:end) - bandEdges(oneCast:end-twoCast);
    weightPerBand   = twoCast./filterBandWidth;
    for i = oneCast:numBands
        filterBank(:,i) = filterBank(:,i).*weightPerBand(i);
    end
end

end