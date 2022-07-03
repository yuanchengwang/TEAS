function note_PT=PTnoteAdd(note,PT,bps,key_note,key_PT,type)
%tremolo/vibrato intra-note technique key_PT adding, specific for Ample China Pipa only
%tremolo, only need a PT change, some vibrato for some synthesizers requires a range.
%type=='range', 'note';range within a note, note level method.
%global protocol;
% sf2=notename(key_note);
% if ~strcmp(protocol.midimode,'default')
%     sf2{1}=sf2{1}+12;
% end
if strcmp(type,'range')%only depends on the PT interval.[onset(beats),duration(beats),channel,pitch,velocity(64,1-127),onsets,duration]
    %input vibratoTrack{i}，no key alters.
    note_PT=[PT(:,1)*bps,PT(:,3)*bps,ones(size(PT,1),1),key_PT*ones(size(PT,1),1),64*ones(size(PT,1),1),PT(:,1),PT(:,3)];
else%type='note'
    index=zeros(size(note,1),1);
    for i=1:size(PT,1)
        index=index+(note(:,end-1)==PT(i,1));% & (note(:,end)+note(:,end-1))<=PT(i,1)detect the technique in 
    end
    if sum(index>1)>0%notice2.3754    0.7116 
        disp('Warning: Multiple articulations for a single note.');
    end
    index=index>0;
    index_diff=[0;diff(index)];%only the change needs key_PT.
    nb=sum(abs(index_diff));
    if index(1)==1%init
        note_PT=[note(1,1),note(1,2),1,key_PT,64,note(1,end-1),note(1,end)];
    else
        note_PT=[note(1,1),note(1,2),1,key_note,64,note(1,end-1),note(1,end)];
    end
    if nb~=0%key change exists
        note_pt=find(index_diff>0);
        pt_note=find(index_diff<0);
        if ~isempty(note_pt)
            for i=1:length(note_pt)%add pt
                note_PT=[note_PT;note(note_pt(i),1),note(note_pt(i),2),1,key_PT,64,note(note_pt(i),end-1),note(note_pt(i),end)];
            end
        end
        if ~isempty(pt_note)
            for i=1:length(pt_note)%add note
                note_PT=[note_PT;note(pt_note(i),1),note(pt_note(i),2),1,key_note,64,note(pt_note(i),end-1),note(pt_note(i),end)];
            end
        end
    end
end
end