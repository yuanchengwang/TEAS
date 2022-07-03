function remove_unvoiced(hObject,eventData)
% REMOVE_UNVOICED function aims to plot/deplot the pitch with unvoiced
% area annotated in previous step. Save w/wo unvoiced part.
global data;
if isfield(data,'pitch') && isfield(data,'noise_ranges')
    if ~isempty(data.noise_ranges)
        if  data.CB.unvoiced.Value
            data.pitch_new=data.pitch;
            for i=1:size(data.noise_ranges)
                position=logical((data.pitchTime<=data.noise_ranges(i,2)).*(data.pitchTime>=data.noise_ranges(i,1)));
                data.pitch_new(position)=0;
            end
            plotPitch(data.pitchTime,data.pitch_new,data.axePitchTabAudio,1,1);%spec plot_flag,plot_clean    
            plotPitch(data.pitchTime,data.pitch_new,data.axeOnsetOffsetStrength,0,1);
            plotPitch(data.pitchTime,data.pitch_new,data.axePitchTabVibrato,0,1);
            plotPitch(data.pitchTime,data.pitch_new,data.axePitchTabPortamento,0,1);
        else
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio,1,1);%spec plot_flag,plot_clean    
            plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,1);
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato,0,1);
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabPortamento,0,1);
        end
    end
end