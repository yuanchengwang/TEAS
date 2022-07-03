function note=merge_PT(tmp,sf)
note=[];
for i=1:3
   note=[note;tmp{i}];
end
%The higher key priority

[~,order]=sort(note(:,1));
note=note(order,:);
note_tmp=note;
%The higher key has priority
onset=unique(note(:,1));
for i=1:length(onset)
    list_tmp=note(:,1)==onset(i);
    if sum(list_tmp)>1
        note_tmp=note(list_tmp,4);
        [~,a]=max(note_tmp);
        b=find(list_tmp);
        list_tmp(b(a))=0;
        note(list_tmp,:)=[];
    end
end
end