function delStrummingFn(hObject,eventData)
%DELSTRUMMINGFN Delete strumming
%   Detailed explanation goes here
    global data; 
    if ~isfield(data,'strummings')
        msgbox('No strum detected.');
        return
    end
    if isempty(data.strummings) == 0
        %delete the strumming time information
        data.strummings(data.numStrummingSelected,:) = [];
        data.strumsDetail(data.numStrummingSelected) = [];
        %data.strums_index(data.numStrummingSelected) = [];
        data.strumPara(data.numStrummingSelected,:) = [];
        %delete the strumming area patch in the plot
        delete(data.patchStrummingArea(data.numStrummingSelected));
        data.patchStrummingArea(data.numStrummingSelected) = [];

        %if the deleted strumming is the last one, then go to the first
        if (data.numStrummingSelected == size(data.strummings,1)+1)
            data.numStrummingSelected = 1;
        end
               
        %higlight the selected strumming
        plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,0);

        %plot the strumming num in the listbox
        plotFeatureNum(data.strummings,data.StrummingListBox);

        %show the highlighted num of strumming in strumming listbox
        data.StrummingListBox.Value = data.numStrummingSelected;

        %show individual strumming in the sub axes
        if isfield(data,'polyStrumAudio')
            time=(0:size(data.polyStrumAudio,1)-1)'/data.fs;
            pos=data.strummings(data.numStrummingSelected,1:2)+[-0.1,0.5];
            [~,time1]=min(abs(pos(1)-time));
            [~,time2]=min(abs(pos(2)-time));
            if isfield(data,'plotStrumAudio')
                delete(data.plotStrumAudio);
            end
            data.plotStrumAudio=plotAudio(time(time1:time2),data.polyStrumAudio(time1:time2),data.axeTabStrummingIndi,'Selected Strum',1);
        end
        
    %show individual strumming statistics
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
    end
    if isfield(data,'patchFeaturesTrackOnsetsInd')
        delete(data.patchFeaturesTrackOnsetsInd);
        delete(data.patchFeaturesAreaOnsetsInd);
    end
    data.patchFeaturesTrackOnsetsInd=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
    data.patchFeaturesAreaOnsetsInd=plotFeaturesArea(range,data.axeTabStrummingIndi);
    %show the first individual strum statistics
    plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
    data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end}; 
        %show thes strumming's X(time) range in the edit text
        if isempty(data.strummings)
            data.StrumXEdit.String=[];
            return
        end
        if size(data.strummings,2)==4
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
        else
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
        end
    end
end