function importStrummingFn(hObject,eventData)
%IMPORTSTRUMMINGFN import strumming interval
global data;
[fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    if isnumeric(fileNameSuffix) == 0
        
        %if the user doesn't cancel, then read the strumming annotation
        %.csv file
        fullPathName = strcat(filePath,fileNameSuffix);
        
        %Get the individual strumming time and pitch vector 
        %strummingsDetail:[time from 0:pitch:orginal time]
        if strcmp(data.tgroup.SelectedTab.Title,'Strumming Analysis')
            data.strummings = csvread(fullPathName);

            %data.strummingsDetail = getPassages(data.pitchTime,data.pitch,data.strummings,0);%»»Ò»¸öÏÔÊ¾£¡

    %         %remove the strumming parameters
    %         if isfield(data,'strummingsParameter') 
    %             data = rmfield(data,'strummingsParameter');
    %         end
            all_onsets=[];
            string=[];
            if isfield(data,'onset_tracks')
                for i=1:data.track_nb
                    all_onsets=[all_onsets;data.onset_tracks{i}];
                    string=[string;i*ones(size(data.onset_tracks{i}))];
                end
            end
            total_num_onsets=length(all_onsets);%total num of plucks
            [all_onsets,order]=sort(all_onsets);
            string=string(order);
            L=size(data.strummings,1);
            strums=cell(L,1);
            strumsDetail=cell(L,1);
            for i=1:L
                flag=(all_onsets>=data.strummings(i,1) & all_onsets<=data.strummings(i,2));
                strums{i}=all_onsets(flag);
                strumsDetail{i}=string(flag);
            end
            data.strumsDetail=strumsDetail;
            data.strumPara=strumParaDetection(strums,strumsDetail);
            if size(data.strummings,2)==3
                data.strummings(:,4)=ones(size(data.strummings,1),1);
                msgbox('The strumming, arpeggio, rasgueado are automatically defined, we set all by strumming by default. Please modify it yourself.');
            else
                data.strumPara(:,4)=cell(L,1);
                for i=1:L
                    data.strumPara{i,4}=data.strummings(i,4);
                end
            end
    
            %plot the strummings on the pitch curve
            if isfield(data,'patchStrummingArea')
                %if there are already some strumming
                delete(data.patchStrummingArea);
            end
            data.patchStrummingArea =  plotFeaturesArea(data.strummings,data.axeTabStrumming);

            %Highlight the first strumming
            data.numStrummingSelected = 1;
            plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,1);

            %plot the strumming num in the listbox
            plotFeatureNum(data.strummings,data.StrummingListBox);

            %show the first Strumming in Strumming listbox
            data.StrummingListBox.Value = data.numStrummingSelected;

            %show the first Strumming's X(time) range in the edit text
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
            %,'+',num2str(data.strummings(data.numStrummingSelected,4))
            
            %show individual strumming in the sub axes
            %plotPitchFeature(data.strummingsDetail, data.numStrummingSelected,data.StrumXaxisPara,data.axeTabStrummingIndi);
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
            %plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
            plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
            if isfield(data,'patchFeaturesTrackOnsetsIndi')
                delete(data.patchFeaturesTrackOnsetsIndi);
                delete(data.patchFeaturesAreaOnsetsIndi);
            end
            data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
            data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);
            %show the type
            data.StrummingType(data.numStrummingSelected).Value=data.strummings(data.numStrummingSelected,4);
            
        else%Strumming track for synthesis+MIDI
            data.StrummingTrack=csvread(fullPathName);
        end
    end    
end