function [patchFeaturesPoint]=plotEdgeTracks(onset,offset,onset_env,offset_env,EdgeTime,axeInput)
    axes(axeInput);
    hold on
    if ~isempty(offset)
        for j=1:length(offset)
            patchFeaturesPoint(j,2) = line([offset(j),offset(j)],...
                    [25,105],'color','yellow');%offset
        end
    end
    if ~isempty(onset)
        for i = 1:length(onset)  
            patchFeaturesPoint(i,1) = line([onset(i),onset(i)],...
                [25,105],'color','red');%onset
        end
    end
    %the y axis in plot pitch starts with 55 midi note£¬ onset_env+offset_env are
    %normalized to 17 midi note to better show the envelope.
    patchFeaturesPoint(length(onset)+1,1) = plot(EdgeTime,onset_env./max(onset_env)*17+55,'blue');%onset_env
    patchFeaturesPoint(length(offset)+1,2) = plot(EdgeTime,offset_env./max(offset_env)*17+55,'green');%offset_env
    hold off
end