function plotClearFeature(featureName)
%plotClearFeature Clear feature, i.e. vibrato or portamenti 
%Input
%@featureName: 'Note','Vibrato' or 'Portamento'

    global data;
    if strcmp(featureName,'Note')
        features = 'notes';
        featuresDetail = 'NoteDetail';
        patchFeatureAreaName = 'patchNoteArea';
        numFeatureSelected = 'numNoteSelected';
        featureListBox = data.noteListBox;
        axeFeature= data.axePitchTabNoteIndi;
    elseif strcmp(featureName,'Vibrato')
        features = 'vibratos';
        featuresDetail = 'vibratosDetail';
        patchFeatureAreaName = 'patchVibratoArea';
        numFeatureSelected = 'numVibratoSelected';
        featureListBox = data.vibratoListBox;
        axeFeature= data.axePitchTabVibratoIndi;
    elseif strcmp(featureName,'Portamento')
        features = 'portamentos';
        featuresDetail = 'portamentosDetail';
        patchFeatureAreaName = 'patchPortamentoArea';
        numFeatureSelected = 'numPortamentoSelected';
        featureListBox = data.portamentoListBox;
        axeFeature= data.axePitchTabPortamentoIndi;
    elseif strcmp(featureName,'Tremolo')
        features = 'tremolos';
        featuresDetail = 'tremolosDetail';
        patchFeatureAreaName = 'patchTremoloArea';
        numFeatureSelected = 'numTremoloSelected';
        featureListBox = data.tremoloListBox;
        axeFeature= data.axeWaveTabTremoloIndi;
%     elseif strcmp(featureName,'Strumming')
%         features = 'strummings';
%         featuresDetail = 'tremolosDetail';
%         patchFeatureAreaName = 'patchTremoloArea';
%         numFeatureSelected = 'numTremoloSelected';
%         featureListBox = data.tremoloListBox;
%         axeFeature= data.axeWaveTabTremoloIndi;
    end
    
    if isfield(data,features) == 1
       data = rmfield(data,features); 
    end
    if isfield(data,featuresDetail) == 1
       data = rmfield(data,featuresDetail); 
    end
    if isfield(data,patchFeatureAreaName) == 1
        %delete the patches from the plot
       delete(eval(['data.',patchFeatureAreaName]));
       data= rmfield(data,patchFeatureAreaName);
    end
    if isfield(data,numFeatureSelected) == 1
       data = rmfield(data,numFeatureSelected); 
    end
    
    %clear the content in the listbox
    plotFeatureNum([],featureListBox);
    
    %clear the axes for individual feature
    cla(axeFeature,'reset');
end

