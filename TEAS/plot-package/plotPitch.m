function a=plotPitch(time,pitch,axePitch,plot_flag,plot_clean,varargin)
%PLOTPITCH Plot pitch curve
%   Input
%   @time: the time vector for pitch
%   @pitch: the pitch vector
%   @axePitch: the axe for pitch plot
    midiScale = (0.5:1:127.5)';
    faceColor = [.5,.5,.5];
    faceAlpha = 0.2;
    if nargin==6
        color=varargin{1};
    else
        color='black';
    end
    
    axes(axePitch);
    if plot_clean
    cla(axePitch,'reset');%don't use delete and clear
    end
    global data;
    if plot_flag && isfield(data,'Cleaned_speech')
        if ~isfield(data,'EdgeTime') ||~isfield(data,'Cleaned_speech_spec')
            [data.Cleaned_speech_spec,data.EdgeTime]=spect_onset(data.Cleaned_speech);
            [data.mel_spec,data.F_new,data.BW]=mel_spect_onset(data.Cleaned_speech_spec);
        end
        spec=10*log10(dynamicRangeLimiting(abs(data.mel_spec), 60));
        cdata = real2rgb(spec,'jet');
        data.spec_plot=surface(repmat(data.EdgeTime,size(data.mel_spec,1),1),repmat(freqToMidi(data.F_new'),1,size(data.mel_spec,2)),zeros(size(data.mel_spec)),cdata,'EdgeColor','none','FaceColor','texturemap',...
  'CDataMapping','direct');alpha(0.3);
        hold on
    end
    
%     plot(time,pitch);
%     if nargin==7
%     yyaxis left; 
%     end
    a=plot(time,freqToMidi(pitch),'-','Color',color);
    if plot_flag && isfield(data,'Cleaned_speech')
        xlim([min(time(1),data.EdgeTime(1)),max(time(end),data.EdgeTime(end))]);
    else
        xlim([time(1),time(end)]);
    end
    title('Pitch Curve');
%     ylabel('Frequency(Hz)');
    ylabel('MIDI name');
    xlabel('Time(s)');
    
%     xlim([0 30]);
    if plot_flag && isfield(data,'Cleaned_speech')
        hold off;
    end
    ylim([55 90]);
    yticks(25:2:105);
    yticklabels(notename(25:2:105));
%     ylim([100 350]);
end

