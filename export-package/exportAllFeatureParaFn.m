function exportAllFeatureParaFn(hObject,eventData)
%EXPORTALLVIRAPARAFUNCTION export all feature (vibrato, portamento) parameters 
    global data;
    if ~strcmp(eventData.Source.Parent.Parent.Title,'Strumming Analysis')
        fileName=data.filenamedefault;
        if isfield(data,'fileName')
            fileName=data.fileName;
        end
        if isfield(data,'NoisefileName')
            fileName=data.NoisefileName;
        end
    else
        if isfield(data,'TrackfileName')
            fileName=data.TrackfileName;
        else
            msgbox('Incomplete onset/note inputs');
            return 
        end
    end
    if strcmp(eventData.Source.Parent.Parent.Title,'Vibrato Analysis')
        %get which para method
        method = get(data.methodVibratoChange,'Value');
        if method == 1
            %FDM
            savedData = data.vibratoPara{1};
            savedFileName = [fileName,'_vib_para_FDM_str',num2str(data.track_index),'.csv'];
        elseif method == 2
            %Max-min
            savedData = data.vibratoPara{2};
            savedFileName = [fileName,'_vib_para_Max-min_str',num2str(data.track_index),'.csv'];
        end
    elseif strcmp(eventData.Source.Parent.Parent.Title,'Sliding Analysis')
        savedFileName = [fileName,'_por_para_Logistic.csv'];
        if isfield(data,'portamentoParaPost')
            savedData = data.portamentoParaPost;
        else
            msgbox('No paratamento parameters, press Logistic Model first');
            return
        end
    elseif strcmp(eventData.Source.Parent.Parent.Title,'Tremolo Analysis')
        savedFileName = [fileName,'_trem_para_',data.changeTremoloMethod.String{data.changeTremoloMethod.Value},'_str',num2str(data.track_index),'.csv'];%add the method£¡
        if isfield(data,'tremoloPara') && sum(data.candidateNote(:,5)~=1)>0
            savedData=zeros(size(data.tremoloPara));
            for i=1:size(data.tremoloPara,1)
                for j=1:size(data.tremoloPara,2)
                    if ~isempty(data.tremoloPara{i,j})
                        savedData(i,j)=data.tremoloPara{i,j};
                    end
                end
            end
        else
            msgbox('No tremolo parameters, press Get Tremolo(s) first or no tremolo detected.');
            return
        end
    elseif strcmp(eventData.Source.Parent.Parent.Title,'Strumming Analysis')
        if isfield(data,'strumPara')
            fileName=split(data.TrackfileName,'_');%edge based
            fileName=fileName(1:end-3);
            fileName_tmp=fileName{1};
            if length(fileName)~=1
                for i=1:length(fileName)-1
                    fileName_tmp=[fileName_tmp,'_',fileName{i+1}];
                end 
            end
            %fileName=fileName_tmp;
            savedFileName = [fileName_tmp,'_strum_para','.csv'];%add the method£¡
            %savedData=[data.strumPara{:,1},data.strumPara{:,2}];
            savedData=cell2mat(data.strumPara);
        else
            msgbox('No strumming parameters, press Get strumming(s) first');
            return
        end
    end
   
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileName);
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        %csvwrite([savedPathName,savedFileName],savedData);
        dlmwrite([savedPathName,savedFileName],savedData,'precision','%.4f');
    end
end

