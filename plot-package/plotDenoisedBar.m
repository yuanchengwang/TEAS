function plotDenoisedBar(hObject,eventData,AmpData,axeAudio)
%PLAYDENOISEDWAVEBAR 此处显示有关此函数的摘要
%   AmpData is the ordinate range of the image
%   data.deniosedbar is the progress bar
    global data;
    
    try
         data=rmfield(data,'deniosedbar');
    catch
         data.deniosedbar = line(axeAudio,[0 0],[0 0],'Color','r'); 
    end
    
    time = data.DenoisedWavePlayer.CurrentSample/data.fs;
    data.deniosedbar = line(axeAudio,[time time],[min(AmpData) max(AmpData)],'Color','r');

end

