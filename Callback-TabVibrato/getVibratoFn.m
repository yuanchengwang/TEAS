function getVibratoFn(hObject,eventData)
%GETVIBRATO get the vibratos using FDM and plot vibratos
%   Detailed explanation goes here
    global data;
    frameCriterion = 5;
    %clear vibratos;
    plotClearFeature('Vibrato');%no inside
        
    %get the threshold for DT
    freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
    ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');
    
    freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
    ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
    
    %Get vibratos using FDM method
    %vibratos: [vibrato start time:end time:duration]
    method = get(data.methodVibratoChange,'Value');
    method1= get(data.methodVibratoDetectorChange,'Value');
    if method==1%FDM
        if ~isfield(data,'FDMoutput')%don't relaunch the FDM if it exists so as to speed up the vibrato detection, particularly for slider
            [data.FDMtime,data.FDMoutput,data.FDMPD,data.FDMPR] = FDMestimate(data.pitch,data.pitchTime);%DT is extracted %vibratoDetectFunc
        end
        %data.FDMoutput(:,1)=fillmissing(data.FDMoutput(:,1),'movmedian',3);
        %data.FDMoutput(:,2)=fillmissing(data.FDMoutput(:,2),'movmedian',3);
        %size(data.FDMoutput)
        if method1==1
            data.vibratos=DT(data.FDMoutput(:,1),data.FDMoutput(:,2),freqThresh,ampThresh,frameCriterion,data.FDMtime);
    %vibratoParametersFDMDT
        elseif method1==2%method1=power difference
            data.vibratos=postprocessing(data.FDMPD,10^(1-1/get(data.parameter,'Value')),frameCriterion,data.FDMtime);
        else%method1=power ratio
            data.vibratos=postprocessing(data.FDMPR,get(data.parameter,'Value'),frameCriterion,data.FDMtime);
        end
    elseif method==2%periodogram
        if ~isfield(data,'PERoutput')%don't relaunch the FDM if it exists so as to speed up the vibrato detection, particularly for slider
            [data.PERtime,data.PERoutput,data.PERPD,data.PERPR] = PERestimate(data.pitch,data.pitchTime);%DT is extracted %vibratoDetectFunc
        end
        if method1==1
            data.vibratos=DT(data.PERoutput(:,1),data.PERoutput(:,2),freqThresh,ampThresh,frameCriterion,data.PERtime);
    %vibratoParametersFDMDT
        elseif method1==2
            data.vibratos=postprocessing(data.PERPD,10^(1-1/get(data.parameter,'Value')),frameCriterion,data.PERtime);
        else%method1=ratio
            data.vibratos=postprocessing(data.PERPR,get(data.parameter,'Value'),frameCriterion,data.PERtime);
        end
    end
    if isempty(data.vibratos)
        disp('No vibrato detected')
        return
    end 
    %data.vibratos = NotePruning(data.vibratos,0.05);%0.25->0.15? more is
    %better, false positive is better than false negative!
    if data.CB.Auto_vibrato.Value && isfield(data,'onset') && isfield(data,'offset')
        if data.double_peak
            onset=data.onset(2:2:end)*data.hop_length/data.fs;
        else
            onset=data.onset*data.hop_length/data.fs;
        end
        offset=data.offset*data.hop_length/data.fs;
        if length(onset)~=length(offset)
            msgbox('Pluck number is not identical to that of offset.Correct the boundaries or cancel the ''boundary adaptied interval'' option');
            return
        else
            vibrato=[];
            for k=1:size(data.vibratos,1)%onset,offset,duration
                % choose the most overlapped note
                index1=find(data.vibratos(k,1)<=offset,1);
                index2=find(data.vibratos(k,2)<=onset,1)-1;
                vib_tmp=[onset(index1:index2)',offset(index1:index2)'-0.001,offset(index1:index2)'-0.001-onset(index1:index2)'];
                vibrato=[vibrato;vib_tmp];
            end
            %unique vibrato for a single note
            vibrato(logical([diff(vibrato(:,1))==0;0]),:)=[];
            data.vibratos=vibrato;
        end
    end
    %data.vibratos %printing only for DT
    
    %Get the individual vibrato time and pitch vector 
    %vibratosDetail:[time from 0:pitch:orginal time]
    data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);

    %----START of getting vibrato para-------
    %vibratosParaFDM: [vibrato rate:vibrato extent]
    thres=[min(freqThresh(2),10),min(ampThresh(2),4)];
    if method==1
        vibratosParaFDM = getVibratoParaFDM2(data.vibratos,data.FDMtime,data.FDMoutput,thres);
    elseif method==2
        vibratosParaFDM = getVibratoParaFDM2(data.vibratos,data.PERtime,data.PERoutput,thres);
    end
    %get vibrato rate, extent(using max-min method) vibrato sinusoid similarity for all passages
    vibratoNames = fieldnames(data.vibratosDetail);
    %vibratoParaMin: [rate, extent, std rate, std extent, SS]
    vibratoParaMaxMin = zeros(length(vibratoNames),5);%pitch based
    vibratosSS = zeros(length(vibratoNames),1);
    for i = 1:length(vibratoNames)
        vibratoTimePitch = getfield(data.vibratosDetail, char(vibratoNames(i)));
        %sinusoid similarity
        vibratoTimePitch=vibratoTimePitch(:,[1,2]);
        avgpitch=median(vibratoTimePitch(:,2)).*[2^(-1/4),2^(1/4)];%3 semitones
        vibratoTimePitch=vibratoTimePitch(vibratoTimePitch(:,2)<avgpitch(2) & vibratoTimePitch(:,2)>avgpitch(1),:);
        SS = vibratoShape(vibratoTimePitch);
        if SS>1
            vibratosSS(i)=0;
            vibratoParaMaxMin(i,:)=0;
            continue
        end
        vibratosSS(i)=SS;
        vibratoParaMaxMin(i,[1:4]) = vibratoRateExtent(vibratoTimePitch);
        vibratoParaMaxMin(i,5) = vibratosSS(i);
    end
    %add sinusoid similarity to the vibratosParaFDM ([rate:extent:SS])        
    vibratosParaFDM = [vibratosParaFDM,vibratosSS];

    %vibratosPara{1}from FDM
    %vibratosPara{1}from PER
    %vibratosPara{3}from Max-min
    if exist('vibratosParaFDM')
        data.vibratoPara{method,method1,1} = vibratosParaFDM;
    end
    if exist('vibratosParaPER')
        data.vibratoPara{method,method1,1} = vibratosParaPER;
    end
    data.vibratoPara{method,method1,2} = vibratoParaMaxMin;%change the parameter with the erea,
    %----END of getting vibrato para-------
    
    
    %plot the vibratos on the pitch curve
    data.patchVibratoArea =  plotFeaturesArea(data.vibratos,data.axePitchTabVibrato);
    
    data.vibratos(:,4)=1;%define the 
    %highlight the first vibrato
    data.numViratoSelected = 1;
    plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);
    
    %plot the vibrato num in the listbox
    plotFeatureNum(data.vibratos,data.vibratoListBox);
   
    %show the first vibrato in vibrato listbox
    data.vibratoListBox.Value = data.numViratoSelected;
    
    %show individual vibrato in the sub axes
    plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi)
    
    %show the first vibrato's X(time) range in the edit text
    data.vibratoXEdit.String=[num2str(data.vibratos(data.numViratoSelected,1)),'-',num2str(data.vibratos(data.numViratoSelected,2))];
    
    %show the first individual vibrato statistics
    plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
end

