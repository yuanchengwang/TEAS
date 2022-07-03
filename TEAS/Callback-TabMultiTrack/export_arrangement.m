function midi=export_arrangement(p,notes)
%playing technique only
global data;
global protocol;
NoteOnset=notes(:,1);
NoteDuration=notes(:,2);
avgPitch=notes(:,3);
%fret=notes(:,4);
velocity=notes(:,5);
midi.notes=[];
%defense code for pitch 
if isfield(data,'PitchTrack')
    if ~isempty(data.PitchTrack{p})
       pitch=data.PitchTrack{p};
       pitchTime=data.PitchTimeTrack{p};
       pitch_valid=1;
    end
end
    
%vibrato
if pitch_valid==1
if isfield(data,'VibratoTrack') && data.CB.Vibrato{p}.Value
    if p<=length(data.VibratoTrack)
    if ~isempty(data.VibratoTrack{p})
        vibratosDetail = getPassages(pitchTime,pitch,data.VibratoTrack{p},0);
        midi.bend=CC(vibratosDetail,'vibrato');
    end
    end
end

if isfield(data,'PortamentoTrack') && data.CB.Portamento{p}.Value
    if p<=length(data.PortamentoTrack)       
        if ~isempty(data.PortamentoTrack{p})
            portamentos=data.PortamentoTrack{p};
            note_tmp=[];
            if size(notes,1)>1%in middle
                for i=1:size(portamentos,1)
                    for j=1:size(notes,1)-1
                        if (portamentos(i,1)>notes(j,1)&& portamentos(i,1)<round(sum(notes(j,1:2)),4))
                            note_tmp=[note_tmp,j];
                            break
                        end
                    end
                end
            end
            for i=1:size(portamentos,1)
            if note_tmp(i)+2<=length(NoteOnset)
                NoteDuration(note_tmp(i))=min(NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i)),NoteOnset(note_tmp(i)+2));
            else
                NoteDuration(note_tmp(i))=NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i));
            end
            end
            sf2=notename(protocol.slide);
            %if ~strcmp(protocol.midimode,'default')
                sf2{1}=sf2{1}+12;
            %end
            for i=1:size(portamentos,1)%add portamento keys
                midi.notes=[midi.notes;NoteOnset(note_tmp(i))*data.beats_per_second,NoteDuration(note_tmp(i))*data.beats_per_second,1,sf2{1},protocol.resolution,NoteOnset(note_tmp(i)),NoteDuration(note_tmp(i))];
            end
        end
    end
end
end

%Tremolo
if isfield(data,'TremoloTrack') && data.CB.Tremolo{p}.Value
    if p<=length(data.TremoloTrack)
        if ~isempty(data.TremoloTrack{p})
            tremolos=data.TremoloTrack{p};
            sf_tremolo=notename(protocol.tremolo);
            sf_note=notename(protocol.note);
            if ~strcmp(protocol.midimode,'default')
                sf_tremolo{1}=sf_tremolo{1}+12;
                sf_note{1}=sf_note{1}+12;
            end
            flag=zeros(size(notes,1),1);%note or tremolo
            for i=1:size(notes,1)%nb of notes
            match=notes(i,1)-tremolos(:,1)==0;
            if sum(match)==1
                flag(i)=sf_tremolo{1};%onset match
            else
                flag(i)=sf_note{1};%onset match
            end
            end
            midi.notes=[midi.notes;NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),flag,protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
        end
    end
end
%No strumming for separated track
%notes(After portamento processing+String forcing)
midi.notes=[midi.notes;NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
if ~isempty(protocol.string_force{p})%String forcing for each note.
    sf=notename(protocol.string_force{p});
    %if ~strcmp(protocol.midimode,'default')
        sf{1}=sf{1}+12;
        midi.notes=[midi.notes;NoteOnset*data.beats_per_second,NoteDuration*data.beats_per_second,ones(size(NoteDuration)),sf{1}*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
    %end
end
end
%end