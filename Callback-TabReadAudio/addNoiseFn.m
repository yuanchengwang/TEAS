function addNoiseFn(hObject,eventData)
%ADDNOISEFN Add/change noise range
%   Detailed explanation goes here
    global data;
    data.Bn.addNoiseArea.set('Enable','inactive');
    %get the rectangle from the mouse selection
    axe=data.axeWave;
    rect = getrect(axe);
    
    %----START of Noise range setting---------------
    %check if it's a good area
    if rect(3)==0
       msgbox('Bad noise area adding');
    else
        if (axe.XLim(1)<=rect(1) && rect(1)<=axe.XLim(2)) || (axe.XLim(1)<=rect(1)+rect(3) && rect(1)+rect(3)<=axe.XLim(2))
            %delete the result
            if isfield(data,'noise_range')           
                data=rmfield(data,'noise_range');
            end 
            if isfield(data,'patchNoiseRangeArea')
                delete(data.patchNoiseRangeArea);
                data=rmfield(data,'patchNoiseRangeArea');
            end
            %define the noise range
            NoiseStart=rect(1);
            NoiseEnd=rect(1) + rect(3);
            data.noise_range=[NoiseStart,NoiseEnd];
            if isfield(data,'noise_ranges')
                data.noise_ranges=[data.noise_ranges;data.noise_range];
            else
                data.noise_ranges=data.noise_range;
            end
            data.noise_range_num=size(data.noise_ranges,1);
            %plot the noise ranges
            data.patchNoiseRangeArea=plotFeaturesArea(data.noise_ranges,data.axeWave);
            plotHighlightFeatureArea(data.patchNoiseRangeArea,data.noise_range_num,1);
        else
            msgbox('Bad noise area adding');
        end
    end
    data.Bn.addNoiseArea.set('Enable','on');
end

