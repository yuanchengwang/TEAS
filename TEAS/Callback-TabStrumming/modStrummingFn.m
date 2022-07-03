function modStrummingFn(hObject,eventData)
%MODSTRUMMINGFN change the interval for selected strumming
global data;
if isfield(data,'strummings')
    strum =  split(get(data.StrumXEdit,'String'),{'-','+'});
    modStrumStart = str2num(strum{1});
    modStrumEnd = str2num(strum{2});
    if length(strum)==3
        velocity=str2num(strum{3});
    end
    %check the partialy overlapping with exising notes
        for i = 1:length(data.strummings)
           if (modStrumStart >= data.strummings(i,1) && modStrumStart <= data.strummings(i,2)) ||...
                   (modStrumEnd >= data.strummings(i,1) && modStrumEnd <= data.strummings(i,2))
               if i~=data.numStrummingSelected
                   uiwait(msgbox('The new strumming is overlapping exisiting strums!','Warning!','Error'));
                   return;
               end
           end
        end

        %check whether it is out of the scope of the recording
        if (modStrumStart > data.axeTabStrumming.XLim(2)) || ...
                (modStrumEnd < data.axeTabStrumming.XLim(1))
            uiwait(msgbox('The new note must be within the recording!','Warning!','Error'));
            return
        end
        
        %check whether the new added note is an area
        if modStrumStart >= modStrumEnd
            uiwait(msgbox('The new note should be an area!','Warning!','Error'));
            return
        end
        %Parameter update, tight up the strum area in the selected area.
        pos=logical((modStrumStart<=data.all_onsets).*(modStrumEnd>=data.all_onsets));
        if sum(pos)<2
            msgbox('Onset not enough.');
            return
        end
        [strum_new,order]=sort(data.all_onsets(pos));
        %Check whether there is the change!
        match_strum=strum_new==[strum_new(1),strum_new(end)];
        if sum(match_strum)==2
            if size(data.strummings,2)==4
                data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
            else
                data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
            end%recover the old value.
            uiwait(msgbox('No Change for strum!','Warning!','Error'));
            return;
        end
        %if strum changes
        string_new=data.all_strings(pos);
        string_new=string_new(order);
        if length(string_new)~=length(unique(string_new))
            msgbox('Repeated strings selected');
            return
        end
        data.strummings(data.numStrummingSelected,1)=strum_new(1);
        data.strummings(data.numStrummingSelected,2)=strum_new(end);
        data.strummings(data.numStrummingSelected,3)=strum_new(end)-strum_new(1);
        
        velocity=[];
        if isfield(data,'strums_velocity')
            velocity=data.strums_velocity(pos);%order is not important here.
            velocity=velocity(order);
            velocity=round(mean(velocity));
            data.strummings(data.numStrummingSelected,4)=velocity; 
        end
            
        if isfield(data,'patchStrummingArea')
            %if there are already some strumming
            delete(data.patchStrummingArea);
        end
        data.patchStrummingArea =  plotFeaturesArea(data.strummings,data.axeTabStrumming);
        plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,1);
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
        range=data.strummings(data.numStrummingSelected,:);
        onset_tracks=cell(1,4);
        min_value=zeros(1,4);
        for i=1:data.track_nb
            temp=data.onset_tracks{i};
            onset_tracks{i}=temp(logical((temp>=range(1)).*(temp<=range(2))));
            min_value(i)=min(onset_tracks{i});
        end
        if data.StrumXaxisPara.Value==2
            min_value=min(min_value);
            for i=1:data.track_nb
                onset_tracks{i}=onset_tracks{i}-min_value;
            end
        end
        if isfield(data,'patchFeaturesTrackOnsetsIndi')
            delete(data.patchFeaturesTrackOnsetsIndi);
            delete(data.patchFeaturesAreaOnsetsIndi);
        end
        data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
        data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);
        if size(data.strummings,2)==4
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
        else
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
        end
        %show the first individual strum statistics
        strum_cell{1}=strum_new;
        string_cell{1}=string_new;
        data.strumPara(data.numStrummingSelected,:)=strumParaDetection(strum_cell,string_cell);
        plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
        data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end};
end
end