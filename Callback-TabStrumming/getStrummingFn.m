function getStrummingFn(hObject,eventData)
%GETSTRUMMINGFN get strumming using preset rules
%Notice: onsets(attacks) are not equivalent to the note begining, sliding
%issues！choose onset only!onset prior!
global data;
EdgeTrackTest;
criteria=data.criteria_strum*data.hop_length/data.fs;
strums=[];
strumsDetail=[];
strums_index=[];
flag=0;
%%%%%%%Candidate strumming types(including the simulateneous plucks)%%%%%%%%%
all_onsets=[];
string=[];
%velocity=[];
for i=1:data.track_nb
all_onsets=[all_onsets;data.onset_tracks{i}];
string=[string;i*ones(size(data.onset_tracks{i}))];
% if isfield(data,'velocity_track')
% velocity=[velocity;data.velocity_track{i}];
% end
end
data.all_onsets=all_onsets;
data.all_strings=string;
% if ~isempty(velocity)
% data.strums_velocity=velocity;
% end
total_num_onsets=length(all_onsets);%total num of plucks
[all_onsets,order]=sort(all_onsets);
string=string(order);
% if ~isempty(velocity)
% velocity=velocity(order);
% end
j=1;a=0;
for i=1:total_num_onsets-1
    if all_onsets(i+1)-all_onsets(i)<=criteria && string(i+1)~=string(i) % Extract the close onsets from different string
        if  a==0%the start
            strums{j}=[all_onsets(i),all_onsets(i+1)];
            strumsDetail{j}=[string(i),string(i+1)];
            %strums_index{j}=i;
%             if ~isempty(velocity)
%                 strums_velocity{j}=velocity(i);
%             end
            a=1;
%             flag=[flag,2];
        else%a==1
            if sum(string(i+1)==strumsDetail{j})==0%no overlap,orderly????
%             tmp=strumsDetail{j};
%             if length(tmp)>1%continue
                strums{j}=[strums{j},all_onsets(i+1)];
                strumsDetail{j}=[strumsDetail{j},string(i+1)];
                %strums_index{j}=[strums_index{j},i];
%                 if ~isempty(velocity)
%                     strums_velocity{j}=[strums_velocity{j},velocity(i)];
%                 end
                %flag(end)=flag(end)+1;
%             end
            else%if sum(string(i+1)==strumsDetail{j})>0%The end
                %strums{j}=[strums{j},onset(i-1)];
%                 strums{j}=[strums{j},all_onsets(i+1)];
%                 strumsDetail{j}=[strumsDetail{j},string(i+1)];
                %strums_index{j}=[strums_index{j},i];
%                 if ~isempty(velocity)
%                     strums_velocity{j}=[strums_velocity{j},velocity(i)];
%                 end
%                 flag(end)=flag(end)+1;
                j=j+1;
                a=0;
            %else
            end
        end
    else%interval is too big or string(i+1)==string(i)
%         flag=[flag,0];      
%         if a==1%The end
%             strums{j}=[strums{j},all_onsets(i)];
%             strumsDetail{j}=[strumsDetail{j},string(i)];                    
%             a=0;
%         end
        a=0;
        j=j+1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[strums,strumsDetail,strums_index]=strum_split(strums,strumsDetail,strums_index);
data.strummings=zeros(length(strums),2);%Range for each strum %only start and end for output
flag=ones(length(strums),1);
for i=1:length(strums)
   if length(strums{i})>2%Remove the empty strum or 2 elements(at least two)
      data.strummings(i,:)=[strums{i}(1),strums{i}(end)]; 
      flag(i)=0;
   end
end
data.strummings(logical(flag),:)=[];
strums(logical(flag))=[];
strumsDetail(logical(flag))=[];
%strum_index(logical(flag))=[];
data.strummings(:,3)=data.strummings(:,2)-data.strummings(:,1);
% if ~isempty(velocity)
%     for i=1:size(data.strummings,1)
%         data.strummings(i,4)=round(mean(strums_velocity{i}));
%     end
% end
%data.strums_index=strums_index;
%Parameter 
data.strumsDetail=strumsDetail;%string
data.strumPara=strumParaDetection(strums,strumsDetail);
data.strummings(:,4)=cell2mat(data.strumPara(:,4));
%plotting
if isfield(data,'patchStrummingArea')
delete(data.patchStrummingArea);
end
data.patchStrummingArea=plotFeaturesArea(data.strummings,data.axeTabStrumming);

%highlight the first strum
data.numStrummingSelected = 1;
plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,0);

%plot the strum num in the listbox
plotFeatureNum(data.strummings,data.StrummingListBox);

%show the first vibrato in strum listbox
data.strumListBox.Value = data.numStrummingSelected;

%show individual strum in the sub axes
if isfield(data,'polyStrumAudio')
    time=(0:size(data.polyStrumAudio,1)-1)'/data.fs;
    pos=data.strummings(data.numStrummingSelected,1:2)+[-0.1,0.5];
    [~,time1]=min(abs(pos(1)-time));
    [~,time2]=min(abs(pos(2)-time));
    if isfield(data,'plotStrumAudio')
        delete(data.plotStrumAudio);
    end
    hold on;
    data.plotStrumAudio=plotAudio(time(time1:time2),data.polyStrumAudio(time1:time2),data.axeTabStrummingIndi,'Selected Strum',1);
    hold off;
end

%show the first strum's X(time) range in the edit text
if size(data.strummings,2)==4
    data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
else
    data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
end
range=data.strummings(data.numStrummingSelected,:);
onset_tracks=cell(1,4);
for i=1:data.track_nb
    temp=data.onset_tracks{i};
    onset_tracks{i}=temp(logical((temp>=range(1)).*(temp<=range(2))));
end
if data.StrumXaxisPara.Value==2
    for i=1:data.track_nb
        onset_tracks{i}=onset_tracks{i}-range(1);
    end
    range=range-range(1);
end
if isfield(data,'patchFeaturesTrackOnsetsIndi')
    delete(data.patchFeaturesTrackOnsetsIndi);
    delete(data.patchFeaturesAreaOnsetsIndi);
end
data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);

%show the first individual strum statistics
plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end};
end