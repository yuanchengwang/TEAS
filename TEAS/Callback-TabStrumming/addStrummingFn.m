function addStrummingFn(hObject,eventData)
global data;
axe=data.axeTabStrumming;
rect = getrect(axe);%[xmin ymin max(x)-xmin max(y)-ymin]
    
    %----START of pitch point---------------
    if rect(3)==0 || rect(4)==0
        msgbox('Bad area selected');
    else
        if ((axe.XLim(1)<=rect(1)&& rect(1)<=axe.XLim(2)) || (axe.XLim(1)<=rect(1)+rect(3) && rect(1)+rect(3)<=axe.XLim(2))) 
            %test if the area outside the existing strumming areas.
%             velocity=[];
            if ~isfield(data,'all_onsets')||~isfield(data,'all_strings')
                all_onsets=[];
                string=[];
                for i=1:data.track_nb
                    all_onsets=[all_onsets;data.onset_tracks{i}];
                    string=[string;i*ones(size(data.onset_tracks{i}))];
%                     if isfield(data,'velocity_track')
%                         velocity=[velocity;data.velocity_track{i}];
%                         data.strums_velocity=velocity;
%                     end
                end
                data.all_onsets=all_onsets;
                data.all_strings=string;
            end
            
            %Parameter update, tight up the strum area in the selected area.
            pos=logical((rect(1)<=data.all_onsets).*(rect(1) + rect(3)>=data.all_onsets));
            if sum(pos)<2
                msgbox('Onset not enough.');
                return
            end
            [strum_new,order]=sort(data.all_onsets(pos));
            string_new=data.all_strings(pos);
            string_new=string_new(order);
%             data.strums_velocity(pos);
%             velocity=[];
%             if isfield(data,'strums_velocity')
%                 velocity=data.strums_velocity(pos);
%                 velocity=velocity(order);
%                 velocity=round(mean(velocity));
%             end
            if length(string_new)~=length(unique(string_new))
                msgbox('Repeated strings selected');
                return
            end
            if ~isfield(data,'strummings')
                data.strummings=[strum_new(1),strum_new(end),strum_new(end)-strum_new(1)];  %,velocity
                data.strumsDetail{1}=string_new;
                strum_cell{1}=strum_new;
                string_cell{1}=string_new;
                data.strumPara=strumParaDetection(strum_cell,string_cell);
                data.strummings(4)=data.strumPara{4};
                list=1;
            else
                for i=1:size(data.strummings,1)
                    if (strum_new(1)>=data.strummings(i,1) && strum_new(1)<=data.strummings(i,2)) || (strum_new(end)>=data.strummings(i,1) && strum_new(end)<=data.strummings(i,2))
                        msgbox('The new strumming is overlapping exisiting strums!','Warning!','Error');
                        return
                    end
                end
                data.strummings=[data.strummings;strum_new(1),strum_new(end),strum_new(end)-strum_new(1),0];   %,velocity                     
                data.strumsDetail(end+1)={string_new};
                [~,list]=sort(data.strummings(:,1));%,'ascend'
                strum_cell{1}=strum_new;
                string_cell{1}=string_new;
                data.strumPara(end+1,:)=strumParaDetection(strum_cell,string_cell);
                data.strummings(end,4)=data.strumPara{end,4};
                data.strummings=data.strummings(list,:);
                data.strumsDetail=data.strumsDetail(list);
                data.strumPara=data.strumPara(list,:);
%                 if list(end)~=size(data.strummings,1)
%                     data.strumsDetail(list(end)+1:end+1)=data.strumsDetail(list(end):end);
%                     data.strumsDetail{list(end)}=string_new;
%                     data.strumPara(list(end)+1:end+1,:)=data.strumPara(list(end):end,:);
%                     data.strumPara(list(end),:)=strumParaDetection(strum_cell,string_cell);
%                 else
%                     data.strumsDetail{list(end)}=string_new;
%                     data.strumPara(list(end),:)=strumParaDetection(strum_cell,string_cell);
%                 end
            end
            
            %plot and para display
            if isfield(data,'patchStrummingArea')
                delete(data.patchStrummingArea);
            end
            data.patchStrummingArea=plotFeaturesArea(data.strummings,data.axeTabStrumming);
            data.numStrummingSelected=1;
            plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,0);
            %plot the strum num in the listbox
            plotFeatureNum(data.strummings,data.StrummingListBox);
            %data.numStrummingSelected=1;
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
%             if size(data.strummings,2)==4
%                 data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
%             else
                data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
%             end
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
    end
end