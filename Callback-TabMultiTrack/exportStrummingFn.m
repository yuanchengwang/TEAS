function exportStrummingFn(hObject,eventData)
%EXPORTSTRUMMINGFN export note and strumming for pth track.
global data;
global protocol;
currentname=data.subgroup.SelectedTab.Title;
%p=str2num(currentname(isstrprop(currentname,'digit'))); 
savedFileName=data.filenamedefault;
savedFileName = [savedFileName,'_strumming'];%global feature, no track to choose
savedFileType = {'*.mid','MIDI file (*.mid)'};

%let user specify the path using modal dialog box
[savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
%Defense code, note, strumming for corresponding track must exist. Note and
%strumming are in mutual exclusion.
if isnumeric(savedFileName) == 0
if isfield(data,'StrummingTrack')
    strummings=data.StrummingTrack;
else
    msgbox('No strumming imported.');
    return
end

if isfield(data,'NoteTrack')
    if length(data.NoteTrack)~=data.track_nb
        ansOnset = questdlg('Warning: Track is not enough, fill the rest with empty track?','Attention','Yes','No','No');
        if strcmp(ansOnset,'No')
            return
        else
            data.NoteTrack{length(data.NoteTrack)+1:data.track_nb}=[];
        end
    end
else
    msgbox('No note imported.');
    return
end
NoteOnset=[];
NoteDuration=[];
velocity=[];
avgPitch=[];
%L=[];string=[];
for i=1:data.track_nb
    notes=data.NoteTrack{i};
    NoteOnset=[NoteOnset;notes(:,1)];
    NoteDuration=[NoteDuration;notes(:,2)];
    avgPitch=[avgPitch;notes(:,3)];
%     string=[string;i*ones(size(notes(:,1)))];
    velocity=[velocity;notes(:,5)];
%     L=[L;length(notes(:,1))];
end

% Get strum and remove notes corresponds
pos_global=zeros(length(NoteOnset),1);
for i=1:size(strummings,1)
    %if data.strumPara{i,end}~=1%not a multiple pluck
        pos=(NoteOnset>=strummings(i,1)).*(NoteOnset<=strummings(i,2));
        if sum(pos)<=1
            msgbox('Bad strumming imported/detected, no pluck or a single pluck found in strumming areas.');
            return
        else
            pos_global=pos_global+pos;
%             NoteOnset(pos)=[];
%             string(pos)=[];
%             velocity_new(i)=mean(velocity(pos));
%             NoteDuration_new(i)=max(NoteDuration(pos));
%             velocity(pos)=[];
%             NoteDuration(pos)=[];
        end
    %end
end
NoteOnset=NoteOnset(logical(pos_global));
NoteDuration=NoteDuration(logical(pos_global));
velocity=velocity(logical(pos_global));
avgPitch=avgPitch(logical(pos_global));
% Silence cannot be located in strumming area and Add pitch-range for strumming
% for i=1:size(strummings,1)
%     [~,time1]=min(abs(pitchTime-strummings(i,1)));%find the closest onset/offset.
%     [~,time2]=min(abs(pitchTime-strummings(i,2)));
%     if sum(pitch(time1:time2)==0)>0
%         msgbox('Bad strumming imported, no silence can be located in strumming areas.');
%         return
%     end
% end
%strummingsDetail = getPassages(pitchTime,pitch,data.strummingTrack{p},0);%clipping
%Export module Midi construction
%Temporal note modification for ACP v2
% for i=1:size(strummings,1)
%     if note_tmp(i)+2<=length(NoteOnset)
%         NoteDuration(note_tmp(i))=min(NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i)),NoteOnset(note_tmp(i)+2));
%     else
%         NoteDuration(note_tmp(i))=NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i));
%     end
% end
%note, only the note within strumming areas exported
midi.notes=[NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
% if ~isempty(protocol.string_force)%no need to get the 
%     sf=notename(protocol.string_force{p});%String forcing for each note.
%     if ~strcmp(protocol.midimode,'default')
%         sf{1}=sf{1}+12;
%     end
%     midi.notes=[midi.notes;NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),sf{1}*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
% %String forcing+default velocity for all external note protocol.resolution.
% end
%Add notes for strumming
sf2=notename(protocol.strumming);
if ~strcmp(protocol.midimode,'default')
    sf2{1}=sf2{1}+12;
end
%for i=1:size(strummings,1)
if ~isempty(sf2)
%midi.notes=[midi.notes;NoteOnset(note_tmp(i))*data.beats_per_second,NoteDuration(note_tmp(i))*data.beats_per_second,1,sf2{1},protocol.resolution*ones(size(NoteDuration)),NoteOnset(note_tmp(i)),NoteDuration(note_tmp(i))];
midi.notes=[midi.notes;NoteOnset(1)*data.beats_per_second,NoteDuration(1)*data.beats_per_second,1,sf2{1},protocol.resolution,NoteOnset(1),NoteDuration(1)];
end
%midi.bend=CC(strummingsDetail,'strumming');
isp_midiwrite(midi,[savedPathName,savedFileName]);
%export the pchords file corresponding to the midi. for preset chord mode,
%support in the future.s
% path_chord=[savedPathName,savedFileName];
% path_chord=[path_chord(1:end-3),'pchords'];
% chord_xml(path_chord,chord);
end
end
