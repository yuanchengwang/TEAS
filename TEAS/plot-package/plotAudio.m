function a=plotAudio(time,audio,axeAudio,fileName,flag)
%PLOTAUDIO Plot the audio waveform
%   Input
%   @time: the time vector for pitch
%   @audio: the audio vector (one channel)
%   @axeAudio: the axe for audio waveform plot
%   @fileName: the file name of the audio

    axes(axeAudio);
    if flag
        yyaxis right;
        a=plot(time,audio,'-','color',[1 0.5 0]);%orange color
    else
        a=plot(time,audio,'-');
    end
    
    title(fileName,'Interpreter','none','fontname','宋体');  
    xlabel('Time(s)');
    xlim([time(1),time(end)]);
    max_audio=max(abs(audio))*1.5;
    ylim([-max_audio,max_audio]);
    ylabel('Amplitude');
end

