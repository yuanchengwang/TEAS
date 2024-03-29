function plotPitchFeature(featuresDetail,numFeatureSelected,featureXaxisPara,axeFeature)
%plotPitchFeature plot individual feature(note/vibrato/portamento) pitch curve in the axe
%   Input:
%   @featuresDetail: [time from 0:MIDI pitch:orginal time]
%   @numFeatureSelected: the number of note/vibrato/portamento selected
%   @featureXaxisPara: ��popup Uicontrol��indicates which kind of x-axis shoud be used. (1: original time, 2: normalized time)
%   @axeFeature: the axe used for ploting individual vibrato
%   
    global data;  
    currentTabName = data.tgroup.SelectedTab.Title;
    axes(axeFeature);
    featureNames = fieldnames(featuresDetail);
    if isempty(featureNames) == 0
        %still have vibrato
        featureIndi = featuresDetail.(char(featureNames(numFeatureSelected)));
    
        %choose which x-axis will be used
        xAxis = get(featureXaxisPara,'Value');
        if xAxis == 1
            %original time  
            time = featureIndi(:,3);
        elseif xAxis == 2
            %normalized time
            time = featureIndi(:,1);
        end

%  plot(time,featureIndi(:,2),'Tag','indiVibratoPitchLine');
        
        
        if strcmp(currentTabName,'Note Detection')
            title('Selected Note');
            yyaxis left;
        elseif strcmp(currentTabName,'Vibrato Analysis')
            title('Selected Vibrato');
        elseif strcmp(currentTabName,'Sliding Analysis')
            title('Selected Portamento');
        elseif strcmp(currentTabName,'Tremolo Analysis')
           title('Selected Tremolo');
        elseif strcmp(currentTabName,'Strumming Analysis')
           title('Selected Strumming');
        %else%overall 
           %title('Selected Features');
        end
        plot(time,featureIndi(:,2),'-');
        ylabel('Frequency(Hz)');
        xlabel('Time(s)');
        xlim([time(1) time(end)]);
    else
        %no feature, clear the axes
        cla(axeFeature,'reset');
    end
end

