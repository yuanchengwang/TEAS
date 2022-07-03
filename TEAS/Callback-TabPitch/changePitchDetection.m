function changePitchDetection(hObject,eventData)
%CHANGEPITCHDETECTION Change the method name for pitch detection method
%   

    global data;
    
    pressedNum = eventData.Source.Value;
    pitchMethodList = eventData.Source.String;
    
    data.pitchMethod = pitchMethodList{pressedNum};
    %{'Yin','Pyin(Matlab)','Pyin(Tony)','BNLS','SFPE'}
    
    if pressedNum==3 && ~strcmp(data.PitchFreThresEdit.String,'100-1600')
        data.PitchFreThresEdit.String='100-1600';
        sprintf('Adjusting the pitch threshold of pyin(tony) is not supported, the 100-1600 is fixed threshold.')
    end
end

