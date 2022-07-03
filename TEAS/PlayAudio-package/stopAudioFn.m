function stopAudioFn( hObject,eventData )
%STOPVIBRATOFUNCTION Stop the feature audio
%   Detailed explanation goes here
    global data;
    stop(data.audioFeaturePlayer);
    data=rmfield(data,'audioFeaturePlayer');
    if isfield(data,'bar')
        delete(data.bar);
    end
end

