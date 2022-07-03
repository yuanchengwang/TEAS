function globalexport(hObject,eventData)
global data;
global protocol;
savedFileName=data.filenamedefault;
file=dir('temp_multichannel/*.wav');
if ~isempty(file)
savedFileName=file.name;
savedFileName=savedFileName(1:end-9);
end
savedFileName = [savedFileName,'_selected_annotation'];
savedFileType = {'*.mat','MATLAB class file (*.mat)';'*.mid','MIDI file (*.mid)';};
[savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);

if isnumeric(savedFileName) == 0
if contains(savedFileName,'.mid')%export a mid file
if protocol.valid==0
    %protocol.string_force=num2cell(1:data.track_nb);%for channel
    protocol.vibrato=data.channelEdit{1,2}.String;
    protocol.slide=data.channelEdit{1,3}.String;%vel127-63,63-1 speed
    protocol.pull=data.channelEdit{1,3}.String;%vel127-63,63-1 speed
    protocol.push=data.channelEdit{1,3}.String;
    protocol.tremolo=data.channelEdit{1,4}.String;
end

if isfield(data,'NoteTrack')
    if length(data.NoteTrack)~=data.track_nb
        ansOnset = questdlg('Warning: Track is not enough, fill the rest with empty track(s)?','Attention','Yes','No','No');
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
if ~isfield(data,'bps_poly')%bps
    if isfield(data,'denoisedWaveTrack')
        if length(data.denoisedWaveTrack)==data.track_nb+1
            if ~isempty(data.denoisedWaveTrack{data.track_nb+1})
                win=hann(data.win_length/2,'periodic');
                data.log_energy_spec_poly=spectrogram(data.denoisedWaveTrack{data.track_nb+1},win,round(data.win_length/2-data.hop_length),data.win_length/2,data.fs);
                spec= 10 * log10(max(1e-10,abs(data.log_energy_spec_poly(106:end,:))));%power2db,replace the spec
                spec=max(spec,max(max(spec))-80);
                energy=sum(spec);
                energy=energy-min(energy);
                data.log_energy_poly=energy/max(energy);
                data.bps_poly=tempo_estimation(data.log_energy_poly,protocol.resolution*data.beats_per_second);
                bps=data.bps_poly;
                flag=0;
                else
            if isfield(data,'bps')
                msgbox('Warning: No polyphonic channel imported, bps replaced by existent BPS');
                bps=data.bps;
                flag=1;
            else
                if isfield(data,'onset_env')
                    msgbox('Warning: No polyphonic channel imported, replaced by existent BPS');
                    data.bps=tempo_estimation(data.onset_env,protocol.resolution*data.beats_per_second);
                    bps=data.bps;
                    flag=1;
                else
                    msgbox('Warning: No onset envelope.');
                    return
                end
            end
            end
        else
            if isfield(data,'bps')
                msgbox('Warning: No polyphonic channel imported, bps replaced by existent BPS');
                bps=data.bps;
                flag=1;
            else
                if isfield(data,'onset_env')
                    msgbox('Warning: No polyphonic channel imported, replaced by existent BPS');
                    data.bps=tempo_estimation(data.onset_env,protocol.resolution*data.beats_per_second);
                    bps=data.bps;
                    flag=1;
                else
                    msgbox('Warning: No onset envelope.');
                    return
                end
            end
        end
    else
        msgbox('Warning: No Audio input.The BPS will be set as default.The MIDI based method will be supported in the future.');
        bps=data.beats_per_second;
        flag=0;
    end
else
    msgbox('Warning: No Audio input.The BPS will be set as default.');
    bps=data.bps_poly;
    flag=0;
end
ansOnset = questdlg(['Warning: Accept the estimated tempo=',num2str(bps),'? If not please set data.beat_per_second for an initial tempo.'],'Attention','Yes','No','No');
switch ansOnset
case 'Yes'
case 'No'
    if flag
        data=rmfield(data,'bps');
    else
        data=rmfield(data,'bps_poly');
    end
    return
end
if data.ChangeOutputMode.Value==1%all track notes
midi.notes=[];
% if ~isempty(protocol.note) && ~strcmp(protocol.midimode,'default')%add a normal pluck
%     midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),notename(protocol.note)*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
% end
for i=1:data.track_nb%in a single MIDI file
    %Note export%must export, we don't care about the other factor
    notes=data.NoteTrack{i};
    NoteOnset=notes(:,1);
    NoteDuration=notes(:,2);
    avgPitch=notes(:,3);
    %fret=notes(:,4);
    velocity=notes(:,5);%protocol.string_force{i}*
    midi.notes=[midi.notes;NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
end
isp_midiwrite(midi,[savedPathName,savedFileName]);
elseif data.ChangeOutputMode.Value==2 %Separated Track with Notes+Techniques

for i=1:data.track_nb%single track MIDI file
    %Note export%must export, we don't care about the other factor
    midi.notes=[];
    sf_note=notename(data.channelEdit{i,1}.String);
    if ~strcmp(protocol.midimode,'default')
        sf_note{1}=sf_note{1}+12;
    end
%     if ~isempty(protocol.note) && ~strcmp(protocol.midimode,'default')%no need to select the note option, notes must be exported!
%         midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),notename(protocol.note)*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
%     end
    notes=data.NoteTrack{i};
    NoteOnset=notes(:,1);
    NoteDuration=notes(:,2);
    avgPitch=notes(:,3);
    %fret=notes(:,4);
    velocity=notes(:,5);%protocol.string_force{i}*
    midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
    tmp=cell(3,1);
    % Save the selected non-strum techniques
    %midi.bend=[];
    if isfield(data,'PortamentoTrack') && ~isempty(protocol.slide) && data.CB.Portamento{i}.Value 
        if i<=length(data.PortamentoTrack) && ~strncmp(protocol.slide,'CC',2) && ~strncmp(protocol.slide,'PB',2)
            if i<=length(data.PitchTrack) && isfield(data,'PitchTimeTrack')
                sf_sliding=notename(data.channelEdit{i,3}.String);
                if ~strcmp(protocol.midimode,'default')
                    sf_sliding{1}=sf_sliding{1}+12;
                end
                [tmp{2},midi.notes]=slidenoteAdd(midi.notes,data.PortamentoTrack{i},bps,sf_note{1},sf_sliding{1},data.PitchTrack{i},data.PitchTimeTrack{i});%the empty doesn't matter.
            else
                msgbox('Sliding are not fully imported for selected option. Continuous Controller(CC) is not temporally supported on Sliding.');
                return
            end
        else
            msgbox('Sliding are not fully imported for selected option. Continuous Controller(CC) is not temporally supported on Sliding.');
            return
        end
    end
    if isfield(data,'VibratoTrack') && ~isempty(protocol.vibrato) && data.CB.Vibrato{i}.Value
        if i<=length(data.VibratoTrack) 
            if strncmp(data.channelEdit{i,2}.String,'PB',2) && isfield(data,'PitchTimeTrack')%pitch truncation based CC pitchbend simulation 
                vibratosDetail = getPassages(data.PitchTimeTrack{i},data.PitchTrack{i},data.VibratoTrack{i},0);
                midi.bend=pitch_bend(vibratosDetail,bps);
            elseif strncmp(data.channelEdit{i,2}.String,'CC',2) && isfield(data,'PitchTimeTrack')
                vibratosDetail = getPassages(data.PitchTimeTrack{i},data.PitchTrack{i},data.VibratoTrack{i},0);
                midi.controller=CC(vibratosDetail,bps,str2num(data.channelEdit{i,2}.String(3:end)),protocol.vibrato_CC_range);       
            else
                sf_vibrato=notename(data.channelEdit{i,2}.String);
                if ~strcmp(protocol.midimode,'default')
                    sf_vibrato{1}=sf_vibrato{1}+12;
                end
                tmp{1}=PTnoteAdd(midi.notes,data.VibratoTrack{i},bps,sf_note{1},sf_vibrato{1},protocol.vibrato_type);
            end
%             else
%                 msgbox('No selected vibrato track input or corresponding pitch curve not imported.');
%                 return
        end
    end
    if isfield(data,'TremoloTrack') && ~isempty(protocol.tremolo) && data.CB.Tremolo{i}.Value 
        if i<=length(data.TremoloTrack) && ~strncmp(protocol.tremolo,'CC',2) && ~strncmp(protocol.tremolo,'PB',2)
            sf_tremolo=notename(data.channelEdit{i,4}.String);
            if ~strcmp(protocol.midimode,'default')
                sf_tremolo{1}=sf_tremolo{1}+12;  
            end
            tmp{3}=PTnoteAdd(midi.notes,data.TremoloTrack{i},data.beats_per_second,sf_note{1},sf_tremolo{1},'note');
        end
    end
    midi.notes=[midi.notes;merge_PT(tmp,sf_note{1})];
    %String forcing for each note
    if ~isempty(protocol.string_force{i})
        sf=notename(protocol.string_force{i});
        if ~strcmp(protocol.midimode,'default')
            sf{1}=sf{1}+12;
        end
        midi.notes=[midi.notes;NoteOnset(1)*bps,NoteDuration(1)*bps,1,sf{1},protocol.resolution,NoteOnset(1),NoteDuration(1)];
    end
    isp_midiwrite(midi,[savedPathName,savedFileName(1:end-4),'_track',num2str(i),'.mid']);
end
%elseif data.ChangeOutputMode.Value==3%output the strumming
%midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];        
    %if isfield(data,'StrummingTrack')
%         NoteOnset=[];
%         string=[];
%         velocity=[];
%         L=[];
%         for i=1:data.track_nb
%             notes=data.NoteTrack{i};
%             NoteOnset=[NoteOnset;notes(:,1)];
%             string=[string;i*ones(size(notes(:,1)))];
%             velocity=[velocity;notes(:,5)];
%             L=[L;length(notes(:,1))];
%         end
%         strummings=data.StrummingTrack;
        %Temporal note modification for ACP v2
%         for i=1:size(strummings,1)
%             if note_tmp(i)+2<=length(NoteOnset)
%                 NoteDuration(note_tmp(i))=min(NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i)),NoteOnset(note_tmp(i)+2));
%             else
%                 NoteDuration(note_tmp(i))=NoteOnset(note_tmp(i)+1)+NoteDuration(note_tmp(i)+1)-NoteOnset(note_tmp(i));
%             end
%         end
        %note without string forcing
%        midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
%         if ~isempty(protocol.string_force)
%         sf=notename(protocol.string_force{p});%String forcing for each note.
%         if ~strcmp(protocol.midimode,'default')
%             sf{1}=sf{1}+12;
%         end
%         midi.notes=[midi.notes;NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),sf{1}*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
%         end
        
%         path_chord=[savedPathName,savedFileName];
%         path_chord=[path_chord(1:end-3),'pchords'];
%        chord_xml(path_chord,chord);
%     else
%         msgbox('No strumming imported');
%         return
%    end
else% separated PT(nonsense without carrier notes)=>MPE
    msgbox('MIDI Polyphonic Expression (MPE) will be supported in the future. Please change the MIDI export mode.');
%     for i=1:data.track_nb
%         %Init export the selected playing techniques
%         notes=data.NoteTrack{i};
%         midi=export_arrangement(i,notes);
%         isp_midiwrite(midi,[savedPathName,savedFileName(1:end-4),'_str',num2str(i),'.mid']);
%     end
end
else %export .mat file
    data_temp=export_data_arrangement;%
    save([savedPathName,savedFileName],'data_temp');
end
end
end