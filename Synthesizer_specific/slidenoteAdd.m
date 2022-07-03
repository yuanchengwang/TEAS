function [note_slide,note]=slidenoteAdd(note,slide,bps,key_note,key_slide,pitch,pitchTime)
%reshape the note, specific for Ample China Pipa only
flag=zeros(size(slide,1),1);
single_double=ones(size(slide,1),1);
note_new=[];

for i=1:size(slide,1)%only for single/double note slide detection and note rectification.
    %Inter-note slide judge
    tmp=round(note(:,end-1),4)<=round(slide(i,1),4) & round(note(:,end-1)+note(:,end),4)>=round(slide(i,2),4);
    if sum(tmp)==0%two notes single slide.
        nb=find(round(note(:,end-1),4)<=round(slide(i,1),4) & round(note(:,end-1)+note(:,end),4)>=round(slide(i,1),4));%onset note
        flag(i)=nb;
        single_double(i)=2;
        new_duration=note(nb+1,end)+note(nb+1,end-1)-note(nb,end-1);%prolong the departure note for overlap.
        %update the note duration
        note(nb,end)=new_duration;
        note(nb,2)=new_duration*bps;
    else%Add a destination note for slide
        nb=find(tmp);
        flag(i)=nb;
        %single_double(i)=2;
        %Add a destination note
        pitch_seg=pitch(pitchTime<=slide(i,2) & pitchTime>=slide(i,1));
        note_add=pitchAdd(pitch_seg,MidiToFreq(note(nb,4)));
        velocity=sliderate(slide(i,2)-slide(i,1),abs(note(nb,4)-note_add));%0 for the other synth
        onset=min([slide(i,1)+0.03,slide(i,2)-0.03,note(nb,end-1)+note(nb,end)]);
        note_new=[note_new;onset*bps,(note(nb,end-1)+note(nb,end)-onset)*bps,1,note_add,velocity,onset,note(nb,end-1)+note(nb,end)-onset];%the velocity here is set for by speed, not accuracy, it will be improved in the future
    end
end
%sort the note
[~,order]=sort(note(:,1));
note=note(order,:);
if flag(1)==1%init, if starting with slide
    note_slide=[note(1,1),note(1,2),1,key_slide,64,note(1,end-1),note(1,end)];
else
    note_slide=[note(1,1),note(1,2),1,key_note,64,note(1,end-1),note(1,end)];
end
j=1;
i=1;
while i<=size(note,1)
   if i==1 
       if flag(1)==1
           i=i+single_double(j);
           if j<size(slide,1)
               j=j+1;
           else%tail
               break
           end
           a=1;
       else
           i=i+1;
           a=0;
       end
   else
       if i==flag(j) %多个的音滑但不切换的时候会如何？
           if a==0%alter
               a=1;
               note_slide=[note_slide;note(i,1),note(i,2),1,key_slide,64,note(i,end-1),note(i,end)];
           %else%a=1 pass
               %i=i+single_double(j);
           end
           i=i+single_double(j);
           if j<size(slide,1)
               j=j+1;
           else%tail
               break
           end
       else%长音可以拉到尾巴？代表一个滑音？
           if a==1%alter
               a=0;
               note_slide=[note_slide;note(i,1),note(i,2),1,key_note,64,note(i,end-1),note(i,end)];
           %else%a=1 pass
           end
           i=i+1;
       end
   end    
end
if i~=size(note,1)%add a tail note
    note_slide=[note_slide;note(i,1),note(i,2),1,key_note,64,note(i,end-1),note(i,end)];
end
note=[note;note_new];%if notes added, PT keys not included
end