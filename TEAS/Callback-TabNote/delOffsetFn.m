function delOffsetFn(hObject,eventData)
%DELOFFSETFN Delete all the offset points and refresh the plot
    global data;
    if isfield(data,'offset')
        if isfield(data,'selected_edge')
            if iscell(data.selected_edge)
                if isempty(data.selected_edge{2})
                   msgbox('Only onset selected, please press Delete Onset button.');
                   return
                else
                   data.offset(data.selected_edge{2})=[];
                   data=rmfield(data,'selected_edge');
                end
            else
                if data.selected_edge(2)==2%offset
                   data.offset(data.selected_edge(1))=[];
                   data=rmfield(data,'selected_edge');
               else%offset
                   msgbox('An onset point selected, please press Delete Onset button.');
                   return
               end
            end
        else
            ansOnset = questdlg('Warning: Comfirm to delete all Offset points?','Attention','Yes','No','No');
            switch ansOnset
            case 'Yes'
                data.offset=[];
            case 'No'
                return
            end
        end
    else
        ansOffset = questdlg('Warning: Comfirm to delete all Offset points?','Attention','Yes','No','No');
        switch ansOffset
        case 'Yes'
            data.offset=[];
        case 'No'
            return
        end 
    end   
    delete(data.patchFeaturesPoint);
    data=rmfield(data,'patchFeaturesPoint');
    if data.OnsetOffsetMethodChange.Value==4
        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.log_energy,data.log_energy_time,data.axeOnsetOffsetStrength);
    else
        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
    end  
end