function exportTremoloFn(hObject,eventData)
%EXPORTTREMOLOFN export note and tremolo for pth track.
global data;
global protocol;
currentname=data.subgroup.SelectedTab.Title;
p=str2num(currentname(isstrprop(currentname,'digit'))); 
savedFileName=data.filenamedefault;
savedFileName = [savedFileName,'_tremolo_str',num2str(p)];
savedFileType = {'*.mid','MIDI file (*.mid)'};

%let user specify the path using modal dialog box
[savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);

%Defense code, note,tremolo for corresponding track must exist.
if isnumeric(savedFileName) == 0
if isfield(data,'TremoloTrack')   
    if p>length(data.TremoloTrack)
        msgbox('No tremolo for this track imported.');
        return
    else
        tremolos=data.TremoloTrack{p};
    end
else
    msgbox('No tremolo for this track imported.');
    return
end

if isfield(data,'NoteTrack')
    if p>length(data.NoteTrack)
        msgbox('No note for this track imported.');
        return
    else
        if isempty(data.NoteTrack{p})
            msgbox('Empty note for corresponding track imported.');
            return
        else
            notes=data.NoteTrack{p};
            NoteOnset=notes(:,1);
            NoteDuration=notes(:,2);
            avgPitch=notes(:,3);
            %velocity=cell2mat(data.tremoloPara);
            velocity=notes(:,5);
        end
    end
else
    msgbox('No note for this track imported.');
    return
end

%%tremolo must be within a note.
for i=1:size(tremolos,1)
    if tremolos(i,1)<notes(1,1)
        msgbox('Bad tremolo imported');
        return
    end
    if tremolos(i,2)>round(sum(notes(end,1:2)),4)%end
        msgbox('Bad tremolo imported');
        return
    end
    if size(data.NoteTrack,1)>1%in middle
        for j=1:size(data.NoteTrack,1)-1
            if (tremolos(i,1)<notes(j+1,1)&& tremolos(i,1)>round(sum(notes(j,1:2)),4))||(tremolos(i,2)<notes(j+1,1)&& tremolos(i,2)>round(sum(notes(j,1:2)),4))
                msgbox('Bad tremolo imported');
                return
            end
        end
    end
end

%tremolosDetail = getPassages(pitchTime,pitch,data.TremoloTrack{p},0);%clipping
%tremolo
sf_tremolo=notename(data.channelEdit{p,4}.String);
sf_note=notename(data.channelEdit{p,1}.String);
if ~strcmp(protocol.midimode,'default')
    sf_tremolo{1}=sf_tremolo{1}+12;
    sf_note{1}=sf_note{1}+12;
end
% flag=zeros(size(notes,1),1);%note or tremolo
% for i=1:size(notes,1)%nb of notes
%     match=notes(i,1)-tremolos(:,1)==0;
%     if sum(match)==1
%         flag(i)=sf_tremolo{1};%onset match
%     else
%         flag(i)=sf_note{1};%onset match
%     end
% end
midi.notes=[NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
tmp=PTnoteAdd(midi.notes,tremolos,data.beats_per_second,sf_note{1},sf_tremolo{1},'note');
midi.notes=[midi.notes;tmp];
if ~isempty(protocol.string_force)%String forcing for each note.
    sf=notename(protocol.string_force{p});
    if ~strcmp(protocol.midimode,'default')
        sf{1}=sf{1}+12;
    end
    midi.notes=[midi.notes;NoteOnset(1)*data.beats_per_second,NoteDuration(1)*data.beats_per_second,1,sf{1},protocol.resolution,NoteOnset(1),NoteDuration(1)];
    %String forcing+default velocity for all external note protocol.resolution.
end
%midi.notes=[midi.notes;NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
%Export module Midi construction
isp_midiwrite(midi,[savedPathName,savedFileName]);
end
end