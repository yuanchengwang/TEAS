function exportPortamentoFn(hObject,eventData)
%EXPORTPORTAMENTOFN export note and portamento for pth track.
global data;
global protocol;
currentname=data.subgroup.SelectedTab.Title;
p=str2num(currentname(isstrprop(currentname,'digit'))); 
savedFileName=data.filenamedefault;
savedFileName = [savedFileName,'_portamento_str',num2str(p)];
savedFileType = {'*.mid','MIDI file (*.mid)'};

%let user specify the path using modal dialog box
[savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
%Defense code, pitch,note,portamento for corresponding track must exist.
if isnumeric(savedFileName) == 0
if isfield(data,'PortamentoTrack')
    if p>length(data.PortamentoTrack)
        msgbox('No portamento for this track imported.');
        return
    else
        portamentos=data.PortamentoTrack{p};
    end
else
    msgbox('No portamento for this track imported.');
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
            velocity=notes(:,5);
        end
    end
else
    msgbox('No note for this track imported.');
    return
end

if isfield(data,'PitchTrack')
    if p>length(data.PitchTrack)
        msgbox('No pitch for corresponding track imported.');
        return
    else
        if isempty(data.PitchTrack{p})
            msgbox('Empty pitch for corresponding track imported.');
            return
        else
           pitch=data.PitchTrack{p};
           pitchTime=data.PitchTimeTrack{p};
        end
    end
else
    msgbox('No pitch for this track imported.');
    return
end
%%portamento must be between two notes.
note_tmp=[];
for i=1:size(portamentos,1)
    if portamentos(i,1)<notes(1,1)
        msgbox('Bad portamento imported.');
        return
    end
    if portamentos(i,2)>round(sum(notes(end,1:2)),4)%end
        msgbox('Bad portamento imported.');
        return
    end
    if size(notes,1)>1%in middle
        for j=1:size(notes,1)-1
            if (portamentos(i,1)>notes(j,1)&& portamentos(i,1)<round(sum(notes(j,1:2)),4))
                note_tmp=[note_tmp,j];
                break
            end
            if i== size(notes,1)-1
                msgbox(['Bad portamento imported for No.',num2str(i),' portamento']);
                return
            end
        end
    else
        msgbox('Notes are not enough for pitch transition.');
        return
    end
end

%Silence cannot be located in portamento area and Add pitch-range for portamento
for i=1:size(portamentos,1)
    [~,time1]=min(abs(pitchTime-portamentos(i,1)));%find the closest onset/offset.
    [~,time2]=min(abs(pitchTime-portamentos(i,2)));
    if sum(pitch(time1:time2)==0)>0
        msgbox('Bad portamento imported, no silence can be located in portamento areas.');
        return
    end
end
%portamentosDetail = getPassages(pitchTime,pitch,data.PortamentoTrack{p},0);%clipping
%Export module Midi construction
%Temporal note modification for ACP v2
% for i=1:size(portamentos,1)
%     if note_tmp(i)+2<=length(NoteOnset)
%         NoteDuration(note_tmp(i))=min(NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i)),NoteOnset(note_tmp(i)+2));
%     else
%         NoteDuration(note_tmp(i))=NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i));
%     end
% end
%note
midi.notes=[NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
%Add notes for portamento
sf1=notename(data.channelEdit{p,1}.String);
sf2=notename(data.channelEdit{p,3}.String);
if ~strcmp(protocol.midimode,'default')
    sf1{1}=sf1{1}+12;
    sf2{1}=sf2{1}+12;
end
% for i=1:size(portamentos,1)
% midi.notes=[midi.notes;NoteOnset(note_tmp(i))*data.beats_per_second,NoteDuration(note_tmp(i))*data.beats_per_second,1,sf2{1},protocol.resolution,NoteOnset(note_tmp(i)),NoteDuration(note_tmp(i))];
% end
[tmp,midi.notes]=slidenoteAdd(midi.notes,portamentos,data.beats_per_second,sf1{1},sf2{1},pitch,pitchTime);
%[midi.notes;tmp];
%midi.bend=CC(portamentosDetail,'portamento');
%String forcing+default velocity for all external note protocol.resolution.
if ~isempty(protocol.string_force)
sf=notename(protocol.string_force{p});%String forcing for each note.
if ~strcmp(protocol.midimode,'default')
    sf{1}=sf{1}+12;
end
midi.notes=[midi.notes;tmp;NoteOnset(1)*data.beats_per_second,NoteDuration(1)*data.beats_per_second,1,sf{1},protocol.resolution,NoteOnset(1),NoteDuration(1)];
end
isp_midiwrite(midi,[savedPathName,savedFileName]);
end
end
