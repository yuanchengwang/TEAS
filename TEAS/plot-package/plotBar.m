function plotBar(hObject,eventData,AmpData,axeAudio)
%plotBar 此处显示有关此函数的摘要
%   AmpData is the ordinate range of the image
%   data.bar is the progress bar
    global data;
    
    try
        delete(data.bar);
    catch
        data.bar = line(axeAudio,[0 0],[0 0],'Color','r'); 
    end
    
    time = data.audioFeaturePlayer.CurrentSample/data.fs;
    data.bar = line(axeAudio,[time time],[min(AmpData) max(AmpData)],'Color','r');
end


