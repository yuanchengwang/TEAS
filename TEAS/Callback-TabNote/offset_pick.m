function [offset,HD_offset_new]=offset_pick(HD_offset,onset,E,pre_max,post_max,pre_avg,post_avg,delta,wait,mode)
%Reference: GuitarSet
% Defense code
assert(nargin==10,'10 augments are required.');

TauB=wait;%wait in peak pick ensures that works
if onset(end)+TauB>length(HD_offset)
   offset_area=floor([onset(1:end-1)+TauB;onset(2:end)]); %no last one,offset num may be one more than onset number,add at the end
else    
    offset_area=floor([onset+TauB;[onset(2:end),length(HD_offset)]]);
end
if mode
    HD_offset_new=HD_offset.*(log(E(1:end-1))-log(E(2:end)))./E(2:end);
else
    HD_offset_new=HD_offset;
end
HD_offset_new=HD_offset_new/max(HD_offset_new);%No Half rectifier
offset=peak_pick(HD_offset_new,pre_max,post_max,pre_avg,post_avg,delta,wait);%All possible offsets

offset(offset<=offset_area(1,1))=[];
for i=1:size(offset_area,2)-1
    offset(logical((offset>offset_area(2,i)).*(offset<=offset_area(1,i+1))))=[];
end

%Select the offsets
for i=1:size(offset_area,2)
   one_part=(offset-offset_area(1,i)>0).*(offset-offset_area(2,i)<0);
   nb_area=sum(one_part);%nb of offset in i^th area
   if nb_area==0%No offset found between two adjacent onsets,add the offset as the point before next onset
       offset=[offset,offset_area(2,i)-1];
   elseif nb_area>1%More than 1 offsets between two adjacent onsets,select the first one.
       ind=find(one_part==1,1,'first');
       one_part(ind)=0;
       offset(logical(one_part))=[];
   end
end
if onset(end)+TauB>length(HD_offset)
    offset=[offset,length(HD_offset)];
end
offset=sort(offset);
end
