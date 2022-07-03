function getMultitrackFn(hObject,eventData)
% GETMULTITRACKFN returns an interface to set the input onsets of each
% string.
global data;
%close 
if ~isfield(data,'f2')%Only one window can be open!
data.f2=figure('units','normalized','position',[0.5 0.5 0.3 0.3],'NumberTitle','Off',...
        'name','Multi-track paths','resize','on','menubar','figure','CloseRequestFcn',@closereq2);%the window size depends on the track number.

%Channels preset
uicontrol('Parent',data.f2,'Style','text','units','normalized','String','Tracks',...
    'Position', [0.1 0.83 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left'); 
uicontrol('Parent',data.f2,'Style','text','units','normalized','String','Current track',...
    'Position', [0.25 0.83 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left'); 
uicontrol('Parent',data.f2,'Style','text','units','normalized','String','Import onset tracks',...
    'Position', [0.5 0.83 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left'); 
uicontrol('Parent',data.f2,'Style','text','units','normalized','String','Priority:',...
    'Position', [0.1 0 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left'); 
data.TrackXaxisPara = uicontrol('Parent',data.f2, 'Style', 'popup','units','normalized','String',{'Selected track of onsets','Imported'}, ...
        'Position', [0.25 0.01 0.15 0.1],'HorizontalAlignment','left');
for i=1:data.track_nb
   uicontrol('Parent',data.f2,'Style','text','units','normalized','String',['Track ',num2str(i),':'],...
        'Position', [0.1 0.13+0.75/data.track_nb*(data.track_nb-i) 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left'); 
   data.bn.radiobn{i}=uicontrol('Parent',data.f2,'Style','radiobutton','units','normalized','Position', [0.3 0.15+0.75/data.track_nb*(data.track_nb-i) 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left','Callback',{@rdbn,i});
   data.bn.OnsetTrack{i}=uicontrol('Parent',data.f2,'Style','pushbutton','units','normalized','String','...','Position', [0.5 0.15+0.75/data.track_nb*(data.track_nb-i) 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left','Callback',{@importNoteTrack,i});
end
data.bn.radiobn{data.selectedtrack}.Value=1;
data.bn.test_plot_strum=uicontrol('Parent',data.f2,'Style','pushbutton','units','normalized','String','Test and plot onsets','Position', [0.5 0.02 0.3 0.1],'FontWeight','bold','HorizontalAlignment','left','Callback',@test_plot_strum);
else%stick the window to the top
    set(data.f2,'WindowStyle','modal');%Always top not this
    set(data.f2,'WindowStyle','normal');%Back to normal mode
end
end

function closereq2(hObject,eventData)
    global data;
    data=rmfield(data,'f2');
    data=rmfield(data,'TrackXaxisPara');
    if isempty(gcbf)
        if length(dbstack) == 1
            warning(message('MATLAB:closereq:ObsoleteUsage'));
        end
        close('force');
    else
        delete(gcbf);
    end
end