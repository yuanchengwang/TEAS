function delOnsetFn(hObject,eventData)
%DELONSETFN Delete all the onset points and refresh the plot
    global data;
    if isfield(data,'onset')
        if isfield(data,'selected_edge')
           if iscell(data.selected_edge)
               if isempty(data.selected_edge{1})
                   msgbox('Only offsets selected, please press Delete Offset button.');
                   return
               else
                    data.onset(data.selected_edge{1})=[];
                    data=rmfield(data,'selected_edge');
               end
           else
               if data.selected_edge(2)==1%onset
                   data.onset(data.selected_edge(1))=[];
                   data=rmfield(data,'selected_edge');
               else%offset
                   msgbox('An offset point selected, please press Delete Offset button.');
                   return
               end
           end
       else
            ansOnset = questdlg('Warning: Comfirm to delete all Onset points?','Attention','Yes','No','No');
            switch ansOnset
            case 'Yes'
                data.onset=[];
            case 'No'
                return
            end
        end
    else
        ansOnset = questdlg('Warning: Comfirm to delete all Onset points?','Attention','Yes','No','No');
        switch ansOnset
        case 'Yes'
            data.onset=[];
        case 'No'
            return
        end
    end
    delete(data.patchFeaturesPoint);
    data=rmfield(data,'patchFeaturesPoint');
    if data.OnsetOffsetMethodChange.Value~=4
        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
    else
        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);
    end
end