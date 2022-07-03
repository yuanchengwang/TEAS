function addVibratoFn(hObject,eventData)
%ADDVIBRATOFN Add vibrato

    global data;
    method = get(data.methodVibratoChange,'Value');
    method1 = get(data.methodVibratoDetectorChange,'Value');
    method2 = get(data.methodParameterChange,'Value');
    %binary variable show whether the new added vibrato is valid or not
    %1: valide, 0: not valid
    validNewVibrato = 1;    
    rect = getrect(data.axePitchTabVibrato);
    
    newVibratoStart = rect(1);
    newVibratoEnd = rect(1) + rect(3);
    
    %----START of new vibrato validation---------------
    %check the partly overlapping with exising vibratos
    %vibrato is changed into vibratopara
    if isfield(data,'vibratoPara')
        vibrato_test=data.vibratoPara{method,method1,method2};
    else
        msgbox('Please run get vibrato button before adding vibrato.');
        return
    end
    if isfield(data,'vibratos') == 1
%         for i = 1:size(vibrato_test,1)
%            if (validNewVibrato == 1) && (newVibratoStart >= vibrato_test(i,1) && newVibratoStart <= vibrato_test(i,2)) ||...
%                    (newVibratoEnd >= vibrato_test(i,1) && newVibratoEnd <= vibrato_test(i,2))
%                validNewVibrato = 0;
%                uiwait(msgbox('The new vibrato is overlapping exisiting vibratos!','Warning!','Error'));
%                break;
%            end
%         end

        %check the coverage all of the exisiting vibratos
        for i = 1:size(vibrato_test,1)
           if (validNewVibrato == 1) && (newVibratoStart <= vibrato_test(i,1) && newVibratoEnd >= vibrato_test(i,2))
               validNewVibrato = 0;
               uiwait(msgbox('The new vibrato is overlapping exisiting vibratos!','Warning!','Error'));
               break;
           end
        end

        %check whether it is out of the scope of the recording
        if (validNewVibrato == 1) && ((newVibratoStart >= data.axePitchTabVibrato.XLim(2)) || ...
                (newVibratoEnd <= data.axePitchTabVibrato.XLim(1)))
            validNewVibrato = 0;
            uiwait(msgbox('The new vibrato should be within the recording!','Warning!','Error'));
        end
        
        %check whether the new added vibrato is an area
        if (validNewVibrato == 1) && ((newVibratoStart >= newVibratoEnd))
            validNewVibrato = 0;
            uiwait(msgbox('The new vibrato should be an area!','Warning!','Error'));
        end        
    else
        %if there is no vibrato
        validNewVibrato = 0;
        uiwait(msgbox('Please click Get Vibrato(s) button! It is necessary to run FDM-based vibrato detection before adding vibrato.','Warning!','Error'));
    end
    %----END of new vibrato validation---------------
    
    if validNewVibrato == 1
         if isfield(data,'onset') && isfield(data,'offset') && data.CB.Auto_vibrato.Value
            if data.double_peak
                onset=data.onset(2:2:end)*data.hop_length/data.fs;
            else
                onset=data.onset*data.hop_length/data.fs;
            end
            offset=data.offset*data.hop_length/data.fs;
            ind=find(offset-newVibratoEnd>0,1);
            newVibratoEnd=offset(ind)-0.001;
            ind=find(newVibratoEnd-onset>0);
            newVibratoStart=onset(ind(end));
        end
        if isfield(data,'vibratos') == 1
            % add the new vibrato into the vibrato array
            data.vibratos=[data.vibratos;newVibratoStart,newVibratoEnd,newVibratoEnd-newVibratoStart,1];
            [~,index] = sort(data.vibratos(:,1));
            data.vibratos=data.vibratos(index,:);
            indexNewVibrato = find(index(:,1) == size(index,1));
            data.VibratoType.Value=1;
            %add the time-pitch into the vibratosDetail struct
            vibratoNames = fieldnames(data.vibratosDetail);
            for i = size(data.vibratos,1):-1:indexNewVibrato + 1
               data.vibratosDetail = setfield(data.vibratosDetail,['passage',num2str(i)],getfield(data.vibratosDetail, char(vibratoNames(i-1))));
            end
            timePitchNewVibrato = getPassages(data.pitchTime,data.pitch,data.vibratos(indexNewVibrato,:),0);
            data.vibratosDetail = setfield(data.vibratosDetail,['passage',num2str(indexNewVibrato)],timePitchNewVibrato.passage1);

    %         %Get the individual vibrato time and pitch vector 
    %         %vibratosDetail:[time from 0:pitch:orginal time]
    %         data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);
    
            vibratoNames = fieldnames(data.vibratosDetail);
            %-----START of calculating the new para-----------
            freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
            ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');

            freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
            ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
            thres=[min(freqThresh(2),10),min(ampThresh(2),4)];
            if method==1
            vibratosParaFDMNewVibrato = getVibratoParaFDM2(data.vibratos(indexNewVibrato,:),data.FDMtime,data.FDMoutput,thres);
            else
            vibratosParaFDMNewVibrato = getVibratoParaFDM2(data.vibratos(indexNewVibrato,:),data.PERtime,data.PERoutput,thres);
            end
            vibratoTimePitchNewVibrato = getfield(data.vibratosDetail, char(vibratoNames(indexNewVibrato)));
            vibratoTimePitchNewVibrato=vibratoTimePitchNewVibrato(:,[1,2]);
            avgpitch=median(vibratoTimePitchNewVibrato(:,2)).*[2^(-1/4),2^(1/4)];
            vibratoTimePitchNewVibrato=vibratoTimePitchNewVibrato(vibratoTimePitchNewVibrato(:,2)<avgpitch(2) & vibratoTimePitchNewVibrato(:,2)>avgpitch(1),:);

            vibratoParaMaxMinNewVibrato = vibratoRateExtent(vibratoTimePitchNewVibrato);
            vibratosSSNewVibrato = vibratoShape(vibratoTimePitchNewVibrato);
            
            vibratosParaFDMNewVibrato = [vibratosParaFDMNewVibrato,vibratosSSNewVibrato];
            vibratoParaMaxMinNewVibrato = [vibratoParaMaxMinNewVibrato,vibratosSSNewVibrato];
            %add the new para into the para array
            data.vibratoPara{method,method1,1} = [data.vibratoPara{method,method1,1}(1:indexNewVibrato-1,:);vibratosParaFDMNewVibrato;data.vibratoPara{method,method1,1}(indexNewVibrato:end,:)];
            data.vibratoPara{method,method1,2} = [data.vibratoPara{method,method1,2}(1:indexNewVibrato-1,:);vibratoParaMaxMinNewVibrato;data.vibratoPara{method,method1,2}(indexNewVibrato:end,:)];
            data.vibratos(indexNewVibrato,4)=1;
            %-----END of calculating the new para-----------
        else
            %the new added vibrato is the first vibrato
            indexNewVibrato = 1;
            data.vibratos = zeros(1,3);
            data.vibratos(:,[1 2]) = [newVibratoStart,newVibratoEnd];
            data.vibratos(:,3) = data.vibratos(:,2)-data.vibratos(:,1); %duration
            data.vibratos(:,4) = 1;%Type by default
            data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos(indexNewVibrato,:),0);
            
            %----START of getting vibrato para-------
            %vibratosParaFDM: [vibrato rate:vibrato extent]
            if method==1
            vibratosParaFDM = getVibratoParaFDM2( data.vibratos,data.FDMtime,data.FDMoutput );
            else
            vibratosParaFDM = getVibratoParaFDM2( data.vibratos,data.PERtime,data.PERoutput );
            end
            %get vibrato rate, extent(using max-min method) vibrato sinusoid similarity for all passages
            vibratoNames = fieldnames(data.vibratosDetail);
            %vibratoParaMin: [rate, extent, std rate, std extent, SS]
            vibratoParaMaxMin = zeros(length(vibratoNames),5);
            vibratosSS = zeros(length(vibratoNames),1);
            for i = 1:length(vibratoNames)
                vibratoTimePitch = getfield(data.vibratosDetail, char(vibratoNames(i)));
                %sinusoid similarity
                vibratosSS(i) = vibratoShape(vibratoTimePitch(:,[1,2]));
                vibratoParaMaxMin(i,[1:4]) = vibratoRateExtent(vibratoTimePitch(:,[1,2]));
                vibratoParaMaxMin(i,5) = vibratosSS(i);
            end
            %add sinusoid similarity to the vibratosParaFDM ([rate:extent:SS])        
            vibratosParaFDM = [vibratosParaFDM,vibratosSS];

            %vibratosPara{1}from FDM
            %vibratosPara{2}from Max-min
            data.vibratoPara{method,method1,1} = vibratosParaFDM;
            data.vibratoPara{method,method1,2} = vibratoParaMaxMin;
            %-----END of calculating the new para-----------
        end

        data.numViratoSelected = indexNewVibrato;
        
        %plot the new created vibrato
        newPatchVibratoArea = plotNewFeatureArea(data.vibratos(data.numViratoSelected,:),data.axePitchTabVibrato);
        %add the new patch into patch list
        data.patchVibratoArea = [data.patchVibratoArea(1:indexNewVibrato-1),newPatchVibratoArea,data.patchVibratoArea(indexNewVibrato:end)];
        
        %higlight the selected vibrato
        plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);
    
        %plot the vibrato num in the listbox
        plotFeatureNum(data.vibratos,data.vibratoListBox);
        
        %show the highlighted num of vibrato in vibrato listbox
        data.vibratoListBox.Value = data.numViratoSelected;
        
        %show individual vibrato in the sub axes
        plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi) 
        
        %show thes vibrato's X(time) range in the edit text
        data.vibratoXEdit.String=[num2str(data.vibratos(data.numViratoSelected,1)),'-',num2str(data.vibratos(data.numViratoSelected,2))];
        
        %show individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
    end
end

