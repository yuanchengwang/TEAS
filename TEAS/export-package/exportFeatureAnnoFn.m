function exportFeatureAnnoFn(hObject,eventData)
%EXPORTALLVIRAFUNCTION export the feature (vibrato/portamento/tremolo) annotations
%   Detailed explanation goes here

    global data;
    if ~strcmp(eventData.Source.Parent.Parent.Title,'Strumming Analysis')
        if isfield(data,'fileName')
            fileName=data.fileName;
        end
        if isfield(data,'NoisefileName')
            fileName=data.NoisefileName;
        end
        if ~exist('fileName','var')
            fileName=[];
            msgbox('No audio input');
        end
    else
        if isfield(data,'TrackfileName')
            fileName=split(data.TrackfileName,'_');%edge based
            fileName=fileName(1:end-3);
            fileName_tmp=fileName{1};
            if length(fileName)~=1
                for i=1:length(fileName)-1
                    fileName_tmp=[fileName_tmp,'_',fileName{i+1}];
                end 
            end
            fileName=fileName_tmp;
        else
            msgbox('Incomplete onset/note inputs');
            return
        end
    end
    if strcmp(eventData.Source.Parent.Title,'Get Vibrato:')
        savedFileName = [fileName,'_vibratos_str',num2str(data.track_index),'.csv'];
        annotation = data.vibratos;
    elseif strcmp(eventData.Source.Parent.Title,'Get Sliding:')
        savedFileName = [fileName,'_portamentos_str',num2str(data.track_index),'.csv'];
        annotation = data.portamentos;
    elseif strcmp(eventData.Source.Parent.Title,'Get Tremolo:')
        savedFileName = [fileName,'_tremolos_str',num2str(data.track_index),'.csv'];
        para=[data.tremoloPara{:,2}];
        if isfield(data,'tremoloPara')
            if data.double_peak
                if sum(para==0.5)==0 && length(para)==size(data.candidateNote,1)
                    a=para*2-1;
                else
                    msgbox('At least an pluck onset for each note, check before file export.');
                    return
                end
            else
                a=para-1;
            end
            annotation = zeros(size(data.candidateNote)+[0,max(a)]);
            annotation(:,1:5)=data.candidateNote;%tremolo;
            for i=1:size(data.tremoloPara,1)
                onset=data.onset_tremolo{i}';
                if ~isempty(data.onset_tremolo{i})
                    annotation(i,6:5+length(onset))=onset;
                end
            end
        else%no onset
            annotation=data.candidateNote;%tremolo;
        end   
    elseif strcmp(eventData.Source.Parent.Title,'Get Strumming:')
        savedFileName = [fileName,'_strummings.csv'];
        if isfield(data,'strummings')
            annotation = data.strummings;%(data.strummings(:,4)~=3,:);%remove the multiple plucks candidate note;
        else
            msgbox('No strumming detected, add strumming or press Get Strumming(s) button first.');
            return
        end
    end
    
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileName);
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        %csvwrite([savedPathName,savedFileName],annotation);
        dlmwrite([savedPathName,savedFileName],annotation,'precision','%.4f');
    end
end

