function EdgeTrackTest
%EDGETRACKTEST Test the edge track for each string
global data;
%input pitch curve
if isfield(data,'TrackXaxisType')
    priorty=data.TrackXaxisType;%1=selected notes,2=imported;
else
    if isfield(data,'TrackXaxisPara')
        priorty=data.TrackXaxisPara.Value;
    end
end

for i=1:data.track_nb
   if priorty==1 && data.selectedtrack==i
       if isfield(data,'onset')
           if data.double_peak
               data.onset_tracks{i}=data.onset(1:2:end)'*data.hop_length/data.fs; 
           else
               data.onset_tracks{i}=data.onset'*data.hop_length/data.fs; 
           end
       else
           if isfield(data,'NoteOnset')
                data.onset_tracks{i}=data.NoteOnset; 
           else
               msgbox('No edge and note for selected track.');
               return
           end
       end
    else
        if isfield(data,'OnsetStr')
            if ~isempty(data.OnsetStr{i})
                data.onset_tracks{i}=data.OnsetStr{i};
            end
        else
            msgbox('One or more of the tracks not imported.');
            return
        end
    end
end
end
