function [timeF,FDMoutput,PD,PR] = PERestimate(originalPitch,originalTime)
%VIBRATODETECTFUNC Detection the vibratos
%   Input:
%   @originalPitch: the pitch curve
%   @originalTime: the cooresponding time for the pitch curve
%   @vibratoRateLimit: frequency threshold for DT. [min,max]Hz
%   @vibratoAmplitudeLimit: amplitude threshold for DT. [min,max]
%   Output:
%   @vibratoCandidatesDT: the detected vibratos using DT. [start:end:duration]
%   @vibratoParametersFDMDT: the corresponding vibrato parameters for DT.
%   @timeF: the time vector match FDMoutput. Each point is one frame.
%   @FDMoutput: the output of FDM in frame wise. 1st column: frequency; 2nd
%   column: amplitude(vibrato extent). Each row is one frame.
    
    f0Fs = 1/(originalTime(2)-originalTime(1));
    frameCriterion = 5; %the frame criterion for the vibrato candidates, make it larger or equal to 6 consecutive frames.
    %---------do interpolation for the pitch using spline function---------
    %Since the data misses some data points, it is necessary to do
    %interpolation.
%     interpolationF = f0Fs;  %interpolation frequency
%     newTime = [0:1/interpolationF:originalTime(end)]';
%     interpolatedSpitch = (interp1(originalTime,originalPitch,newTime,'spline'));
    %----------------------------------------------------------------------

%     time = newTime;
    time = originalTime;
%     midiSpitch = interpolatedSpitch;
    %To have correct extent, we shuold use the MIDI scale
    midiSpitch = freqToMidi(originalPitch);
    midiSpitch = smooth(midiSpitch,10);
    FDMDTSign = 1.25;
    FDMBRSign = 2.5;
    %-----------------------------------------

    %-----------get the frame---------------------------------------
    windowLengthTime = 0.125;  %window length in seconds
    windowLength = floor(windowLengthTime*f0Fs);
    stepOfWindow = 0.25;
    step = floor(windowLength*stepOfWindow);

    frameNumTotal = ceil((length(midiSpitch)-windowLength)/step);
    fdResonanceF = zeros(1,frameNumTotal);
    fdResonanceD = zeros(1,frameNumTotal);
    PR=zeros(1,frameNumTotal);
    PD=zeros(1,frameNumTotal);
    pin  = 0;
    pend = length(midiSpitch)-windowLength;
    frameNum = 0;
    h = waitbar(0,'Periodogram-based Vibrato detecting...');
    output3=cell(1,frameNumTotal);
    while pin<pend
        frameNum = frameNum + 1;
        waitbar(frameNum/frameNumTotal,h,sprintf('%d%% Periodogram-based Vibrato detecting...',round(frameNum/frameNumTotal*100)));
        %remove the DC component  
        frame = midiSpitch(pin+1:pin+windowLength)-mean(midiSpitch(pin+1:pin+windowLength));
        %using FDM for each frame   
        %frame=frame.*gausswin(windowLength);
        A=fft(frame,floor(f0Fs/0.1));%.*gausswin(windowLength);delta(f)=0.1hz
        tempD=A(1+(2/0.1:14/0.1))';%[2,14]Hz
        tempFk=2:0.1:14;
        %output3{frameNum} = [tempFk',tempD'];
        %size(tempD)
%         if isempty(output3{frameNum}) == 1
%             fdResonanceF(frameNum) = NaN;
%             fdResonanceD(frameNum) = NaN;
%         else
            extent = 2*abs(tempD)/windowLength;  %this is the vibrato extent.
            [fdResonanceD(frameNum),indexMaxfdD] = max(extent); %find the biggest resonance
            fdResonanceF(frameNum) = real(tempFk(indexMaxfdD));%get the biggest resonance's frequency              
        %end        
        power=frame'*frame;
        if power/windowLength<1e-10 || isempty(output3)
            PD(frameNum)=0;
            PR(frameNum)=0;
        else
            %recons=real(extent(indexMaxfdD)*exp(-2j*pi/f0Fs*output3(indexMaxfdD,1).*(0:(n-1))));
            %[A,~] = max(abs(extent)); %find the biggest resonance
%     recons=real(extent(indexMaxfdD)*exp(-2j*pi/Fs*output3(indexMaxfdD,1).*(0:(n-1))));
%     recons=reshape(recons,n,1);
    %cod=abs(extent(indexMaxfdD))^2/(s'*s+para.lambda*n);
            %cod=2*A^2/n/(s'*s+para.lambda*n);
            recons=max(abs(tempD))^2;
            %recons=reshape(recons,windowLength,1);
            %cod=abs(extent(indexMaxfdD))^2/(s'*s+para.lambda*n);
            %cod=recons'*recons-s'*s;
            PR(frameNum)=min(1,recons/power/windowLength);
            PD(frameNum)=min(1,(2*recons-power)/windowLength);
        end
        pin = pin + step;
    end
	close(h);
    %----obtain the time axis for frames---------
    timeF = zeros(frameNum,1);
    timeF(1) = windowLength/2/f0Fs + time(1);
    for n = 2:frameNum
        timeF(n) = timeF(n-1) + step/f0Fs;
    end
    FDMoutput = [fdResonanceF',fdResonanceD'];
end

