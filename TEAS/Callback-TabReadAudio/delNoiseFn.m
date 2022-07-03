function delNoiseFn(hObject,eventData)
%DELNOISEFN Delete noise range
%   Detailed explanation goes here
    global data;
    if isfield(data,'patchNoiseRangeArea')
       delete(data.patchNoiseRangeArea);
       data=rmfield(data,'patchNoiseRangeArea');
    end
    data.noise_ranges(data.noise_range_num,:)=[];
    if data.noise_range_num>size(data.noise_ranges,1)
        data.noise_range_num=data.noise_range_num-1;
    end
    if ~isempty(data.noise_ranges)
        data.patchNoiseRangeArea=plotFeaturesArea(data.noise_ranges,data.axeWave);
        plotHighlightFeatureArea(data.patchNoiseRangeArea,data.noise_range_num,1);
    end 
end

