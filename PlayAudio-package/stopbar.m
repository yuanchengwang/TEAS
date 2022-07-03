function stopbar(hObject,eventData)
global data;
delete(data.bar);
data=rmfield(data,'bar');
end