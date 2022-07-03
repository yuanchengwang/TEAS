function PTfreelist=eliminate_PT(notes,vibratos,portamentos)
%PTFREELIST Remove the playing techniques detected from previous steps
%Note vibrato portamentos format
%note: onset, duration,average pitch, (fret)
%vibratos,poramentos:onset,offset
%get the overlap place
PTfreelist=ones(size(notes,1),1);
%vibrato
if ~isempty(vibratos)
for i=1:size(notes,1)
    for j=1:size(vibratos,1)
        if ~(vibratos(j,1)>=notes(i,1)+notes(i,2) || vibratos(j,2)<=notes(i,1))
            PTfreelist(i)=0;
            break
        end
    end
end
end
%portamento
if ~isempty(portamentos)
for i=1:size(notes,1)
    for j=1:size(portamentos,1)
        if ~(portamentos(j,1)>=notes(i,1)+notes(i,2) || portamentos(j,2)<=notes(i,1))
            PTfreelist(i)=0;
            break
        end
    end
end
end
PTfreelist=logical(PTfreelist);
end