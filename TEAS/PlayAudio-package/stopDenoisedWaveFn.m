function stopDenoisedWaveFn( hObject,eventData )
%STOPDENOISEDWAVEFUNCTION Stop the feature audio
%   Detailed explanation goes here
    global data;
    stop(data.DenoisedWavePlayer);
    delete(data.deniosedbar);
end

