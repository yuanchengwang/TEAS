function exportVibratoFn(hObject,eventData)
%EXPORTVIBRATOFN export note and vibrato for pth track.
global data;
global protocol;
currentname=data.subgroup.SelectedTab.Title;
p=str2num(currentname(isstrprop(currentname,'digit'))); 
savedFileName=data.filenamedefault;
savedFileName = [savedFileName,'_vibrato_str',num2str(p)];
savedFileType = {'*.mid','MIDI file (*.mid)'};

%let user specify the path using modal dialog box
[savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
%Defense code, pitch,note,vibrato for corresponding track must exist.
if isnumeric(savedFileName) == 0
if isfield(data,'VibratoTrack')   
    if p>length(data.VibratoTrack)
        msgbox('No vibrato for this track imported.');
        return
    else
        vibratos=data.VibratoTrack{p};
    end
else
    msgbox('No vibrato for this track imported.');
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

%%vibrato must be within a note.
for i=1:size(vibratos,1)
    if vibratos(i,1)<notes(1,1)
        disp(1);
        msgbox('Bad vibrato imported');
        return
    end
    if vibratos(i,2)>sum(notes(end,1+2))%end
        disp(2);
        msgbox('Bad vibrato imported');
        return
    end
    if size(notes,1)>1%in middle
        for j=1:size(notes,1)-1
            if (vibratos(i,1)<notes(j+1,1)&& vibratos(i,1)>round(sum(notes(j,1:2)),4))||(vibratos(i,2)<notes(j+1,1)&& vibratos(i,2)>round(sum(notes(j,1:2)),4))
                disp(3);
                msgbox('Bad vibrato imported');
                return
            end
        end
    end
end
%Silence cannot be located in vibrato area and Add pitch-range for portamento
for i=1:size(vibratos,1)
    [~,time1]=min(abs(pitchTime-vibratos(i,1)));%find the closest onset/offset.
    [~,time2]=min(abs(pitchTime-vibratos(i,2)));
    if sum(pitch(time1:time2)==0)>0
        msgbox('Bad vibrato imported, no silence can be located in vibrato areas.');
        return
    end
end
vibratosDetail = getPassages(pitchTime,pitch,vibratos,0);%clipping
%Export module Midi construction
%note: temporally output, no accuracy BPS computed!
midi.notes=[NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
%Vibrato using pitch bend
if strncmp(data.channelEdit{p,2}.String,'PB',2)%CC output
    disp(1);
    midi.bend=pitch_bend(vibratosDetail,data.beats_per_second);
elseif strncmp(data.channelEdit{p,2}.String,'CC',2)%key beyond the register, temporally output, no accuracy BPS computed!
    midi.controller=CC(vibratosDetail,data.beats_per_second,str2num(data.channelEdit{p,2}.String(3:end)),protocol.vibrato_CC_range);
else%key beyond the register
    sf1=notename(data.channelEdit{p,1}.String);
    sf2=notename(data.channelEdit{p,2}.String);
    if ~strcmp(protocol.midimode,'default')
        sf1{1}=sf1{1}+12;%note
        sf2{1}=sf2{1}+12;%vibrato
    end
    tmp=PTnoteAdd(midi.notes,vibratos,data.beats_per_second,sf1{1},sf2{1},protocol.vibrato_type);
    midi.notes=[midi.notes;tmp];%no need to sort
end
if ~isempty(protocol.string_force)%String forcing+default velocity for all external note protocol.resolution. 
    sf=notename(protocol.string_force{p});
    if ~strcmp(protocol.midimode,'default')
        sf{1}=sf{1}+12;
    end
    midi.notes=[midi.notes;NoteOnset(1)*data.beats_per_second,NoteDuration(1)*data.beats_per_second,1,sf{1},64,NoteOnset(1),NoteDuration(1)];
end
isp_midiwrite(midi,[savedPathName,savedFileName]);
end
end
