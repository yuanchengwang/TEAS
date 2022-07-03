function [filterBank,Fc,BW] = MelFilterBank(fs,varargin)
%DESIGNAUDITORYFILTERBANK Design auditory filter bank.
%   filterBank = designAuditoryFilterBank(fs) returns a frequency-domain
%   auditory filter bank, filterBank. fs is the input sample rate, in Hz.
%   filterBank is returned as a N-by-L array, where N is the number of
%   bands and L is the number of frequency points, respectively.
%
%   filterBank = designAuditoryFilterBank(fs,'FrequencyScale',SCALE)
%   specifies the frequency scale as either 'mel', 'bark', or 'erb'. If
%   unspecified, SCALE defaults to 'mel'.
%
%   filterBank = designAuditoryFilterBank(fs,'FFTLength',FFTLENGTH)
%   specifies the FFT length. If unspecified, FFTLENGTH defaults to 1024.
%
%   filterBank = designAuditoryFilterBank(fs,'FrequencyRange',FREQRANGE)
%   specifies the frequency range over which to design the filter bank.
%   If unspecified, FREQRANGE defaults to [0, fs/2].
%
%   filterBank = designAuditoryFilterBank(fs,'NumBands',NUMBANDS)
%   specifies the number of bands in the filter bank. If unspecified,
%   NUMBANDS defaults to ceil(hz2erb(FREQRANGE(2)) - hz2erb(FREQRANGE(1)))
%   when FrequencyScale is 'erb', and to 32 otherwise.
%
%   filterbank = designAuditoryFilterBank('Normalization',NORM) specifies 
%   how the filter bank energy is normalized as either 'bandwidth', 'area',
%   or 'none'. If unspecified, NORM defaults to 'bandwidth'.
%
%   [filterbank,Fc,BW] = designAuditoryFilterBank(...) returns the
%   center frequencies, Fc, of the bands (in Hz) and the bandwidths, BW, of
%   each filter in Hz.
%
%   % Example: Design an auditory filter bank and use it to compute a
%   % mel spectrogram.
%
%   [audioIn,fs] = audioread('Counting-16-44p1-mono-15secs.wav');
%       
%   % Compute spectrogram
%   win     = hann(1024,'periodic');
%   [~,F,T,S] = spectrogram(audioIn,win,512,1024,fs,'onesided');
%
%   % Design auditory filter bank
%   [filterBank,CF] = designAuditoryFilterBank(fs,'FFTLength',1024,...
%                        'NumBands',16,'Normalization','none');
%
%   % Visualize filter bank
%   plot(F , filterBank.')
%   grid on
%   title('Mel Filter Bank')
%   xlabel('Frequency (Hz)')
%      
%   % Compute mel spectrogram
%   SMel = filterBank * S;
%
%   See also gammatoneFilterBank, melSpectrogram.

%   Copyright 2019 The MathWorks, Inc.

%#codegen

%validateattributes(fs,{'single','double'}, ...
%    {'positive','real','scalar','nonnan','finite'}, ...
%    'designAuditoryFilterBank','fs');
%Default parameters
params.FrequencyRange=[0,fs/2];
params.FFTLength=1024;
params.FrequencyRange='mel';
params.Normalization= 'bandwidth';
%Setting parameters
for i=1:length(varargin)
    if strcmp(varargin{i}, 'NumBands')
        params.NumBands=varargin{i+1};
    end
    if strcmp(varargin{i}, 'FrequencyRange')
        params.FrequencyRange=varargin{i+1};
    end
    if strcmp(varargin{i},'FFTLength')
        params.FFTLength=varargin{i+1};
    end
    if strcmp(varargin{i},'Normalization')
        params.Normalization=varargin{i+1};
    end
    if strcmp(varargin{i},'FrequencyScale')
        params.FrequencyScale=varargin{i+1};
    end
end

FRange     = double(params.FrequencyRange);
SampleRate = double(fs);

if strcmp(params.FrequencyScale,'erb')
    
    fhigh      = FRange(2);
    flow       = FRange(1);
    highERB    = hz2erb(fhigh);
    lowERB     = hz2erb(flow);
    Fc          = erb2hz(linspace(lowERB,highERB,params.NumBands));
    
    coeffs = audio.internal.computeGammatoneCoefficients(SampleRate,Fc.');
    
    filterBank = coder.nullcopy(zeros(params.NumBands , params.FFTLength));
    for index = 1:params.NumBands
        filterBank(index,:) =  abs(freqz(coeffs(:,:,index),params.FFTLength,'whole'));
    end
    
    % Derive Gammatone filter bandwidths as a function of center
    % frequencies
    BW = 1.019 * 24.7 * (0.00437 * Fc + 1);

else
    if strcmp(params.FrequencyScale,'mel')
        range          = hz2mel(FRange);
        bandEdges      = mel2hz(linspace(range(1),range(end),params.NumBands+2));
    else
        range          = hz2bark(FRange);
        bandEdges      = bark2hz(linspace(range(1),range(end),params.NumBands+2));
    end
    [fbank,Fc,FFTLengthTooSmall] = designMelFilterBank( ...
        SampleRate,bandEdges,params.FFTLength,1,'None','Hz','double');
    
    filterBank = fbank.';
    
    BW = bandEdges(3:end) - bandEdges(1:end-2);
    
    if  FFTLengthTooSmall && isempty(coder.target)
        warning('FFTLength is too small');
    end
end

if strcmp(params.Normalization,'area')
    % Weight by area
    weightPerBand = sum(filterBank,2);
    for i = 1: params.NumBands
        filterBank(i,:) = filterBank(i,:)./weightPerBand(i);
    end
elseif strcmp(params.Normalization,'bandwidth')
    % Weight by bandwidth
    weightPerBand   = 2./BW;
    for i = 1: params.NumBands
        filterBank(i,:) = filterBank(i,:).*weightPerBand(i);
    end
end

if mod(params.FFTLength , 2) == 0
    select = 1:params.FFTLength/2+1;    % EVEN
else
    select = 1:(params.FFTLength+1)/2;  % ODD
end
filterBank = filterBank(:,select);

end