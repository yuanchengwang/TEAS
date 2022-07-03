function getPortamentoFn(hObject,eventData)
%GETPORTAMENTOFN get portmaneto using HMM method
    global data;
    if ~isfield(data,'pitchVFree')
        ansOnset = questdlg('Warning: No vibrato free pitch. Run vibrato-free pitch first. Force to run the portamento detector?','Attention','Yes','No','No');
        if strcmp(ansOnset,'No')       
            return
        else
            data.pitchVFree=data.pitch;
        end
    end
    %clear portamento in case
    plotClearFeature('Portamento');
    h = waitbar(0,'Portamento detecting...');
    zero_position=data.pitchVFree>0;
    diff_zeros_position=diff(zero_position);
    down=find(diff_zeros_position==-1);
    up=find(diff_zeros_position==1)+1;
    if zero_position(1)==1
        segment(1,1)=1;
        segment(2:1+length(up),1)=up;
    else
        segment(:,1)=up;
    end
    if zero_position(end)==1
        segment(1:length(down),2)=down;
        segment(length(down)+1,2)=length(zero_position);
    else
        segment(:,2)=down;
    end
    segment=segment(diff(segment,[],2)>=10,:);
    for i=1:size(segment,1)
        data.pitchVFree(segment(i,1):segment(i,2)) = smooth(data.pitchVFree(segment(i,1):segment(i,2)),10);
    end
    plotPitch(data.pitchTime,data.pitchVFree,data.axePitchTabPortamento,0,1);
    %portamentos: [portamento start time:end time:duration]
    data.portamentos = portamentoDetectFunc(data.pitchTime,data.pitchVFree);
    data.portamentos(:,4) = 1;
    waitbar(50/100,h,sprintf('%d%% Portamento detecting...',50));
    %Get the individual portamento time and pitch vector 
    %portamentosDetail:[time from 0:pitch:orginal time]
    data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos,0);
    
    %remove the old portamentosDetailLogistic
    if isfield(data,'portamentosDetailLogistic') 
        data = rmfield(data,'portamentosDetailLogistic');
    end
    %Logistic modeling and get parameters
%     portamentosName = fieldnames(data.portamentosDetail);
%     fittedDataLogistic6 = zeros(size(portamentosName,1),6);
%     for i = 1:length(portamentosName)
%         portamentoXY = getfield(data.portamentosDetail, char(portamentosName(i)));
%         
%         portamentoX = portamentoXY(:,1);
%         portamentoY = freqToMidi(portamentoXY(:,2));
%         
%         [fittedPortamentoLogistic6,fittedGOFLogistic6(i)] = createGeneralLogistic6Fit(portamentoX,portamentoY);
%         fittedDataLogistic6(i,:) = coeffvalues(fittedPortamentoLogistic6);
%     end
%     
    waitbar(75/100,h,sprintf('%d%% Portamento detecting...',75));
    %plot the portamentos on the pitch curve
    if isfield(data,'patchPortamentoArea') 
        %if there are already some vibratos
        delete(data.patchPortamentoArea);
    end
    if isempty(data.portamentos)
        disp('No portamentos detected.');
        close(h);
        return
    end
    data.patchPortamentoArea =  plotFeaturesArea(data.portamentos,data.axePitchTabPortamento);
    
    %highlight the first portamento
    data.numPortamentoSelected = 1;
    plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);
    
    %plot the portamento num in the listbox
    plotFeatureNum(data.portamentos,data.portamentoListBox);
    
    %show the first portamento in vibrato listbox
    data.portamentoListBox.Value = data.numPortamentoSelected;
    
    %show the first portamento's X(time) range in the edit text
    data.portamentoXEdit.String=[num2str(data.portamentos(data.numPortamentoSelected,1)),'-',num2str(data.portamentos(data.numPortamentoSelected,2))];
    
    %show individual portamento in the sub axes
    plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
    
    close(h);
end

