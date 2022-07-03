function getVFreePitchFn(hObject,eventData)
%GETVFREEPITCHFN return vibrato free pitch curve for portmaneto detection
    global data;    
    if isfield(data,'vibratos')
        %clear portamentos; 
        plotClearFeature('Portamento');
        data.pitchVFree = getVibratoFreePitch(data.pitchTime,data.pitch,data.vibratos);
        plotPitch(data.pitchTime,data.pitchVFree,data.axePitchTabPortamento,0,1);
        %clean the logistic statistics;
        for i=1:length(data.textPort)
            data.textPort(i).String=[];
        end
    else
        msgbox('No vibrato detected.');
    end
end

