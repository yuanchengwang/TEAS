function data_temp=export_data_arrangement
%Return selected annotation
global data;
global data_temp;
if isfield(data,'denoisedWaveTrack')
    for i=1:data.track_nb+1%the track_nb+1 corresponds to the polyphonic audio
        if data.CB.MIDIDenoisedWave{i}.Value 
            if i<=length(data.denoisedWaveTrack)
                data_temp.denoisedWaveTrack{i}=data.denoisedWaveTrack{i};%the empty doesn't matter.
            end
        end
    end
end

if isfield(data,'PitchTrack')
    for i=1:data.track_nb
        if data.CB.Pitch{i}.Value 
            if i<=length(data.PitchTrack)
                data_temp.PitchTrack{i}=data.PitchTrack{i};%the empty doesn't matter.
            end
        end
    end
end
if isfield(data,'PitchTimeTrack')
    for i=1:data.track_nb
        if data.CB.Pitch{i}.Value 
            if i<=length(data.PitchTimeTrack)
                data_temp.PitchTimeTrack{i}=data.PitchTimeTrack{i};%the empty doesn't matter.
            end
        end
    end
end
if isfield(data,'NoteTrack')
    for i=1:data.track_nb
        if data.CB.Note{i}.Value 
            if i<=length(data.NoteTrack)
                data_temp.NoteTrack{i}=data.NoteTrack{i};%the empty doesn't matter.
            end
        end
    end
end

if isfield(data,'VibratoTrack')
    for i=1:data.track_nb
        if data.CB.Vibrato{i}.Value 
            if i<=length(data.VibratoTrack)
                data_temp.VibratoTrack{i}=data.VibratoTrack{i};%the empty doesn't matter.
            end
        end
    end
end

if isfield(data,'PortamentoTrack')
    for i=1:data.track_nb
        if data.CB.Portamento{i}.Value 
            if i<=length(data.PortamentoTrack)
                data_temp.PortamentoTrack{i}=data.PortamentoTrack{i};%the empty doesn't matter.
            end
        end
    end
end

if isfield(data,'TremoloTrack')
    for i=1:data.track_nb
        if data.CB.Tremolo{i}.Value 
            if i<=length(data.TremoloTrack)
                data_temp.TremoloTrack{i}=data.TremoloTrack{i};%the empty doesn't matter.
            end
        end
    end
end

if isfield(data,'StrummingTrack')
    if data.CB.Strumming.Value 
        if i<=length(data.StrummingTrack)
            data_temp.StrummingTrack=data.StrummingTrack;%the empty doesn't matter.
        end
    end
end
end
