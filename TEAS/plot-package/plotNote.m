function [patchNoteArea]=plotNote(onset,duration,avgPitch,axeInput,varargin)
    axes(axeInput);
    yyaxis left;
    hold on
    if ~isempty(onset)
        for j=1:length(onset)
            %patchNoteArea(j) = fill([onset(j),onset(j)+duration(j),onset(j)+duration(j),onset(j)],[round(freqToMidi(avgPitch(j)))-1,round(freqToMidi(avgPitch(j)))-1,round(freqToMidi(avgPitch(j)))+1,round(freqToMidi(avgPitch(j)))+1],[.5 .5 .5],'FaceAlpha',0.5);%offset
            if nargin==4
                patchNoteArea(j) = rectangle('Position',[onset(j),round(freqToMidi(avgPitch(j)))-1,duration(j),2],'FaceColor',[0.5,0.5,0.5],'EdgeColor','k');
            elseif nargin==5%syn note
                patchNoteArea(j) = rectangle('Position',[onset(j),round(freqToMidi(avgPitch(j)))-1,duration(j),2],'EdgeColor',varargin{1},'LineStyle','--');%'FaceColor',[0.5,0.5,0.5],
            elseif nargin==6%vibrato or tremolo
                patchNoteArea(j) = rectangle('Position',[onset(j),round(freqToMidi(avgPitch(j)))-1,duration(j),2],'EdgeColor',varargin{1},'LineStyle',varargin{2});%'FaceColor',[0.5,0.5,0.5],
            elseif nargin==7%portamento
                patchNoteArea(j) = rectangle('Position',[onset(j),floor(freqToMidi(avgPitch(j))),duration(j),ceil(freqToMidi(varargin{3}(j)))-floor(freqToMidi(avgPitch(j)))],'EdgeColor',varargin{1},'LineStyle',varargin{2});%'FaceColor',[0.5,0.5,0.5],
            end
        end
    end
    hold off
end