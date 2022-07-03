function [ pitchPointArea ] = plotPitchPoints(pitchPoint,pitchPointTime,axeInput)
%PLOTPITCHPOINTS plot the new Features' pitch area selected on pitch curve
%   Input
%   @features:vector [start time,end time,duration]
%   @axeInput: plot the vibrato area on this axe
%   Output
%   @newPatchVibratoArea: the filled new feature area for plot.

    %plot the created pitch points
    axes(axeInput);
    if isscalar(pitchPointTime)
        hold on
        pitchPointArea = plot(pitchPointTime,pitchPoint,'x','Color',[0 1 0]);    
        hold off
    else
        hold on
        pitchPointArea = plot(pitchPointTime,pitchPoint,'Color',[0 1 0]);    
        hold off
    end
end

