function modVibratoFn(hObject,eventData)
%MODVIBRATOFN modify vibrato
%   此处显示详细说明
    global data;
    
    %get the time range after the change
    vib =  split(get(data.vibratoXEdit,'String'),'-');
    modVibratoStart = str2num(vib{1});
    modVibratoEnd = str2num(vib{2});
    
    %get the sort of the modification vibrato
    modIndex = data.numViratoSelected;
    
    %binary variable show whether the new added vibrato is valid or not
    %1: valide, 0: not valid
    validModVibrato= 1;
    %-----START of modification vibrato validation------
    %check the partly overlapping with exising vibratos
    if isfield(data,'vibratos') == 1
                %check whether it is out of the scope of the recording
        if (validModVibrato == 1) && ((modVibratoStart > data.axePitchTabVibrato.XLim(2)) || ...
                (modVibratoEnd < data.axePitchTabVibrato.XLim(1)))
            validModVibrato = 0;
            uiwait(msgbox('The new vibrato must be within the recording!','Warning!','Error'));
            return
        end
        
        %check whether the new added vibrato is an area
        if (validModVibrato == 1) && ((modVibratoStart >= modVibratoEnd))
            validModVibrato = 0;
            uiwait(msgbox('The new vibrato should be an area!','Warning!','Error'));
            return
        end  
        if modIndex == 1 
            if size(data.vibratos,1)~=1
            if (validModVibrato == 1) && (modVibratoEnd >= data.vibratos(2,1))
               validModVibrato = 0;
               uiwait(msgbox('The modification vibrato is overlapping exisiting vibratos!','Warning!','Error'));               
               return
            end
            end
        elseif modIndex == size(data.vibratos,1)
            if (validModVibrato == 1) && (modVibratoStart <= data.vibratos(modIndex-1,2))
               validModVibrato = 0;
               uiwait(msgbox('The modification vibrato is overlapping exisiting vibratos!','Warning!','Error'));              
               return
            end
            
        %vibrato is in the middle
        else
            for i = 1:size(data.vibratos,1)
               if (validModVibrato == 1) && (i<modIndex) && (modVibratoStart <= data.vibratos(i,2))
                   validModVibrato = 0;
                   uiwait(msgbox('The modification vibrato is overlapping exisiting vibratos!','Warning!','Error'));
                   return;
               elseif (validModVibrato == 1) && (i>modIndex) && (modVibratoEnd >= data.vibratos(i,1))
                   validModVibrato = 0;
                   uiwait(msgbox('The modification vibrato is overlapping exisiting vibratos!','Warning!','Error'));
                   return;
               %the x range does not change
               elseif (validModVibrato == 1) && (i == modIndex) && (modVibratoStart == data.vibratos(i,1))&& (modVibratoEnd == data.vibratos(i,2))
                   validModVibrato = 0;
                   return;
               end
            end    
        end

    
    if validModVibrato == 1
        %delete the old vibrato
        delete(data.patchVibratoArea(modIndex));
        
        % modify the vibrato into the vibrato array
        data.vibratos(modIndex,[1,2]) = [modVibratoStart,modVibratoEnd];
        data.vibratos(modIndex,3) = data.vibratos(modIndex,2)-data.vibratos(modIndex,1); %duration

        %modify the time-pitch into the vibratosDetail struct  
        vibratoNames = fieldnames(data.vibratosDetail);
        timePitchNewVibrato = getPassages(data.pitchTime,data.pitch,data.vibratos(modIndex,:),0);
        data.vibratosDetail = setfield(data.vibratosDetail,['passage',num2str(modIndex)],timePitchNewVibrato.passage1);

        vibratoNames = fieldnames(data.vibratosDetail);

        %-----START of calculating the modify para-----------
        freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
        ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');

        freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
        ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
        thres=[min(freqThresh(2),10),min(ampThresh(2),4)];
        if get(data.methodVibratoDetectorChange,'Value')==1
            vibratosParaFDMModVibrato = getVibratoParaFDM2(data.vibratos(modIndex,:),data.FDMtime,data.FDMoutput,thres);
        else%per
            vibratosParaFDMModVibrato = getVibratoParaFDM2(data.vibratos(modIndex,:),data.PERtime,data.PERoutput,thres);
        end
        vibratoTimePitchModVibrato = getfield(data.vibratosDetail, char(vibratoNames(modIndex)));
        vibratoParaMaxMinModVibrato = vibratoRateExtent(vibratoTimePitchModVibrato(:,[1,2]));
        vibratosSSModVibrato = vibratoShape(vibratoTimePitchModVibrato(:,[1,2]));

        vibratosParaFDMModVibrato = [vibratosParaFDMModVibrato,vibratosSSModVibrato];
        vibratoParaMaxMinModVibrato = [vibratoParaMaxMinModVibrato,vibratosSSModVibrato];
        %modify the para in the para array
        data.vibratoPara{1}(modIndex,:) = vibratosParaFDMModVibrato;
        data.vibratoPara{2}(modIndex,:) = vibratoParaMaxMinModVibrato;
        %-----END of calculating the new para-----------
        
        %plot the modified vibrato
        modPatchVibratoArea = plotNewFeatureArea(data.vibratos(modIndex,:),data.axePitchTabVibrato);
        %modify the patch in patch list
        data.patchVibratoArea(modIndex) = modPatchVibratoArea;
        
        %higlight the selected vibrato
        plotHighlightFeatureArea(data.patchVibratoArea,modIndex,1);
    
        %plot the vibrato num in the listbox
        plotFeatureNum(data.vibratos,data.vibratoListBox);
        
        %show the highlighted num of vibrato in vibrato listbox
        data.vibratoListBox.Value = modIndex;
        
        %show individual vibrato in the sub axes
        plotPitchFeature(data.vibratosDetail, modIndex ,data.vibratoXaxisPara,data.axePitchTabVibratoIndi) 
        
        %show individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,modIndex ,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);   
    end
end

