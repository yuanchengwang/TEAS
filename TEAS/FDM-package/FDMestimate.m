function [timeF,FDMoutput,PD,PR] = FDMestimate(originalPitch,originalTime)
%VIBRATODETECTFUNC(old name) Detection the vibratos, the is drawn out
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
    h = waitbar(0,'FDM Vibrato detecting...');
    f0Fs = (length(originalTime)-1)/(originalTime(end)-originalTime(1));

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

    %-----------FDM parameters---------------
    f_min = 2;  %f_min = 0, f_max = 20 for evaluation and discussion part of MM14 paper
    f_max = 20; 
    J = 4;
    k_max = 4;  %the number of times we iterate the solution (to make it more accurate). You should only use the final iteration, because in theory that is the most accurate result.
                %k_max = 10 for MM14 paper
    %--------------------------------------

    %-----------get the frame---------------------------------------
    windowLengthTime = 0.125;  %window length in seconds
    windowLength = floor(windowLengthTime*f0Fs);%43£¿
    stepOfWindow = 0.25;%proportion of window length
    step = floor(windowLength*stepOfWindow);%10

    frameNumTotal = ceil((length(midiSpitch)-windowLength)/step);
    fdResonanceF = zeros(1,frameNumTotal);
    fdResonanceD = zeros(1,frameNumTotal);
    PR=zeros(1,frameNumTotal);
    PD=zeros(1,frameNumTotal);
    pin  = 0;
    %pend = length(midiSpitch)-windowLength;
    frameNum = 0;
    for i=1:frameNumTotal
        frameNum = frameNum + 1;
        waitbar(frameNum/frameNumTotal,h,sprintf('%d%% FDM Vibrato detecting...',round(frameNum/frameNumTotal*100)));
        %remove the DC component  
        frame = midiSpitch(pin+1:pin+windowLength)-mean(midiSpitch(pin+1:pin+windowLength));
        %using FDM for each frame   
        [tempFk,tempD] = frameFDM3(frame,f0Fs,f_min,f_max,k_max);
        output = [tempFk(1:length(tempD)).',tempD.'];

        %delete the negative real frequency
        output2 = [output(real(output(:,1))>0,1),output(real(output(:,1))>0,2)];

        %throw away any real frequency outside the preset frequency range
        output3 = [output2((output2(:,1)>=f_min&output2(:,1)<=f_max),1),output2((output2(:,1)>=f_min&output2(:,1)<=f_max),2)];

        tempFk = output3(:,1);
        tempD = output3(:,2);

        if isempty(output3) == 1
            fdResonanceF(frameNum) = NaN;
            fdResonanceD(frameNum) = NaN;
        else
             extent = 2*abs(tempD);  %this is the vibrato extent.
            [fdResonanceD(frameNum),indexMaxfdD] = max(extent); %find the biggest resonance
            fdResonanceF(frameNum) = real(tempFk(indexMaxfdD));   %get the biggest resonance's frequency  
        end
        pin = pin + step;
        power=frame'*frame;
        if power/windowLength<1e-10 || isempty(output3)
            PD(frameNum)=0;
            PR(frameNum)=0;
        else
            %framewise cost compute periodogram   
            %extent = 2*output3(:,2);  %this is the vibrato extent.
            %[~,indexMaxfdD] = max(abs(extent)); %find the biggest resonance
            recons=real(extent(indexMaxfdD)*exp(-2j*pi/f0Fs*output3(indexMaxfdD,1).*(0:(windowLength-1))));
            recons=recons*recons';
            %cod=abs(extent(indexMaxfdD))^2/(s'*s+para.lambda*n);
            %cod=recons'*recons-s'*s;
            PR(frameNum)=min(1,recons/power);
            PD(frameNum)=min(1,(2*recons-power)/windowLength);
        end
    end

    %----obtain the time axis for frames---------
    timeF = ones(frameNumTotal,1)*(windowLength/2/f0Fs + time(1));
    timeF = timeF+(0:frameNumTotal-1)'*step/f0Fs;
     
    FDMoutput = [fdResonanceF',fdResonanceD'];
    close(h);
end

