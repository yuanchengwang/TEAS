function [NoteOnset,NoteDuration]=auto_alignment(NoteOnset,NoteDuration,onset,offset,Tau)
%AUTO_ALIGNMENT Align between edges and imported notes 
%IndexToTime for Edge(Edge is not the target to change)
global data;
onset=onset*data.hop_length/data.fs;
offset=offset*data.hop_length/data.fs;
% Viz, we don't use the DTW
%figure;dtw(onset,NoteOnset);
%Deal with the first note in front of the first onset  
    if NoteOnset(1)+NoteDuration(1)<=Tau+onset(1) %The true offset is in front of the first detected offset.
        onset=[NoteOnset(1),onset];
        [~,k]=min(abs(NoteOnset+NoteDuration-(onset(2)-data.hop_length/data.fs)));%Nb_note*Nb_edge,double for offset
        offset=[min(NoteOnset(k)+NoteDuration(k),onset(2)-data.hop_length/data.fs),offset]; 
    end%keep the notes before the first onset
    [onset_diff,onset2align]=min(abs(NoteOnset-onset),[],2);%Nb_note*Nb_edge
    [offset_diff,offset2align]=min(abs(NoteOnset+NoteDuration-offset),[],2);%Nb_note*Nb_edge,double for offset
    onset_index=unique(onset2align);
    offset_index=unique(offset2align);
    %align the closest one to the edge
    if data.onset_align_valid
    for i=1:length(onset_index)
        temp=onset2align==onset_index(i);
        n=find(temp,1,'first');
        [~,min_temp]=min(onset_diff(temp));
        NoteOnset(n+min_temp-1)=onset(onset_index(i));
    end
    end
    if data.offset_align_valid
        for i=1:length(offset_index)
            temp=offset2align==offset_index(i);
            n=find(temp,1,'first');
            [~,min_temp]=min(offset_diff(temp));
            if offset(offset_index(i))-NoteOnset(n+min_temp-1)>0
                NoteDuration(n+min_temp-1)=min(offset(offset_index(i))-NoteOnset(n+min_temp-1),NoteDuration(n+min_temp-1));
            end
        end
    end
end
