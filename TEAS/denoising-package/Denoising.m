function Cleaned_speech=Denoising(Noisy_speech,fs,noise_range)
%Denoising with MMSE method with Ephraim's method
%signal input noisy signal
%noise_range=[t1,t2] between t1-t2(s)
T=(length(Noisy_speech)-1)/fs;
if isempty(noise_range)%noise_range=[],choose the first second
  msgbox('No noise range detected');
end
t1=max(0,noise_range(1));
t2=min(noise_range(2),T);
%assert(t1<=t2||t1<0||t2>T,'Bad noise range');
Noise=Noisy_speech(1+ceil(t1*fs):floor(t2*fs));
Noisy_speech=Noisy_speech/max(abs(Noisy_speech));
Noise=Noise/max(abs(Noise));

%Parameter setting
Window_seg=0.02*fs;    
nfft=2*Window_seg;         
Shift_Percentage = 0.5;    
normFactor=1/Shift_Percentage;
overlap = fix((1-Shift_Percentage)*Window_seg); 
offset = Window_seg - overlap;
IndMaxNoisySpeech = fix((length(Noisy_speech)-nfft)/offset);
IndMaxNoise= fix((length(Noise)-nfft)/offset);
alpha = 0.98;
HanWindow = hanning(Window_seg);

% Initialization variables
Previous_weighted_SpeechFFT = zeros(nfft,1);
Cleaned_speech = zeros(length(Noisy_speech),1);
Periodogramme_Noise = zeros(nfft,1);

% Noise analyze
for mm = 0:IndMaxNoise
    Segment_noise = Noise(mm*offset+1:mm*offset+Window_seg,1);     
    SegmentWindowed_noise = HanWindow.*Segment_noise;  
    SW_noise_FFT = fft(SegmentWindowed_noise,nfft);      
    Periodogramme_Noise = Periodogramme_Noise + abs(SW_noise_FFT).^2;
end
sigmaNoise = Periodogramme_Noise./(IndMaxNoise-1);

% Denoising process
for mm = 0:IndMaxNoisySpeech
    % Compute FFT speech windowed segment
    Segment_speech = Noisy_speech(mm*offset+1:mm*offset+Window_seg);       
    SegmentWindowed_speech = HanWindow.*Segment_speech;   
    SW_speech_FFT = fft(SegmentWindowed_speech,nfft);        
    SW_speech_FFT_phase = angle(SW_speech_FFT);       
    % Compute the SFTA estimator
    SNR_aPosteriori = abs(SW_speech_FFT).^2./sigmaNoise; 
    SNR_aPriori = alpha.*Previous_weighted_SpeechFFT.^2./sigmaNoise + ...
        (1 - alpha).*max(SNR_aPosteriori-1,0); 
    v = SNR_aPosteriori.*SNR_aPriori./(1 + SNR_aPriori);
    ExpoInt_v = Compute_ExponentialIntegral(v);     
    % Update variables
    Weighted_SpeechFFT = (SNR_aPriori./(1+SNR_aPriori)).*exp(0.5*ExpoInt_v).*abs(SW_speech_FFT);
    Previous_weighted_SpeechFFT = Weighted_SpeechFFT;
    SW_speech_FFT = Weighted_SpeechFFT.*exp(1i*SW_speech_FFT_phase);
    % Reconstruction
    Cleaned_speech(mm*offset+1:mm*offset+1+nfft-1) = Cleaned_speech(mm*offset...
        +1:mm*offset+1+nfft-1) + real(ifft(SW_speech_FFT,nfft))/normFactor; 
end
Cleaned_speech = Cleaned_speech./max(abs(Cleaned_speech));
end