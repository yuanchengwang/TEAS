function changePortamentoType(hObject,eventData)
%change the type of pitch transition techniques: portamento, hammer-on, pull-off
global data;
if isfield(data,'portamentos')
    data.portamentos(data.numPortamentoSelected,4)=data.PortamentoType.Value;
end
end