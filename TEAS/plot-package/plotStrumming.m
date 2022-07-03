function patchFeaturesTrackOnsets=plotStrumming(onset_tracks,color,track_nb,strum,axeInput)  
    axes(axeInput);
    hold on;
    for i=1:track_nb
        onset=onset_tracks{i};
        for j = 1:length(onset)  
            patchFeaturesTrackOnsets(i,j) = line([onset(j),onset(j)],...
                [i-0.4,i+0.4],'color',color(i,:));%onset
        end
    end
    yticks(1:track_nb);
    xlim([strum(1),strum(2)]+[-0.1,+0.5]);%[-0.1,+0.5]
    hold off;
end