function modPortamentoFn(hObject,eventData)
%MODPortamentoFN modify portamento
%   此处显示详细说明
    global data;
    %get the time range after the change
    port =  split(get(data.portamentoXEdit,'String'),'-');
    modPortamentoStart = str2num(port{1});
    modPortamentoEnd = str2num(port{2});
    
    %get the sort of the modification portamento
    modIndex = data.numPortamentoSelected;
    
    %binary variable show whether the new added portamento is valid or not
    %-----START of modification portamento validation------
    %check the partly overlapping with exising portamentos
    if isfield(data,'portamentos') == 1
                %check whether it is out of the scope of the recording
        if ((modPortamentoStart > data.axePitchTabPortamento.XLim(2)) || ...
                (modPortamentoEnd < data.axePitchTabPortamento.XLim(1)))
            uiwait(msgbox('The new portamento must be within the recording!','Warning!','Error'));
            return
        end
        
        %check whether the new added portamento is an area
        if ((modPortamentoStart >= modPortamentoEnd))
            uiwait(msgbox('The new portamento should be an area!','Warning!','Error'));
            return
        end  
        if modIndex == 1 
            if size(data.portamentos,1)~=1
            if (modPortamentoEnd >= data.portamentos(2,1))
               uiwait(msgbox('The modification portamento is overlapping exisiting portamentos!','Warning!','Error'));               
               return
            end
            end
        elseif modIndex == size(data.portamentos,1)
            if (modPortamentoStart <= data.portamentos(modIndex-1,2))
               uiwait(msgbox('The modification portamento is overlapping exisiting portamentos!','Warning!','Error'));              
               return
            end      
        else%portamento is in the middle
            for i = 1:size(data.portamentos,1)
               if  (i<modIndex) && (modPortamentoStart <= data.portamentos(i,2))
                   uiwait(msgbox('The modification portamento is overlapping exisiting portamentos!','Warning!','Error'));
                   return;
               elseif (i>modIndex) && (modPortamentoEnd >= data.portamentos(i,1))
                   uiwait(msgbox('The modification portamento is overlapping exisiting portamentos!','Warning!','Error'));
                   return;
               %the x range does not change
               elseif (i == modIndex) && (modPortamentoStart == data.portamentos(i,1))&& (modPortamentoEnd == data.portamentos(i,2))
%                    validModPortamento = 0;
%                    return;
               end
            end    
        end

    
    %delete the old portamento
    delete(data.patchPortamentoArea(modIndex));
    %delete estimated logistic parameters, otherwise the length cannot be
    %matched
    clear global portamentosDetailLogistic;
    if isfield(data,'portamentoPara')
        data=rmfield(data,'portamentoPara');
    end
    % modify the portamento into the portamento array
    data.portamentos(modIndex,[1,2]) = [modPortamentoStart,modPortamentoEnd];
    data.portamentos(modIndex,3) = data.portamentos(modIndex,2)-data.portamentos(modIndex,1); %duration
    if isfield(data,'pitchVFree')
        data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos,0);
    else
        data.portamentosDetail = getPassages(data.pitchTime,data.pitch,data.portamentos,0);
    end
    %plot the modified portamento
    modPatchPortamentoArea = plotNewFeatureArea(data.portamentos(modIndex,:),data.axePitchTabPortamento);
    %modify the patch in patch list
    data.patchPortamentoArea(modIndex) = modPatchPortamentoArea;

    %higlight the selected portamento
    plotHighlightFeatureArea(data.patchPortamentoArea,modIndex,0);

    %show the highlighted num of portamento in portamento listbox
    data.portamentoListBox.Value = modIndex;

    %show individual portamento in the sub axes
    plotPitchFeature(data.portamentosDetail, modIndex ,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi) 

    


    %show individual portamento statistics
    if isfield(data,'portamentosDetailLogistic')
    %-----START of calculating the modify para-----------
        portamentoNames = fieldnames(data.portamentosDetail);        
        TimePitchNewPortamento = data.portamentosDetail.(char(portamentoNames(modIndex)));

        %the logistic model fitting
        [fittedPortamentoLogistic6,~] = createGeneralLogistic6Fit(TimePitchNewPortamento(:,1),freqToMidi(TimePitchNewPortamento(:,2)));
        data.portamentoPara(modIndex,:) = coeffvalues(fittedPortamentoLogistic6);

        %add the new fitted line vector
        %-------get the fitted line-----------
        A = data.portamentoPara(modIndex,1); 
        B = data.portamentoPara(modIndex,2);
        G = data.portamentoPara(modIndex,3); 
        L = data.portamentoPara(modIndex,4); 
        M = data.portamentoPara(modIndex,5); 
        U = data.portamentoPara(modIndex,6);
        portamentosDetailLogisticNew = MidiToFreq( L + (U-L)./((1+A*exp(-G*(TimePitchNewPortamento(:,1)-M))).^(1/B)));
        %----------------------   
        for i = size(data.portamentos,1):-1:modIndex + 1
           data.portamentosDetailLogistic.(['passage',num2str(i)]) = data.portamentosDetailLogistic.(char(portamentoNames(i-1)));
        end                
        data.portamentosDetailLogistic.(['passage',num2str(modIndex)]) = portamentosDetailLogisticNew;
        %plotPortamentoStatistics(data.textVib,data.portamentoPara,modIndex ,data.methodPortamentoChange,data.methodPortamentoDetectorChange,data.methodParameterChange);   
        plotPortamentoStatistics(data.textPort,data.portamentoPara,modIndex);
    end
        %-----END of calculating the new para-----------
    end
end

