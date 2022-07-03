function selectEdges(hObject,eventData)
%SELECTEDGES Select the onsets time point within a rectangle
% (to delete)
    global data;
    data.Bn.selectEdges.set('Enable','inactive');
    axe=data.axeOnsetOffsetStrength;
    rect = getrect(axe);%[xmin ymin max(x)-xmin max(y)-ymin]
    
    %----START of pitch point---------------
    if rect(3)==0 || rect(4)==0
        msgbox('Bad area selected');
    elseif ~(isfield(data,'onset')||isfield(data,'offset'))
        msgbox('No edge detected.');
    else
        if (isempty(data.onset)&&isempty(data.offset))
            msgbox('No edge detected.');
        else
        if ((axe.XLim(1)<=rect(1)&& rect(1)<=axe.XLim(2)) || (axe.XLim(1)<=rect(1)+rect(3) && rect(1)+rect(3)<=axe.XLim(2)))
            %different from that in pitch curve(PC is continuous)
            selected_edge=cell(1,2);
            if isfield(data,'onset')
                onset=data.onset*data.hop_length/data.fs;
                selected_edge{1}=logical((rect(1)<=onset).*(rect(1)+rect(3)>=onset));
            end
            if isfield(data,'offset')
                offset=data.offset*data.hop_length/data.fs;
                selected_edge{2}=logical((rect(1)<=offset).*(rect(1)+rect(3)>=offset));
            end
            
            if isempty(selected_edge{1}) && isempty(selected_edge{2})
                msgbox('No onset/offset selected');
            else
                %delete the existing result
                data.selected_edge=selected_edge;
                if isfield(data,'patchFeaturesPoint')
                    delete(data.patchFeaturesPoint);
                    data=rmfield(data,'patchFeaturesPoint');
                end
                if isfield(data,'onset_env')
                    if data.OnsetOffsetMethodChange.Value~=4
                        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
                    else
                        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);
                    end
                else
                    data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.axeOnsetOffsetStrength);%data.HD_offset_new
                end
            end
            set(data.patchFeaturesPoint(data.selected_edge{1},1),'Color',[1,0,1]); 
            if size(data.patchFeaturesPoint,2)==2
                set(data.patchFeaturesPoint(data.selected_edge{2},2),'Color',[1,0,1]);
            end
        else
            msgbox('Bad area selected')
        end
        end
    end
    data.Bn.selectEdges.set('Enable','on');
    %----END of Pitch Area setting------------ 
end

