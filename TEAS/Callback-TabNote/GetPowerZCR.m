function [ powerCurve, ZCRCurve, time ] = GetPowerZCR(audioData, windowLength, step,Fs)
%GETPOWERZCR Summary of this function goes here
%   Detailed explanation goes here
%   Input
%   @audioName: the name of the audio
%   @windowLength: the length of the window
%   @step: the length of step
%   Output
%   @PowerCurve: the power curve of the audio (RMS)
%   @ZCRCurve: the zero crossing rate of the audio
%   @time: the corresponding time index.

    channels = size(audioData,2);
    %make the multichannel into one chanel
    if channels > 1
        audioData = sum(audioData,2);
    end

    frameNumTotal = ceil((length(audioData)-windowLength)/step);
    powerCurve = zeros(frameNumTotal,1);
    ZCRCurve = zeros(frameNumTotal,1);
    pin  = 0;
    pend = length(audioData);
    frameNum = 0;
    while pin<pend
        frameNum = frameNum + 1;
        if (pin+windowLength > length(audioData))
            %padding zero, if the final frame doesn't have enough data
            %points
            frame = [audioData(pin+1:end);zeros((pin+windowLength)-length(audioData),1)];
        else
            frame = audioData(pin+1:pin+windowLength);
        end

        powerCurve(frameNum) = sqrt(sum(frame.^2));
        ZCRCurve(frameNum) = ZCR(frame);

        pin = pin + step;

    end
%     powerCurve = medf(powerCurve,21,length(powerCurve));
%     powerCurve = smooth(powerCurve,51);
%     powerCurve = (powerCurve-min(powerCurve))/(max(powerCurve)-min(powerCurve));
    %----obtain the time axis for frames---------
    time = zeros(frameNum,1);
    time(1) = windowLength/2/Fs;
    for n = 2:frameNum
        time(n) = time(n-1) + step/Fs;
    end
%     time = time - time(1); %make the time start from zero
    %----------------------------------------------------------

end

