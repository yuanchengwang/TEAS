function plotFeatureNum(features, featureListBox)
%PLOTFEATURENUM plot the features (Note,vibrato,portamento,tremolo) num in the corresponding listbox
%   Input:
%   @vibratos: [vibrato start time:end time:duration]
%   @vibratoListBox: uicontrl - listbox

    featureNumberList = cell(size(features,1),1);
    for i = 1:size(features,1)
        featureNumberList{i} = num2str(i);
    end
    set(featureListBox,'String',featureNumberList);
    featureListBox.Value=1;
end

