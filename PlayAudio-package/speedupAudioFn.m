function speedupAudioFn(hObject,eventData)
global data;
%list=[0.125,0.25,0.5,1,2];
if data.speedvalue.Value<2 && data.speedvalue.Value>=0.25
    data.speedvalue.Value=data.speedvalue.Value*2;
    data.speedvalue.String=['X',num2str(data.speedvalue.Value)];
end