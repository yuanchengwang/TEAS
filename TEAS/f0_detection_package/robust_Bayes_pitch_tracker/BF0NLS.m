function result=BF0NLS(speechSignal,samplingFreq,f0Bounds,prew_flag)
% -----------------------------------------------------------------------
% format of the input and output arguments
% 
% input:
% input arguments --> as the names suggested
% plot_flag: 0 when you do not want a plot  (0 in default)
% prew_flag: 0 when you do not want to prewhiten the signal (0 in default)
% 
% Par_set.segmentTime is the segmentTime in seconds  (25 ms in default)
% Par_set.segmentShift is the segmentShift in seconds (10 ms in default)
% Par_set.f0Bounds is the F0 boundaries in Hz ([70 400] Hz in default)
% 
% output:
% result.tt         -->   time vector
% result.ff         -->   Fundamental frequency estimates
%                         (when all the frames are considered as voiced)
% result.oo         -->   order estimates  
%                         (when all the frames are considered as voiced)
% result.vv         -->   voicing probability
% result.best_ff    -->   Best fundamental frequency estimates (setting the F0=nan 
%                         when voicing probability is less than .5)
% result.best_order -->   Best harmonic order estimates (setting the order=nan 
%                         when voicing probability is less than .5)
% 
% result.loss -->   Output probability for each frame.
%                         
% Example for for customize Par_set
% 
% Par_set.segmentTime = 0.025; 25 ms for each segment (default value)
% Par_set.segmentShift = 0.01; 10 ms for segment shift (default value)
% Par_set.f0Bounds =[70, 400]; pitch is bounded between 70 to 400 Hz (default value)
% 
% 
% Written by Liming Shi, Aalborg 9000, Denmark
% Email: ls@create.aau.dk
% -----------------------------------------------------------------------


if nargin<4
%   do not use prewhitening in default
    prew_flag=0; 
end


%% resample to 16 KHz for tuned parameters. However, the sampling frequency can be changed.
% fs_fine_tuned=44100;
% if fs_fine_tuned~=samplingFreq
% speechSignal=resample(speechSignal,fs_fine_tuned,samplingFreq);%may lead a
% slight misalign, we match the resolution with pYIN
%samplingFreq=fs_fine_tuned;
segmentTime = 0.025; %0.025->0.03 seconds
segmentShift = 128/44100; % 0.01->0.0029 seconds， pYIN
%f0Bounds= [200, 1500]; %[70, 400]; cycles/sample!!!!
std_pitch=2;%0.5805;%default 2 is not good, since the pitch deviation is too frequency!!!!max(2/10*segmentShift*1000,0.5); 
c=[.7 .3;.4,.6];%^(0.29);%[.7 .3;.4,.6]!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normalization step
sumE = sqrt(speechSignal'*speechSignal/length(speechSignal));
scale = sqrt(3.1623e-5)/sumE; % scale to -45-dB loudness level
speechSignal=speechSignal*scale;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nData = length(speechSignal);
% set up
f0Bounds=f0Bounds/samplingFreq;
segmentLength = round(segmentTime*samplingFreq/2)*2; % samples
nShift = round(segmentShift*samplingFreq); % samples
nSegments = floor((nData-segmentLength)/nShift)+1;%+segmentLength/2 if zeropadding

if prew_flag==0
    maxNoHarmonics = 10;
else
    if prew_flag==1
        maxNoHarmonics = 30;
    end
end
f0Estimator = BayesianfastF0NLS(segmentLength, maxNoHarmonics, f0Bounds, std_pitch/samplingFreq,.7,c);
%speechSignal_padded=[zeros(segmentLength/2,1);speechSignal];%may lead to
%an octave error.
% do the analysis
idx = 1:segmentLength;
f0Estimates = nan(nSegments,1); % cycles/sample
order=nan(nSegments,1);
voicing_prob=nan(nSegments,1);
%loss=nan(nSegments,580,10);
h = waitbar(0,'BNLS pitch tracker...');
if prew_flag==0
    for ii = 1:nSegments
        waitbar(ii/nSegments,h,sprintf('%d%% BNLS pitch tracker...',round(ii/nSegments*100)));
        speechSegment = speechSignal(idx);
        [f0Estimates(ii),order(ii),voicing_prob(ii)]=f0Estimator.estimate(speechSegment,0);%,loss(ii,:,:)
        idx = idx + nShift;
    end
else
    if prew_flag==1        
        for ii = 1:nSegments
            waitbar(ii/nSegments,h,sprintf('%d%% BNLS pitch tracker...',round(ii/nSegments*100)));
            speechSegment = speechSignal_padded(idx);
            [f0Estimates(ii),order(ii),voicing_prob(ii)]=f0Estimator.estimate(speechSegment,1,segmentShift);%,loss(ii,:,:)
            idx = idx + nShift;
        end
    end
end

f0Estimates_remove_unvoiced=f0Estimates;
unvoiced_indicator=voicing_prob<.5;
f0Estimates_remove_unvoiced(unvoiced_indicator)=nan;
order_remove_unvoiced=order;
order_remove_unvoiced(unvoiced_indicator)=nan;
timeVector = ((0:nSegments-1)*segmentShift)'+segmentLength/2/samplingFreq;
close(h);
result.tt=timeVector;
result.ff=f0Estimates*samplingFreq;
result.oo=order;
%result.loss=loss;
result.vv=voicing_prob;
result.best_ff=f0Estimates_remove_unvoiced*samplingFreq;
result.best_order=order_remove_unvoiced;
% if plot_flag==1
%     figure;
%     subplot(4,1,4)
%     plot([0:length(speechSignal_padded)-1]/samplingFreq,speechSignal_padded/max(abs(speechSignal_padded)));
%     xlim([0,(length(speechSignal_padded)-1)/samplingFreq])
%     xlabel('Time [s]');
%     ylabel('Amplitude');
%     subplot(4,1,3)    
% %   plot the spectrogram
%     window = gausswin(segmentLength);
%     nOverlap = segmentLength-nShift;
%     nDft = 2048;
%     [stft, stftFreqVector] = ...
%         spectrogram(speechSignal_padded, window, nOverlap, nDft, samplingFreq);
%     powerSpectrum = abs(stft).^2;
%     imagesc(timeVector, stftFreqVector, ...
%     10*log10(dynamicRangeLimiting(powerSpectrum, 60)));
%     axis xy;
%     ylim([0,f0Bounds(2)*samplingFreq+100])
%     hold on;
%     plot(timeVector, result.best_ff, 'r-', 'linewidth',2);
%     ylabel('Frequency [Hz]');
%     subplot(4,1,2)    
%     plot(timeVector,result.best_order,'r.', 'linewidth',2)
%     xlim([timeVector(1),timeVector(end)])
%     ylabel('Order estimate')
%     subplot(4,1,1)    
%     plot(timeVector,result.vv,'r-', 'linewidth',2)
%     xlim([timeVector(1),timeVector(end)])
%     ylabel('Voicing probability')
% end
end