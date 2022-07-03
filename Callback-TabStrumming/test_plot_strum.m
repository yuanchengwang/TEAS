function test_plot_strum(hObject,eventData)
    global data;
    EdgeTrackTest;
    if isfield(data,'TrackXaxisPara')%(Re)set the type;
        data.TrackXaxisType=data.TrackXaxisPara.Value;
    end
    if isfield(data,'strummings')
%         data=rmfield(data,'strummings');
        data.StrummingListBox.String=[];
        data.StrumXEdit.String=[];
%         data=rmfield(data,'strumsDetail');
%         data=rmfield(data,'strumPara');
        cla(data.axeTabStrummingIndi);
        cla(data.axeTabStrumming);
        plotStrumStatistics(data.textPortStrumming,[],1);
    end
    if isfield(data,'patchFeaturesTrackOnsets')
        delete(data.patchFeaturesTrackOnsets);
        %data=rmfield(data,'patchFeaturesTrackOnsets');
        cla(data.axeTabStrumming);
    end
    range_min=zeros(data.track_nb,1);
    range_max=zeros(data.track_nb,1);
    for i=1:data.track_nb
        range_min(i)=min(data.onset_tracks{i});
        range_max(i)=max(data.onset_tracks{i});
    end
    range=[max(0,min(range_min)-1),max(range_max)+1];
    data.patchFeaturesTrackOnsets=plotStrumming(data.onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrumming);
end