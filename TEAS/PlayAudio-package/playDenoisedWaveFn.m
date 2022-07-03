function playDenoisedWaveFn( hObject,eventData)
%PLAYDENOISEDWAVEFUNCTION Play feature audio.
%   Detailed explanation goes here
    global data;
    
    currentTabName = data.tgroup.SelectedTab.Title;
    if strcmp(currentTabName,'Read Audio')   
        axeFeature = data.axedenoisedWave;
    elseif strcmp(currentTabName,'Pitch detection')        
        axeFeature = data.axePitchWave;
    end
    
    %Get the ordinate range of the image
    AmpData = get(axeFeature,'YLim');
      
    data.DenoisedWavePlayer = audioplayer(data.Cleaned_speech, data.fs);
    
    %The progress bar is displayed in the 'Read Audio' and  'Pitch detection'
    set(data.DenoisedWavePlayer,'TimerPeriod',128/44000,'TimerFcn',{@plotDenoisedBar,AmpData,axeFeature});%,'StopFcn',@stopbar);
    play(data.DenoisedWavePlayer);
end

