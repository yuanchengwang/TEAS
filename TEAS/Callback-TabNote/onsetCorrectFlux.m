function onsetTime = onsetCorrectFlux(audioData,windowLength,step,Fs)
%ONSETCORRECFLUX using the spectral flux onset function to detect onset
%within note, and split the two notes having same pitch.
%   Input
%   @transcribedData: the transcribed note data. [start time:end time:MIDI]
%   @windowLength: the window length for calculate spectrogram
%   @step: the step for spectrogram
%   Output:
%   @transcribedDataCorrected: the corrected transcribed data. [start time:end time:MIDI]
    
    nfft = windowLength;
    
    %----spectral flux for onset detection---------
    [spec,~,tSpec] = spectrogram(audioData,windowLength,step,nfft,Fs);
    tSpec = tSpec - tSpec(1);   %make the time start from zero
    tSpec = tSpec';
    spec = abs(spec);

    specDiff = zeros(size(spec));
    specDiff(:,2:end) = diff(spec,1,2); 
    specDiffHWRP = (specDiff + abs(specDiff))/2; %half-wave rectifier function
    specFluxP = sum(specDiffHWRP);
    
    %smooth the spectral flux data
    specFluxP = smooth(specFluxP);
    
    %normalize to zero mean and one unit standard deviation
    specFluxP = specFluxP-mean(specFluxP);
    specFluxP = specFluxP./std(specFluxP);

    %-----peak-picking from Simon2006----
    w = 3; %window size
    step = 1;
    m = 3;  %multiplier
    peakIndex = [];
    %threshold
    th1 = 1;
    alpha = 0.9;

    g = zeros(size(specFluxP));
    for i = 2:length(specFluxP)
        g(i) = max([specFluxP(i),alpha*g(i-1)+(1-alpha)*specFluxP(i)]);
    end

    for i = 1+w*m:step:length(specFluxP)-w
       frame = specFluxP(i-w:i+w);
       if specFluxP(i) >= max(frame) &&...
          specFluxP(i) >= mean(specFluxP(i-m*w:i+w))+th1 &&...
          specFluxP(i) >= g(i-1)
          peakIndex(end+1) = i;
       end
    end
    onsetTime = tSpec(peakIndex);
    %--------------------------------------
end

