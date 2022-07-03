function delPortamentoFn(hObject,eventData)
%DELPORTAMETOFN Summary of this function goes here
%   Detailed explanation goes here

    global data;
    
    if isempty(data.portamentos) == 0
        %delete the portamento time information
        data.portamentos(data.numPortamentoSelected,:) = [];
        %delete the portamento area patch in the plot
        delete(data.patchPortamentoArea(data.numPortamentoSelected));
        data.patchPortamentoArea(data.numPortamentoSelected) = [];
    %     %delete the portamento time and pitch vectors
    %     vibratoNames = fieldnames(data.portamentosDetail);
    %     data.portamentosDetail = rmfield(data.portamentosDetail,char(vibratoNames(data.numPortamentoSelected)));
        %Get the individual portamento time and pitch vector 
        %portamentosDetail:[time from 0:pitch:orginal time]
        data.portamentosDetail = getPassages(data.pitchTime,data.pitch,data.portamentos,0);
        
        
        %if the delelted portamento is the last one, then go to the last
        if (data.numPortamentoSelected == size(data.portamentos,1)+1)
            data.numPortamentoSelected = size(data.portamentos,1);
        end
        %plot the portamento num in the listbox
         plotFeatureNum(data.portamentos,data.portamentoListBox);
         
        %delete the last area 
        if isempty(data.portamentos)
            cla(data.axePitchTabPortamentoIndi);           
            data.portamentoXEdit.String=[];
            if isfield(data,'portamentosDetailLogistic')
                data=rmfield(data,'portamentosDetailLogistic');
            end
            for i=1:length(data.textPort)
                data.textPort(i).String=[];
            end 
            return
        end
        %higlight the selected portamento
        plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);
        
        %show the highlighted num of portamento in portamento listbox
        data.portamentoListBox.Value = data.numPortamentoSelected;
        
        %show the first portamento's X(time) range in the edit text
        data.portamentoXEdit.String=[num2str(data.portamentos(data.numPortamentoSelected,1)),'-',num2str(data.portamentos(data.numPortamentoSelected,2))];

        %show individual portamento in the sub axes
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
        
        %plot the portamneto statistics
        if isfield(data,'portamentosDetailLogistic') 
            plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected);
        end 
    end
end

