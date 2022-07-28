%Transcription and Expressiveness Annotation System(TEAS)
%The Automatic Music Transcription and Expressive Feature Analysis Tool, Enhanced by Yuancheng WANG
function GUI_Main()%[] = 
    addpath(genpath(pwd)); %add all current subfolders to the search path
    global data;
    global protocol;
    if isfield(data,'f')
        msgbox('A single window can be opened, otherwise the data in previous window cannot be used.');
        return
    end
    data = parametersetting;
    protocol = protocolsetting;
    testParametersetting;
    warning off;
    
    %Create the figure
    data.f = figure('units','normalized','position',[0.02 0.12 0.75 0.8],'NumberTitle','Off',...
        'name','TEAS: Transcription and Expressiveness Annotation System','resize','on',...%Automatic Music Transcription and Expressive Feature Analysis 
        'menubar','figure','WindowButtonDownFcn',@mouseClick,'KeyPressFcn',@keyPressedFunction,'CloseRequestFcn',@closereq1);
    %set(gcf,'renderer','opengl');%Speed up with openGL(maybe GPU)
    data.currentTab = 'readAudio';  %Show the current tab name
    %creating the tabgroup and tabs
    data.tgroup = uitabgroup('Parent',data.f,'TabLocation','top','SelectionChangedFcn',@tabChangedCB);
    tabReadAudio = uitab('Parent',data.tgroup,'Title','Read Audio');
    tabPitch= uitab('Parent',data.tgroup,'Title','Pitch Detection');
    tabNote= uitab('Parent',data.tgroup,'Title','Note Detection');
    tabVibrato = uitab('Parent',data.tgroup,'Title','Vibrato Analysis');
    tabPortamento = uitab('Parent',data.tgroup,'Title','Sliding Analysis');
    tabTremolo=uitab('Parent',data.tgroup,'Title','Tremolo Analysis');
    tabStrumming=uitab('Parent',data.tgroup,'Title','Strumming Analysis');
    %tabOverall=uitab('Parent',data.tgroup,'Title','Overall Multitrack');
    tabSynMIDI=uitab('Parent',data.tgroup,'Title','Multitrack+MIDI');
    tabAbout = uitab('Parent',data.tgroup,'Title','About');
    
    %set the zoom in/out callback function
    zoomH = zoom;
    zoomH.ActionPostCallback = @plotZoomInPost;
    
    %define color
    colorDefine.addFeature = [0 0.6 0];
    colorDefine.deleteFeature = [0.6 0 0];
    colorDefine.foreground = [1 1 1];
    
    %----------START of tabReadAudio build-----------
    %create the readAudio button to tabReadAudio
    data.Bn.readAudio = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Read Audio','units','normalized', ...
        'Position', [0.875 0.85 0.1 0.1],'ForegroundColor',[1 0 0],'FontWeight','bold','Callback',@readAudioFn);
    data.Bn.recordAudio= uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Record Audio','units','normalized', ...
        'Position', [0.875 0.75 0.1 0.1],'ForegroundColor',[0 0.8 0],'FontWeight','bold','Callback',@recordAudioFn);
    
    uicontrol('Parent',tabReadAudio,'Style','text','units','normalized','String','Choose denoising method:',...
        'Position', [0.875 0.6 0.2 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.denoisingMethodChange = uicontrol('Parent', tabReadAudio, 'Style', 'popup','units','normalized','String',{'None','MMSE','Highpass'}, ...%,'MMSE(Auto)'
       'Position', [0.875 0.57 0.1 0.1],'HorizontalAlignment','left') ;
    
   %choose the noise area for denoising
    data.Bn.noiseCandidate = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Get noise candidate(s)','units','normalized', ...
        'Position', [0.875 0.58 0.1 0.05],'FontWeight','bold','FontSize',7,'Callback',@Candidate_noise_range);
    data.Bn.addNoiseArea = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Add/Change Noise Area','units','normalized', ...
        'Position', [0.875 0.53 0.1 0.05],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','FontSize',7,'ForegroundColor',colorDefine.foreground,'Callback',@addNoiseFn);
    data.Bn.deleteNoiseArea = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Delete Noise Area','units','normalized', ...
        'Position', [0.875 0.48 0.1 0.05],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','FontSize',7,'ForegroundColor',colorDefine.foreground,'Callback',@delNoiseFn);
    data.Bn.Denoising = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Denoise','units','normalized', ...
        'Position', [0.875 0.43 0.1 0.05],'FontWeight','bold','FontSize',7,'Callback',@denoisingFn);
    data.Bn.ImportDenoisedWave = uicontrol('Parent',tabReadAudio, 'Style', 'pushbutton', 'String', 'Import Denoised Wave','units','normalized', ...
        'FontSize',7,'Position', [0.875 0.28 0.1 0.1],'FontWeight','bold','Callback',@importDenoisedWaveFn);
    data.Bn.ExportDenoisedWaveAnnotation = uicontrol('Parent',tabReadAudio, 'Style', 'pushbutton', 'String', 'Export Denoised Wave','units','normalized', ...
        'FontSize',7,'Position', [0.875 0.18 0.1 0.1],'FontWeight','bold','Callback',@exportDenoisedWaveFn);
   
    %Audio manipulation buttons for audio
    playAudioBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Play','units','normalized', ...
        'Position', [0.25 0.5 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseAudioBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Pause','units','normalized', ...
        'Position', [0.35 0.5 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeAudioBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Resume','units','normalized', ...
        'Position', [0.45 0.5 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopAudioBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Stop','units','normalized', ...
        'Position', [0.55 0.5 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    playDenoisedWaveBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Play','units','normalized', ...
        'Position', [0.25 0.01 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,2});
    pauseDenoisedWaveBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Pause','units','normalized', ...
        'Position', [0.35 0.01 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeDenoisedWaveBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Resume','units','normalized', ...
        'Position', [0.45 0.01 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopDenoisedWaveBn = uicontrol('Parent', tabReadAudio, 'Style', 'pushbutton', 'String', 'Stop','units','normalized', ...
        'Position', [0.55 0.01 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    data.axeWave = axes('Parent',tabReadAudio,'position',[0.05 0.6 0.8 0.35]);
    data.axedenoisedWave = axes('Parent',tabReadAudio,'position',[0.05 0.1 0.8 0.35]);  
    %-----------END of tabReadAudio build------------
    
    %----------START of tabPitch build-----------
    %create the readAudio button to tabReadAudio
    data.Bn.getPitch = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Get Pitch Curve','units','normalized', ...
        'Position', [0.875 0.7 0.1 0.05],'FontWeight','bold','Callback',@getPitchCurveFn);
    data.Bn.selectPitches = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Select Pitch Area','units','normalized', ...
        'Position', [0.875 0.35 0.1 0.05],'FontWeight','bold','Callback',@selectPitchPoints);
    data.Bn.UpPitch = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Up','units','normalized', ...
        'Position',[0.875 0.25 0.05 0.1],'FontWeight','bold','Callback',@UpPitchFn);
    data.Bn.DownPitch = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Down','units','normalized', ...
        'Position',[0.925 0.25 0.05 0.1],'FontWeight','bold','Callback',@DownPitchFn);
    
    uicontrol('Parent',tabPitch,'Style','text','units','normalized','String','Choose pitch detection method:',...
        'Position', [0.875 0.75 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.pitchDetectionChange = uicontrol('Parent', tabPitch, 'Style', 'popup','units','normalized','String',{'Yin','Pyin(Matlab)','Pyin(Tony)','BNLS'}, ...
        'Position', [0.875 0.7 0.1 0.1],'HorizontalAlignment','left','Callback',@changePitchDetection) ;   
    uicontrol('Parent',tabPitch,'Style','text','units','normalized','String','Frequency Range(Hz):',...
        'Position', [0.875 0.85 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left');
    data.PitchFreThresEdit = uicontrol('Parent',tabPitch,'Style','edit','units','normalized','String','100-1320',...
        'Position', [0.875 0.87 0.05 0.05],'HorizontalAlignment','left');
    %data.Bn.refinementPitch = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Pitch Refinement','units','normalized', ...
        %'Position', [0.875 0.5 0.1 0.05],'FontWeight','bold','Callback',@refinement);
    %add the import/export pitch button
    data.Bn.importPitch = uicontrol('Parent',tabPitch, 'Style', 'pushbutton', 'String', 'Import Pitch Curve','units','normalized', ...
        'Position', [0.875 0.6 0.1 0.05],'FontWeight','bold','Callback',@importPitchCurveFn);
    data.Bn.exportPitch = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Export Pitch Curve','units','normalized', ...
        'Position', [0.875 0.65 0.1 0.05],'FontWeight','bold','Callback',@exportPitchCurveFn);
    
    %Modify the pitch point
    uicontrol('Parent',tabPitch,'Style','text','units','normalized','String','Y axis:',...
        'Position', [0.875 0.04 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.PitchXaxisPara = uicontrol('Parent',tabPitch, 'Style', 'popup','units','normalized','String',{'Frequency(Hz)','MIDI'}, ...
        'Position', [0.875 0.01 0.1 0.1],'HorizontalAlignment','left','Callback',@changePitchMetric);
    
    uicontrol('Parent',tabPitch,'Style','text','units','normalized','String','Single point modification:',...
        'Position', [0.875 0.14 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.PitchXMIDI = uicontrol('Parent', tabPitch, 'Style', 'text','units','normalized',...
        'Position', [0.855 0.14 0.02 0.04],'HorizontalAlignment','left');    
    data.PitchXEdit = uicontrol('Parent', tabPitch, 'Style', 'edit','units','normalized',...
        'Position', [0.875 0.15 0.05 0.04],'HorizontalAlignment','left','Callback',@MIDIplot);
    data.Bn.PitchMod = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
        'Position', [0.925 0.15 0.05 0.04],'FontWeight','bold','Callback',@modPitchFn);
    
    %Initialise the pitch detection method name
    data.pitchMethod = data.pitchDetectionChange.String(data.pitchDetectionChange.Value);
    data.axePitchWave = axes('Parent',tabPitch,'position',[0.05 0.6 0.8 0.35]);
    data.axePitchTabAudio = axes('Parent',tabPitch,'position',[0.05 0.1 0.8 0.35]);
    
    %audio manipulation buttons for pitch
    playPitchBn = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Play','units','normalized', ...
        'Position', [0.25 0.5 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,2});
    pausePitchBn = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Pause','units','normalized', ...
        'Position', [0.35 0.5 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumePitchBn = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Resume','units','normalized', ...
        'Position', [0.45 0.5 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopPitchBn = uicontrol('Parent', tabPitch, 'Style', 'pushbutton', 'String', 'Stop','units','normalized', ...
        'Position', [0.55 0.5 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %----------END of tabPitch build-----------
    
    %----------START of tabNote build-----------
    data.axeOnsetOffsetStrength = axes('Parent',tabNote,'position',[0.05 0.6 0.8 0.35]);
    %data.axePitch2note = axes('Parent',tabNote,'position',[0.05 0.1 0.8 0.35]);
    uicontrol('Parent',tabNote,'Style','text','units','normalized','String','Choose boundary detection method:',...
        'Position', [0.875 0.88 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.OnsetOffsetMethodChange = uicontrol('Parent', tabNote, 'Style', 'popup','units','normalized','String',{'SpecFlux','SuperFlux','ComplexFlux','logEnergy'}, ...
       'Position', [0.875 0.84 0.1 0.1],'HorizontalAlignment','left');%,'Callback',@changeOnsetOffsetMethod);
   if data.double_peak
       data.OnsetOffsetMethodChange.Value=4;%turn to logenergy frequency
   end
   data.Bn.EdgeDetection = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Onset Detection','units','normalized', ...
        'Position',[0.875 0.85 0.1 0.05],'FontWeight','bold','Callback',@OnsetDetectionFn);
    data.Bn.EdgeDetection = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Offset Detection','units','normalized', ...
        'Position',[0.875 0.8 0.1 0.05],'FontWeight','bold','Callback',@OffsetDetectionFn);
    data.Bn.addOnset = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Add Onset','units','normalized', ...
        'Position', [0.875 0.75 0.1 0.05],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addOnsetFn);
    data.Bn.delOnset = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Delete Onset','units','normalized', ...
        'Position', [0.875 0.7 0.1 0.05],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delOnsetFn); 
    data.Bn.addOffset = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Add Offset','units','normalized', ...
        'Position', [0.875 0.65 0.1 0.05],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addOffsetFn);
    data.Bn.delOffset = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Delete Offset','units','normalized', ...
        'Position', [0.875 0.6 0.1 0.05],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delOffsetFn); 
    data.Bn.selectEdges = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Select Boundary Area','units','normalized', ...
        'Position', [0.875 0.55 0.1 0.05],'FontWeight','bold','Callback',@selectEdges);
    data.CB.Auto_Edge=uicontrol('Parent',tabNote,'Style','checkbox','units','normalized','String','Onset Auto-adjustment',...
        'Position', [0.875 0.46 0.9 0.05],'HorizontalAlignment','left','value',1);%,'callback',@AutoEdgeActive);
    data.CB.plot_audio=uicontrol('Parent',tabNote,'Style','checkbox','units','normalized','String','Plot Audio',...
        'Position', [0.875 0.5 0.9 0.05],'HorizontalAlignment','left','value',1,'callback',@PlotEdgeAudio);

    %Panel: show the individual note.
    data.axePitchTabNoteIndi = axes('Parent',tabNote,'position',[0.25 0.12 0.6 0.4]);
    panelShowNoteIndi = uipanel('Parent',tabNote,'units','normalized','position',[0.05 0.00 0.15 0.55],'FontWeight','bold','title','Notes');
    data.noteListBox = uicontrol('Parent', panelShowNoteIndi, 'Style', 'listbox','units','normalized', ...
        'Position', [0.05 0.27 0.9 0.7],'Callback',@featureListBoxFn);
    uicontrol('Parent',panelShowNoteIndi,'Style','text','units','normalized','String','X axis:',...
        'Position', [0.05 0.16 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.noteXaxisPara = uicontrol('Parent', panelShowNoteIndi, 'Style', 'popup','units','normalized','String',{'Original Time','Normalized Time'}, ...
        'Position', [0.0 0.11 1 0.1],'HorizontalAlignment','left','Callback',@changeXaxisFeatureIndi); 
    
    %add time(x) range edit text/MIDI and modification button
    uicontrol('Parent',panelShowNoteIndi,'Style','text','units','normalized','String','X Range+MIDI+Velocity:',...
        'Position', [0.05 0.025 0.8 0.1],'FontWeight','bold','HorizontalAlignment','left');
    data.NoteXEdit = uicontrol('Parent', panelShowNoteIndi, 'Style', 'edit','units','normalized',...
        'Position', [0.0 0.005 0.7 0.07],'HorizontalAlignment','left');
    data.Bn.NoteMod = uicontrol('Parent', panelShowNoteIndi, 'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
        'Position', [0.7 0.005 0.3 0.07],'FontWeight','bold','Callback',@modNoteFn);
    
    uicontrol('Parent',tabNote,'Style','text','units','normalized','String','Choose pitch2note method:',...
        'Position', [0.875 0.37 0.1 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.pitch2noteMethodChange = uicontrol('Parent', tabNote, 'Style', 'popup','units','normalized','String',{'HMM baseline','HMM+note'}, ...%,'Hierarchic structure'
       'Position', [0.875 0.38 0.1 0.05],'HorizontalAlignment','left');
    data.Bn.pitch2note = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Pitch2Note','units','normalized', ...
        'Position', [0.875 0.35 0.1 0.05],'FontWeight','bold','Callback',@pitch2note);
    data.Bn.addNote = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Add Note','units','normalized', ...
        'Position', [0.875 0.3 0.1 0.05],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addNoteFn);
    data.Bn.delNote = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Delete Note','units','normalized', ...
        'Position', [0.875 0.25 0.1 0.05],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delNoteFn);
    %data.CB.auto_NoteEdge=uicontrol('Parent',tabNote,'Style','checkbox','units','normalized','String','Note edge auto-alignment',...
     %   'Position', [0.875 0.23 0.9 0.05],'HorizontalAlignment','left','Value',1);%,'callback',@AutoEdgeAdjustment);
    data.Bn.exportEdgeAnnotation = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Export Boundaries','units','normalized', ...
        'Position', [0.875 0.18 0.1 0.05],'FontWeight','bold','Callback',@exportEdgeFn);%���exportFeatureAnnoFn
    data.Bn.importEdge = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Import Boundaries','units','normalized', ...
        'Position',[0.875 0.13 0.1 0.05],'FontWeight','bold','Callback',@importEdgeFn);
    data.Bn.exportNoteAnnotation = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Export Notes','units','normalized', ...
        'Position', [0.875 0.08 0.1 0.05],'FontWeight','bold','Callback',@exportNoteFn);%���exportFeatureAnnoFn
    data.Bn.importNote = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Import Notes','units','normalized', ...
        'Position',[0.875 0.03 0.1 0.05],'FontWeight','bold','Callback',@importNoteFn);
    
    %
    playNoteBn = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Play Note','units','normalized', ...
        'Position', [0.25 0.02 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseNoteBn = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Pause Note','units','normalized', ...
        'Position', [0.35 0.02 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeNoteBn = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Resume Note','units','normalized', ...
        'Position', [0.45 0.02 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopNoteBn = uicontrol('Parent', tabNote, 'Style', 'pushbutton', 'String', 'Stop Note','units','normalized', ...
        'Position', [0.55 0.02 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %----------END of tabNote build-----------
    
    %----------START of tabVibrato build-----------   
    data.axePitchTabVibrato = axes('Parent',tabVibrato,'position',[0.05 0.6 0.8 0.35]);
    %Panel:get vibrato and parameters for FDM
    panelGetVibrato = uipanel('Parent',tabVibrato,'units','normalized','position',[0.88 0.55 0.1 0.4],'FontWeight','bold','title','Get Vibrato:');
    uicontrol('Parent',panelGetVibrato,'Style','text','units','normalized','String','Frequency Range(Hz):',...
        'Position', [0 0.85 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    data.vibFreThresEdit = uicontrol('Parent',panelGetVibrato,'Style','edit','units','normalized','String','4-9',...
        'Position', [0.6 0.9 0.4 0.1],'HorizontalAlignment','left');
    uicontrol('Parent',panelGetVibrato,'Style','text','units','normalized','String','Amplitude Range:',...
        'Position', [0 0.75 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    data.vibAmpThresEdit = uicontrol('Parent',panelGetVibrato,'Style','edit','units','normalized','String','0.04-inf',...
        'Position', [0.6 0.8 0.4 0.1],'HorizontalAlignment','left'); 
    
    %%%%%%slider for parameter adjustment%%%%%%%  
    uicontrol('Parent',panelGetVibrato,'Style','text','units','normalized','String','Parameter Trimming:',...
        'Position', [0 0.45 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    data.parameter = uicontrol('Parent',panelGetVibrato,'Style','slider','units','normalized','String','0.1',...
        'Position', [0.6 0.45 0.4 0.15],'HorizontalAlignment','left','Callback',@parameterFn); 
    uicontrol('Parent',panelGetVibrato,'Style','text','units','normalized','String','0          1',...
        'Position', [0.6 0.3 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    data.parametervalue =uicontrol('Parent',panelGetVibrato,'Style','text','units','normalized','String','0',...
        'Position', [0 0.3 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    
    data.Bn.getVibrato = uicontrol('Parent', panelGetVibrato, 'Style', 'pushbutton', 'String', 'Get Vibrato(s)','units','normalized', ...
        'Position', [0.05 0.7 0.9 0.1],'FontWeight','bold','Callback',@getVibratoFn);
    data.CB.Auto_vibrato=uicontrol('Parent',panelGetVibrato,'Style','checkbox','units','normalized','String','Boundary-adapted interval',...
        'Position', [0 0.6 1 0.1],'HorizontalAlignment','left','value',1);
    data.Bn.addVibrato = uicontrol('Parent', panelGetVibrato, 'Style', 'pushbutton', 'String', 'Add/Change Vibrato','units','normalized', ...
        'Position', [0.05 0.3 0.9 0.1],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addVibratoFn);
    data.Bn.delVibrato = uicontrol('Parent', panelGetVibrato, 'Style', 'pushbutton', 'String', 'Delete Vibrato','units','normalized', ...
        'Position', [0.05 0.2 0.9 0.1],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delVibratoFn);
    data.Bn.exportVibratoAnnotation = uicontrol('Parent', panelGetVibrato, 'Style', 'pushbutton', 'String', 'Export Area(s)','units','normalized', ...
        'Position', [0.05 0.1 0.9 0.1],'FontWeight','bold','Callback',@exportFeatureAnnoFn);
    data.Bn.importVibrato = uicontrol('Parent', panelGetVibrato, 'Style', 'pushbutton', 'String', 'Import Vibrato','units','normalized', ...
        'Position',[0.05 0. 0.9 0.1],'FontWeight','bold','Callback',@importVibratoFn);
    
    %Panel:show individual vibrato
    data.axePitchTabVibratoIndi = axes('Parent',tabVibrato,'position',[0.25 0.12 0.6 0.4]);
    panelShowVibratoIndi = uipanel('Parent',tabVibrato,'units','normalized','position',[0.05 0.00 0.15 0.55],'FontWeight','bold','title','Vibratos');
    data.vibratoListBox = uicontrol('Parent', panelShowVibratoIndi, 'Style', 'listbox','units','normalized', ...
        'Position', [0.05 0.27 0.9 0.7],'Callback',@featureListBoxFn);
    uicontrol('Parent',panelShowVibratoIndi,'Style','text','units','normalized','String','X axis:',...
        'Position', [0.05 0.16 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.vibratoXaxisPara = uicontrol('Parent', panelShowVibratoIndi, 'Style', 'popup','units','normalized','String',{'Original Time','Normalized Time'}, ...
        'Position', [0.0 0.11 1 0.1],'HorizontalAlignment','left','Callback',@changeXaxisFeatureIndi);  
   
    %add time(x) range edit text and modification button
    uicontrol('Parent',panelShowVibratoIndi,'Style','text','units','normalized','String','X Range:',...
        'Position', [0.05 0.025 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.vibratoXEdit = uicontrol('Parent', panelShowVibratoIndi, 'Style', 'edit','units','normalized',...
        'Position', [0.0 0.005 0.55 0.07],'HorizontalAlignment','left');
    data.Bn.vibratoMod = uicontrol('Parent', panelShowVibratoIndi, 'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
        'Position', [0.55 0.005 0.3 0.07],'FontWeight','bold','Callback',@modVibratoFn);
    
    %Panel:show individual vibrato statistics
    panelShowVibratoStat = uipanel('Parent',tabVibrato,'units','normalized','position',[0.88 0.02 0.1 0.5],'FontWeight','bold','title','Statistics');
    
    %show vibrato para text list
    vibParaName = {'Rate (Hz):','Extent (Semitone):','Sinusoid Similarity:'};
    for i = 1:length(vibParaName)
        uicontrol('Parent',panelShowVibratoStat,'Style','text','units','normalized','String',vibParaName{i},...
        'Position', [0 0.85-0.15*(i-1) 1 0.1],'FontWeight','bold','HorizontalAlignment','left');    
        data.textVib(i,1) = uicontrol('Parent',panelShowVibratoStat,'Style','text','units','normalized','String',[],...
        'Position', [0 0.8-0.15*(i-1) 1 0.08],'HorizontalAlignment','left');
    end
    uicontrol('Parent',panelShowVibratoStat,'Style','text','units','normalized','String','Type:',...
        'Position', [0 0.43 1 0.08],'FontWeight','bold','HorizontalAlignment','left');
    data.VibratoType = uicontrol('Parent', panelShowVibratoStat, 'Style', 'popup','units','normalized','String',{'Vibrato','Trill','Bending'}, ...
        'Position', [0 0.38 1 0.08],'HorizontalAlignment','left','Callback',@changeVibratoType);
    uicontrol('Parent',panelShowVibratoStat,'Style','text','units','normalized','String','Method:',...
        'Position', [0 0.29 1 0.08],'FontWeight','bold','HorizontalAlignment','left');
    data.methodVibratoChange = uicontrol('Parent', panelShowVibratoStat, 'Style', 'popup','units','normalized','String',{'FDM','Periodogram'}, ...
        'Position', [0 0.24 1 0.08],'HorizontalAlignment','left','Callback',@changeMethodVibratoParaFn);
    data.methodVibratoDetectorChange = uicontrol('Parent', panelShowVibratoStat, 'Style', 'popup','units','normalized','String',{'Decision Tree','Power Difference','Power Ratio'}, ...
        'Position', [0 0.16 1 0.08],'HorizontalAlignment','left');%,'Callback',@changeMethodVibratoDetectorParaFn);
    data.methodParameterChange = uicontrol('Parent', panelShowVibratoStat, 'Style', 'popup','units','normalized','String',{'Mean','Max-min'}, ...
        'Position', [0 0.08 1 0.08],'HorizontalAlignment','left');%,'Callback',@changeMethodVibratoDetectorParaFn);
    data.Bn.exportVibratoStatistics = uicontrol('Parent', panelShowVibratoStat, 'Style', 'pushbutton', 'String', 'Export Parameters','units','normalized', ...
        'Position', [0 0.0 1 0.08],'FontWeight','bold','Callback',@exportAllFeatureParaFn);
    
    %audio manipulation buttons for vibrato
    playVibratoBn = uicontrol('Parent', tabVibrato, 'Style', 'pushbutton', 'String', 'Play Vibrato','units','normalized', ...
        'Position', [0.25 0.02 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseVibratoBn = uicontrol('Parent', tabVibrato, 'Style', 'pushbutton', 'String', 'Pause Vibrato','units','normalized', ...
        'Position', [0.35 0.02 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeVibratoBn = uicontrol('Parent', tabVibrato, 'Style', 'pushbutton', 'String', 'Resume Vibrato','units','normalized', ...
        'Position', [0.45 0.02 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopVibratoBn = uicontrol('Parent', tabVibrato, 'Style', 'pushbutton', 'String', 'Stop Vibrato','units','normalized', ...
        'Position', [0.55 0.02 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %-----------END of tabVibrato build------------    

    %----------START of tabPortamento build-----------
    data.axePitchTabPortamento = axes('Parent',tabPortamento,'position',[0.05 0.6 0.8 0.35]);
    %Panel:get portamentos
    panelGetPortamento = uipanel('Parent',tabPortamento,'units','normalized','position',[0.88 0.55 0.1 0.4],'FontWeight','bold','title','Get Sliding:');
    data.getVibratoFreePitchBn = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Vibrato-free Pitch','units','normalized', ...
        'Position', [0.05 0.9 0.9 0.1],'FontWeight','bold','Callback',@getVFreePitchFn);
    data.Bn.getPortamento = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Get Sliding(s)','units','normalized', ...
        'Position', [0.05 0.8 0.9 0.1],'FontWeight','bold','Callback',@getPortamentoFn);

    data.Bn.addPortamento = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Add Sliding','units','normalized', ...
        'Position', [0.05 0.35 0.9 0.1],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addPortamentoFn);
    data.Bn.delPortamento = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Delete Sliding','units','normalized', ...
        'Position', [0.05 0.25 0.9 0.1],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delPortamentoFn);
    data.Bn.exportPortamentoAnnotation = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Export Area(s)','units','normalized', ...
        'Position', [0.05 0.15 0.9 0.1],'FontWeight','bold','Callback',@exportFeatureAnnoFn);%exportFeatureAnnoFn
    data.Bn.importPortamento = uicontrol('Parent', panelGetPortamento, 'Style', 'pushbutton', 'String', 'Import Sliding','units','normalized', ...
        'Position',[0.05 0.05 0.9 0.1],'FontWeight','bold','Callback',@importPortamentoFn);
    
    %Panel:show individual portamento
    data.axePitchTabPortamentoIndi = axes('Parent',tabPortamento,'position',[0.25 0.12 0.6 0.4]);
    panelShowPortamentoIndi = uipanel('Parent',tabPortamento,'units','normalized','position',[0.05 0.00 0.15 0.55],'FontWeight','bold','title','Slidings');
    data.portamentoListBox = uicontrol('Parent', panelShowPortamentoIndi, 'Style', 'listbox','units','normalized', ...
        'Position', [0.05 0.27 0.9 0.7],'Callback',@featureListBoxFn) ;  
    uicontrol('Parent',panelShowPortamentoIndi,'Style','text','units','normalized','String','X axis:',...
        'Position', [0.05 0.16 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.portamentoXaxisPara = uicontrol('Parent', panelShowPortamentoIndi, 'Style', 'popup','units','normalized','String',{'Original Time','Normalized Time'}, ...
        'Position', [0.0 0.11 1 0.1],'HorizontalAlignment','left','Callback',@changeXaxisFeatureIndi) ;   
     %add time(x) range edit text and modification button
    uicontrol('Parent',panelShowPortamentoIndi,'Style','text','units','normalized','String','X Range:',...
        'Position', [0.05 0.025 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.portamentoXEdit = uicontrol('Parent', panelShowPortamentoIndi, 'Style', 'edit','units','normalized',...
        'Position', [0.0 0.005 0.55 0.07],'HorizontalAlignment','left');
    data.Bn.PortamentoMod = uicontrol('Parent', panelShowPortamentoIndi, 'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
        'Position', [0.55 0.005 0.3 0.07],'FontWeight','bold','Callback',@modPortamentoFn);
    %Panel:show individual portamento statistics
    panelShowPortamentoStat = uipanel('Parent',tabPortamento,'units','normalized','position',[0.88 0.02 0.1 0.5],'FontWeight','bold','title','Statistics');
    
    %show portamento para text list
    uicontrol('Parent',panelShowPortamentoStat,'Style','text','units','normalized','String','MIDI scale',...
    'Position', [0 0.9 0.9 0.1],'FontWeight','bold','HorizontalAlignment','left');  
    portParaName = {'A','B','G','L','M','U'};
    for i = 1:length(portParaName)
        uicontrol('Parent',panelShowPortamentoStat,'Style','text','units','normalized','String',[portParaName{i},':'],...
        'Position', [0 0.9-0.1*i 0.2 0.1],'FontWeight','bold','HorizontalAlignment','left');        
        data.textPort(i,1) = uicontrol('Parent',panelShowPortamentoStat,'Style','text','units','normalized','String',[],...
        'Position', [0.2 0.9-0.1*i 0.6 0.1],'HorizontalAlignment','left');  
    end
    uicontrol('Parent',panelShowPortamentoStat,'Style','text','units','normalized','String','Type:',...
        'Position', [0 0.22 1 0.08],'FontWeight','bold','HorizontalAlignment','left'); 
    data.PortamentoType = uicontrol('Parent', panelShowPortamentoStat, 'Style', 'popup','units','normalized','String',{'Slide','Slide-in','Slide-out'}, ...%,'Legato'
        'Position', [0 0.16 1 0.08],'HorizontalAlignment','left','Callback',@changePortamentoType);
    data.Bn.Logistic = uicontrol('Parent', panelShowPortamentoStat, 'Style', 'pushbutton', 'String', 'Logistic Model','units','normalized', ...
        'Position', [0 0.08 1 0.08],'FontWeight','bold','Callback',@applyLogisticToAllFn);    
    data.Bn.exportPortamentoStatistics = uicontrol('Parent', panelShowPortamentoStat, 'Style', 'pushbutton', 'String', 'Export Parameters','units','normalized', ...
        'Position', [0 0.0 1 0.08],'FontWeight','bold','Callback',@exportAllFeatureParaFn);
    
    %audio manipulation buttons for portamento
    playPortamentoBn = uicontrol('Parent', tabPortamento, 'Style', 'pushbutton', 'String', 'Play Sliding','units','normalized', ...
        'Position', [0.25 0.02 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pausePortamentoBn = uicontrol('Parent', tabPortamento, 'Style', 'pushbutton', 'String', 'Pause Sliding','units','normalized', ...
        'Position', [0.35 0.02 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumePortamentoBn = uicontrol('Parent', tabPortamento, 'Style', 'pushbutton', 'String', 'Resume Sliding','units','normalized', ...
        'Position', [0.45 0.02 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopPortamentoBn = uicontrol('Parent', tabPortamento, 'Style', 'pushbutton', 'String', 'Stop Sliding','units','normalized', ...
        'Position', [0.55 0.02 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %-----------END of tabPortamento build------------
    
    %----------START of Tremolo build-----------
    data.axeWaveTabTremolo = axes('Parent',tabTremolo,'position',[0.05 0.6 0.8 0.35]);
    %Panel:get portamentos
    panelGetTremolo = uipanel('Parent',tabTremolo,'units','normalized','position',[0.88 0.55 0.1 0.4],'FontWeight','bold','title','Get Tremolo:');
    
%     uicontrol('Parent',panelGetTremolo,'Style','text','units','normalized','String','Frequency Range(Hz):',...
%         'Position', [0 0.9 0.6 0.1],'FontWeight','bold','HorizontalAlignment','left');
%     data.treFreThresEdit = uicontrol('Parent',panelGetTremolo,'Style','edit','units','normalized','String','4-20',...
%         'Position', [0.6 0.9 0.4 0.1],'HorizontalAlignment','left');
%     uicontrol('Parent',panelGetTremolo,'Style','text','units','normalized','String','Dynamic ratio:',...
%         'Position', [0 0.8 0.6 0.1],'FontWeight','bold','HorizontalAlignment','left');
%     data.treAmpThresEdit = uicontrol('Parent',panelGetTremolo,'Style','edit','units','normalized','String','0.001-1',...
%         'Position', [0.6 0.8 0.4 0.1],'HorizontalAlignment','left');
    uicontrol('Parent',panelGetTremolo,'Style','text','units','normalized','String','Choose Method:',...
        'Position', [0 0.85 0.4 0.1],'FontWeight','bold','HorizontalAlignment','left');%[0 0.7 0.4 0.1]
    data.changeTremoloMethod = uicontrol('Parent', panelGetTremolo, 'Style', 'popup','units','normalized','String',{'logEnergy','SpecFlux','SpecSlope'}, ...%,'Periodogram','RTPA','L1+L2','FDM'
        'Position', [0.4 0.84 0.6 0.1],'HorizontalAlignment','left');%,'Callback',@changeTremoloMethod[0.4 0.69 0.6 0.1]
    data.Bn.getTremolo = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Get Tremolo(s)','units','normalized', ...
        'Position', [0.05 0.5 0.9 0.1],'FontWeight','bold','Callback',@getTremoloFn);
    data.Bn.CandidateTremolo = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Candidate Notes','units','normalized', ...
        'Position', [0.05 0.65 0.9 0.1],'FontWeight','bold','Callback',@CandidateTremoloFn);%[0.05 0.65 0.9 0.1]
    %data.CB.PTfree=uicontrol('Parent',panelGetTremolo,'Style','checkbox','units','normalized','String','Vib/Sliding-free Notes',...
        %'Position', [0.05 0.35 0.9 0.1],'HorizontalAlignment','left','Value',0); 
    %data.CB.Auto_tremolo=uicontrol('Parent',panelGetTremolo,'Style','checkbox','units','normalized','String','Note Auto-adjustment',...
    %    'Position', [0.05 0.32 0.9 0.08],'HorizontalAlignment','left','Value',1);
%     data.Bn.addTremolo = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Add Tremolo','units','normalized', ...
%         'Position', [0.05 0.3 0.9 0.1],'BackgroundColor',colorDefine.addFeature,...
%         'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addTremoloFn);
%     data.Bn.delTremolo = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Delete Tremolo','units','normalized', ...
%         'Position', [0.05 0.2 0.9 0.1],'BackgroundColor',colorDefine.deleteFeature,...
%         'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delTremoloFn);
    data.Bn.exportTremoloAnnotation = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Export Area(s)+Plucks','units','normalized', ...
        'Position', [0.05 0.2 0.9 0.1],'FontWeight','bold','Callback',@exportFeatureAnnoFn);%exportFeatureAnnoFn
    data.Bn.importTremolo = uicontrol('Parent', panelGetTremolo, 'Style', 'pushbutton', 'String', 'Import Tremolo','units','normalized', ...
        'Position',[0.05 0.05 0.9 0.1],'FontWeight','bold','Callback',@importTremoloFn);
    
    %Panel:show individual tremolo
    data.axeWaveTabTremoloIndi = axes('Parent',tabTremolo,'position',[0.25 0.12 0.6 0.4]);
    panelShowTremoloIndi = uipanel('Parent',tabTremolo,'units','normalized','position',[0.05 0.00 0.15 0.55],'FontWeight','bold','title','Candidate Notes');
    data.tremoloListBox = uicontrol('Parent', panelShowTremoloIndi, 'Style', 'listbox','units','normalized', ...
        'Position', [0.05 0.17 0.9 0.8],'Callback',@featureListBoxFn) ;  
    uicontrol('Parent',panelShowTremoloIndi,'Style','text','units','normalized','String','X axis:',...
        'Position', [0.05 0.06 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.tremoloXaxisPara = uicontrol('Parent', panelShowTremoloIndi, 'Style', 'popup','units','normalized','String',{'Original Time','Normalized Time'}, ...
        'Position', [0.0 0.01 1 0.1],'HorizontalAlignment','left','Callback',@changeXaxisFeatureIndi) ;   
    
    %add time(x) range edit text and modification button
    %uicontrol('Parent',panelShowTremoloIndi,'Style','text','units','normalized','String','X Range:',...
    %    'Position', [0.05 0.025 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    %data.tremoloXEdit = uicontrol('Parent', panelShowTremoloIndi, 'Style', 'edit','units','normalized',...
    %    'Position', [0.0 0.005 0.55 0.07],'HorizontalAlignment','left');
    %data.Bn.TremoloMod = uicontrol('Parent',panelShowTremoloIndi,'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
     %   'Position',[0.55 0.005 0.3 0.07],'FontWeight','bold','Callback',@modTremoloFn);
    %Panel:show individual portamento statistics
    panelShowTremoloStat = uipanel('Parent',tabTremolo,'units','normalized','position',[0.88 0.07 0.1 0.45],'FontWeight','bold','title','Statistics');
    
    %show tremolo para text list
%     uicontrol('Parent',panelShowTremoloStat,'Style','text','units','normalized','String','MIDI scale',...
%     'Position', [0 0.9 0.9 0.1],'FontWeight','bold','HorizontalAlignment','left');  
    %Parameter
    data.treParaName = {'Strength(Initial):','Pluck No.:','Rate(Hz):'};%,'Dynamic Trend','Dynamic Uniformity:','Speed Uniformity:'
    for i = 1:length(data.treParaName)
        uicontrol('Parent',panelShowTremoloStat,'Style','text','units','normalized','String',data.treParaName{i},...
        'Position', [0 0.85-0.15*(i-1) 1 0.15],'FontWeight','bold','HorizontalAlignment','left');    
        data.textTremolo(i,1) = uicontrol('Parent',panelShowTremoloStat,'Style','text','units','normalized','String',[],...
        'Position', [0 0.85-0.15*(i-1) 1 0.1],'HorizontalAlignment','left');
    end
    uicontrol('Parent',panelShowTremoloStat,'Style','text','units','normalized','String','Note types:',...
        'Position', [0 0.4 1 0.15],'FontWeight','bold','HorizontalAlignment','left'); 
    data.TremoloType = uicontrol('Parent',panelShowTremoloStat, 'Style', 'popup','units','normalized','String',{'Normal','Wheel','Rolling','Shaking'}, ...
        'Position', [0 0.4 1 0.1],'HorizontalAlignment','left','Callback',@changeTremoloType);
    %data.Bn.ModNoteClass = uicontrol('Parent', panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Class Change','units','normalized', ...
        %'Position', [0 0.15 1 0.1],'FontWeight','bold','Callback',@ModNoteClassFn);
    
%     data.Bn.Logistic = uicontrol('Parent', panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Logistic Model','units','normalized', ...
%         'Position', [0 0.15 1 0.1],'FontWeight','bold','Callback',@applyLogisticToAllFn); 
    data.CB.Auto_pluck=uicontrol('Parent',panelShowTremoloStat,'Style','checkbox','units','normalized','String','Pluck Auto-adjustment',...
        'Position', [0 0.35 1 0.05],'HorizontalAlignment','left','value',1);
    data.Bn.addPluck = uicontrol('Parent',panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Add Pluck','units','normalized', ...
        'Position', [0 0.25 1 0.1],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addPluckFn);
    data.Bn.delPluck = uicontrol('Parent',panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Delete Pluck','units','normalized', ...
        'Position', [0 0.15 1 0.1],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delPluckFn);
    data.Bn.exportTremoloStatistics = uicontrol('Parent',panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Export Parameters','units','normalized', ...
        'Position', [0 0.05 1 0.1],'FontWeight','bold','Callback',@exportAllFeatureParaFn);
    %data.Bn.importTremoloStatistics = uicontrol('Parent',panelShowTremoloStat, 'Style', 'pushbutton', 'String', 'Import Plucks','units','normalized', ...
    %    'Position', [0 0.0 1 0.1],'FontWeight','bold','Callback',@importPluckFn);
    %audio manipulation buttons for tremolo
    playTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Play Tremolo','units','normalized', ...
        'Position', [0.25 0.02 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Pause Tremolo','units','normalized', ...
        'Position', [0.35 0.02 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Resume Tremolo','units','normalized', ...
        'Position', [0.45 0.02 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Stop Tremolo','units','normalized', ...
        'Position', [0.55 0.02 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    speedupTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Speed Up','units','normalized', ...
        'Position', [0.65 0.02 0.1 0.05],'FontWeight','bold','Callback',@speedupAudioFn);
    speeddownTremoloBn = uicontrol('Parent', tabTremolo, 'Style', 'pushbutton', 'String', 'Speed Down','units','normalized', ...
        'Position', [0.75 0.02 0.1 0.05],'FontWeight','bold','Callback',@speeddownAudioFn);
    data.speedvalue =uicontrol('Parent',tabTremolo,'Style','text','units','normalized','String','X 1','Value',1,...
        'Position', [0.85 0.02 0.1 0.05],'FontWeight','bold','HorizontalAlignment','left');
    %----------END of tremolo build-----------
    
    %----------START of tabStrumming build-----------
    data.axeTabStrumming = axes('Parent',tabStrumming,'position',[0.05 0.6 0.8 0.35]);
    %Panel:get strums
    panelGetStrumming = uipanel('Parent',tabStrumming,'units','normalized','position',[0.88 0.55 0.1 0.4],'FontWeight','bold','title','Get Strumming:');
    data.getMultitrackBn = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Multi-track Paths','units','normalized', ...
        'Position', [0.05 0.9 0.9 0.1],'FontWeight','bold','Callback',@getMultitrackFn);
    data.Bn.getStrumming = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Get Strumming(s)','units','normalized', ...
        'Position', [0.05 0.8 0.9 0.1],'FontWeight','bold','Callback',@getStrummingFn);

    data.Bn.addStrumming= uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Add Strumming','units','normalized', ...
        'Position', [0.05 0.45 0.9 0.1],'BackgroundColor',colorDefine.addFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@addStrummingFn);
    data.Bn.delStrumming = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Delete Strumming','units','normalized', ...
        'Position', [0.05 0.35 0.9 0.1],'BackgroundColor',colorDefine.deleteFeature,...
        'FontWeight','bold','ForegroundColor',colorDefine.foreground,'Callback',@delStrummingFn);
    data.Bn.exportStrummingAnnotation = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Export Area(s)','units','normalized', ...
        'Position', [0.05 0.25 0.9 0.1],'FontWeight','bold','Callback',@exportFeatureAnnoFn);
    data.Bn.importStrumming = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Import Strumming','units','normalized', ...
        'Position',[0.05 0.15 0.9 0.1],'FontWeight','bold','Callback',@importStrummingFn);
    data.Bn.importStrummingAudio = uicontrol('Parent', panelGetStrumming, 'Style', 'pushbutton', 'String', 'Import Audio','units','normalized', ...
        'Position',[0.05 0.05 0.9 0.1],'FontWeight','bold','Callback',@importDenoisedWaveFn);
    
    %Panel:show individual strumming
    data.axeTabStrummingIndi = axes('Parent',tabStrumming,'position',[0.25 0.12 0.6 0.4]);
    panelShowStrummingIndi = uipanel('Parent',tabStrumming,'units','normalized','position',[0.05 0.00 0.15 0.55],'FontWeight','bold','title','Strummings');
    data.StrummingListBox = uicontrol('Parent', panelShowStrummingIndi, 'Style', 'listbox','units','normalized', ...
        'Position', [0.05 0.27 0.9 0.7],'Callback',@featureListBoxFn);
    uicontrol('Parent',panelShowStrummingIndi,'Style','text','units','normalized','String','X axis:',...
        'Position', [0.05 0.16 0.5 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.StrumXaxisPara = uicontrol('Parent', panelShowStrummingIndi, 'Style', 'popup','units','normalized','String',{'Original Time','Normalized Time'}, ...
        'Position', [0.0 0.11 1 0.1],'HorizontalAlignment','left','Callback',@changeXaxisFeatureIndi) ;   
     %add time(x) range edit text and modification button
    uicontrol('Parent',panelShowStrummingIndi,'Style','text','units','normalized','String','X Range:',...%+Velocity
        'Position', [0.05 0.025 0.8 0.1],'FontWeight','bold','HorizontalAlignment','left')
    data.StrumXEdit = uicontrol('Parent', panelShowStrummingIndi, 'Style', 'edit','units','normalized',...
        'Position', [0.0 0.005 0.55 0.07],'HorizontalAlignment','left');
    data.Bn.StrummingMod = uicontrol('Parent', panelShowStrummingIndi, 'Style', 'pushbutton', 'String', 'Modify','units','normalized', ...
        'Position', [0.55 0.005 0.3 0.07],'FontWeight','bold','Callback',@modStrummingFn);
    %Panel:show individual strumming statistics
    panelShowStrummingStat = uipanel('Parent',tabStrumming,'units','normalized','position',[0.88 0.07 0.1 0.45],'FontWeight','bold','title','Statistics');
    
    %show strumming para text list
    %uicontrol('Parent',panelShowStrummingStat,'Style','text','units','normalized','String','MIDI scale',...
    %'Position', [0 0.9 0.9 0.1],'FontWeight','bold','HorizontalAlignment','left');  
    data.strumTypes={'Up Strum','Up-tremble Strum','Up-bass Strum','Down Strum','Down-tremble Strum','Down-bass Strum','Up Arpeggio','Up-tremble Arpeggio','Up-bass Arpeggio','Down Arpeggio','Down-tremble Arpeggio','Down-bass Arpeggio','Rasgueado'};
    portParaName2 = {'Rate','Start/End strings','Direction','Types'};
    for i = 1:length(portParaName2)
        uicontrol('Parent',panelShowStrummingStat,'Style','text','units','normalized','String',[portParaName2{i},':'],...
        'Position', [0 0.85-0.2*(i-1) 1 0.15],'FontWeight','bold','HorizontalAlignment','left');        
        data.textPortStrumming(i,1) = uicontrol('Parent',panelShowStrummingStat,'Style','text','units','normalized','String',[],...
        'Position', [0 0.85-0.2*(i-1) 1 0.1],'HorizontalAlignment','left');  
    end   
    data.StrummingType = uicontrol('Parent', panelShowStrummingStat, 'Style', 'popup','units','normalized','String',data.strumTypes, ...
        'Position', [0 0.25 1 0.1],'HorizontalAlignment','left','Callback',@changeStrummingType);
    data.Bn.exportStrummingStatistics = uicontrol('Parent', panelShowStrummingStat, 'Style', 'pushbutton', 'String', 'Export Parameters','units','normalized', ...
        'Position', [0 0.05 1 0.1],'FontWeight','bold','Callback',@exportAllFeatureParaFn);
    
    %audio manipulation buttons for strumming
    playStrummingBn = uicontrol('Parent', tabStrumming, 'Style', 'pushbutton', 'String', 'Play Strumming','units','normalized', ...
        'Position', [0.25 0.02 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseStrummingBn = uicontrol('Parent', tabStrumming, 'Style', 'pushbutton', 'String', 'Pause Strumming','units','normalized', ...
        'Position', [0.35 0.02 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeStrummingBn = uicontrol('Parent', tabStrumming, 'Style', 'pushbutton', 'String', 'Resume Strumming','units','normalized', ...
        'Position', [0.45 0.02 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopStrummingBn = uicontrol('Parent', tabStrumming, 'Style', 'pushbutton', 'String', 'Stop Strumming','units','normalized', ...
        'Position', [0.55 0.02 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %-----------END of tabStrumming build------------
    
    %----------START of Overall multitrack build-----------
    %data.axeTabOverall= axes('Parent',tabOverall,'position',[0.05 0.6 0.8 0.35]);
    %-----------END of Overall multitrack build------------
    
    %----------START of Multitrack+MIDI build-----------
    data.axeTabSynMIDI = axes('Parent',tabSynMIDI,'position',[0.05 0.6 0.92 0.35]);
    
    %Panel for CC setting
    panelMIDI = uipanel('Parent',tabSynMIDI,'units','normalized','position',[0.85 0.05 0.13 0.4],'FontWeight','bold','title','MIDI Setting:');
    uicontrol('Parent',panelMIDI,'Style','text','units','normalized','String','MIDI Export Mode:',...
        'Position', [0 0.3 0.9 0.15],'FontWeight','bold','HorizontalAlignment','left');
    data.ChangeOutputMode = uicontrol('Parent',panelMIDI, 'Style', 'popup','units','normalized','String',{'All-track Notes','Separated Track Notes+Selected Non-Strum Techniques','MIDI Polyphonic Expression (MPE)'}, ...
        'Position', [0 0.22 1 0.15],'HorizontalAlignment','left');%,'Callback',@ChangeOutputMode);
    %uicontrol('Parent',panelMIDI,'Style','text','units','normalized','String','Frequency Range(Hz):',...
    %    'Position', [0 0.8 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    %data.MIdIFreThresEdit = uicontrol('Parent',panelMIDI,'Style','edit','units','normalized','String','4-9',...
    %    'Position', [0.6 0.8 0.4 0.15],'HorizontalAlignment','left');
    %uicontrol('Parent',panelMIDI,'Style','text','units','normalized','String','Amplitude Range:',...
    %    'Position', [0 0.65 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    %data.MIDIAmpThresEdit = uicontrol('Parent',panelMIDI,'Style','edit','units','normalized','String','0.1-inf',...
    %    'Position', [0.6 0.65 0.4 0.15],'HorizontalAlignment','left');
    %uicontrol('Parent',panelMIDI,'Style','text','units','normalized','String','CC Resampling:',...
    %    'Position', [0 0.45 0.6 0.15],'FontWeight','bold','HorizontalAlignment','left');
    %data.MIDIAmpThresEdit = uicontrol('Parent',panelMIDI,'Style','edit','units','normalized','String','18000',...
    %    'Position', [0.6 0.5 0.4 0.15],'HorizontalAlignment','left');    
    data.Bn.SS=uicontrol('Parent',panelMIDI, 'Style', 'pushbutton', 'String', 'Signal Separation','units','normalized', ...
        'Position', [0 0.85 1 0.1],'FontWeight','bold','Callback',@KAMIR);
    data.Bn.importProtocol=uicontrol('Parent',panelMIDI, 'Style', 'pushbutton', 'String', 'Import Protocol','units','normalized', ...
        'Position', [0 0.75 1 0.1],'FontWeight','bold','Callback',@importProtocol);
    data.Bn.importBatch=uicontrol('Parent',panelMIDI, 'Style', 'pushbutton', 'String', 'Project Import','units','normalized', ...
        'Position', [0 0.65 1 0.1],'FontWeight','bold','Callback',@importBatch);
    data.Bn.globalexport=uicontrol('Parent',panelMIDI, 'Style', 'pushbutton', 'String', 'Project/MIDI Export','units','normalized', ...
        'Position', [0 0.55 1 0.1],'FontWeight','bold','Callback',@globalexport);%export to .mid or .m
    % Play module
    uicontrol('Parent',tabSynMIDI,'Style','text','units','normalized','String','Selected Audio:',...
        'Position', [0.21 0.5 0.1 0.05],'FontWeight','bold','HorizontalAlignment','left');
    playSynMIDIBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Play','units','normalized', ...
        'Position', [0.3 0.5 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,1});
    pauseSynMIDIBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Pause','units','normalized', ...
        'Position', [0.4 0.5 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    resumeSynMIDIBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Resume','units','normalized', ...
        'Position', [0.5 0.5 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    stopSynMIDIDenoisedWaveBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Stop','units','normalized', ...
        'Position', [0.6 0.5 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    %uicontrol('Parent',tabSynMIDI,'Style','text','units','normalized','String','Denoised Signal:',...
    %    'Position', [0.21 0.45 0.1 0.05],'FontWeight','bold','HorizontalAlignment','left')
    %playSynMIDIDenoisedWaveBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Play','units','normalized', ...
    %    'Position', [0.3 0.45 0.1 0.05],'FontWeight','bold','Callback',{@playAudioFn,2}); %��ȷ��������Ҫ��
    %pauseSynMIDIDenoisedWaveBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Pause','units','normalized', ...
    %    'Position', [0.4 0.45 0.1 0.05],'FontWeight','bold','Callback',@pauseAudioFn);
    %resumeSynMIDIDenoisedWaveBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Resume','units','normalized', ...
    %    'Position', [0.5 0.45 0.1 0.05],'FontWeight','bold','Callback',@resumeAudioFn);
    %stopSynMIDIDenoisedWaveBn = uicontrol('Parent', tabSynMIDI, 'Style', 'pushbutton', 'String', 'Stop','units','normalized', ...
    %    'Position', [0.6 0.45 0.1 0.05],'FontWeight','bold','Callback',@stopAudioFn);
    
    % The control panel and Track setting
    panelControlmono = uipanel('Parent',tabSynMIDI,'units','normalized','position',[0.05 0.2 0.8 0.25],'FontWeight','bold','title','Control Panel (Mono):');
    panelControlpoly = uipanel('Parent',tabSynMIDI,'units','normalized','position',[0.05 0.05 0.8 0.15],'FontWeight','bold','title','Control Panel (Poly):');
    %subgroup for Multitrack+MIDI
    data.subgroup = uitabgroup('Parent',panelControlmono,'TabLocation','top');
    uicontrol('Parent', panelControlmono,'Style','text','units','normalized','String','Import:',...
        'FontWeight','bold','Position', [0.15 0.65 0.1 0.1],'HorizontalAlignment','left');
    uicontrol('Parent', panelControlmono,'Style','text','units','normalized','String','Export:',...
        'FontWeight','bold','Position', [0.4 0.65 0.15 0.1],'HorizontalAlignment','left'); 
    uicontrol('Parent', panelControlmono,'Style','text','units','normalized','String','Play/Plot+Save:',...
        'FontWeight','bold','Position', [0.27 0.65 0.1 0.1],'HorizontalAlignment','left');
    uicontrol('Parent', panelControlmono,'Style','text','units','normalized','String','Export Channel:',...
        'FontWeight','bold','Position', [0.5 0.65 0.2 0.1],'HorizontalAlignment','left');
    uicontrol('Parent', panelControlpoly,'Style','text','units','normalized','String','Import:',...
        'FontWeight','bold','Position', [0.15 0.7 0.1 0.2],'HorizontalAlignment','left');
    uicontrol('Parent', panelControlpoly,'Style','text','units','normalized','String','Export:',...
        'FontWeight','bold','Position', [0.4 0.7 0.15 0.2],'HorizontalAlignment','left'); 
    uicontrol('Parent', panelControlpoly,'Style','text','units','normalized','String','Play/Plot+Save:',...
        'FontWeight','bold','Position', [0.27 0.7 0.1 0.2],'HorizontalAlignment','left');
    %uicontrol('Parent', panelControlpoly,'Style','text','units','normalized','String','Export Channel:',...
    %    'FontWeight','bold','Position', [0.5 0.7 0.2 0.2],'HorizontalAlignment','left');
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Denoised wave:',...
        'FontWeight','bold','Position', [0.017 0.55 0.1 0.1],'HorizontalAlignment','left'); 
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Pitch:',...
        'FontWeight','bold','Position', [0.072 0.45 0.05 0.1],'HorizontalAlignment','left'); 
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Note:',...
        'FontWeight','bold','Position', [0.077 0.35 0.05 0.1],'HorizontalAlignment','left');
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Vibrato:',...
        'FontWeight','bold','Position', [0.062 0.25 0.05 0.1],'HorizontalAlignment','left'); 
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Sliding:',...
        'FontWeight','bold','Position', [0.062 0.15 0.08 0.1],'HorizontalAlignment','left'); 
    uicontrol('Parent',panelControlmono,'Style','text','units','normalized','String','Tremolo:',...
        'FontWeight','bold','Position', [0.057 0.05 0.06 0.1],'HorizontalAlignment','left'); 
    %The options in the tabs
    for p=1:data.track_nb
        temptab=uitab('Parent',data.subgroup,'Title',['Track',num2str(p)]);
        %waveform for play the denoise waveform
        data.CB.MIDIDenoisedWave{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
        'Position', [0.29 0.65 0.2 0.12],'HorizontalAlignment','left','callback',{@DenoisedActive,p});
        data.Bn.ImportSynMIDIDenoisedWave{p} = uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String','...',...
            'units','normalized','Position', [0.15 0.65 0.05 0.1],'FontWeight','bold','Callback',{@importDenoisedWaveFn,p});
        data.Bn.ExportSynMIDIDenoisedWave{p} = uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String','...',...
            'units','normalized','Position', [0.4 0.65 0.05 0.1],'FontWeight','bold','Callback',{@exportDenoisedWaveFn,p});
        data.CB.Pitch{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
            'Position', [0.29 0.51 0.2 0.12],'HorizontalAlignment','left','callback',{@PitchActive,p});
        data.Bn.ImportSynMIDIPitch{p} = uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.15 0.53 0.05 0.1],'FontWeight','bold','Callback',@importPitchCurveFn);
        %data.Bn.ExportSynMIDIPitch{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
        %    'Position', [0.4 0.53 0.05 0.1],'FontWeight','bold','Callback',@exportPitchWaveFn);  
        %data.channelEdit{p,1} = uicontrol('Parent',temptab,'Style','edit','units','normalized','String',num2str(1),...
        %'Position', [0.5 0.53 0.03 0.1],'HorizontalAlignment','left');
    
        data.CB.Note{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
            'Position', [0.29 0.39 0.2 0.12],'HorizontalAlignment','left','callback',{@NoteActive,p});
        data.Bn.ImportSynMIDINote{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.15 0.41 0.05 0.1],'FontWeight','bold','Callback',@importNoteFn);
        data.Bn.ExportSynMIDINote{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.4 0.41 0.05 0.1],'FontWeight','bold','Callback',@exportNoteFn); 
        data.channelEdit{p,1} = uicontrol('Parent',temptab,'Style','edit','units','normalized','String',protocol.note,...
        'Position', [0.5 0.41 0.03 0.1],'HorizontalAlignment','left');
        
        data.CB.Vibrato{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
            'Position', [0.29 0.27 0.2 0.12],'HorizontalAlignment','left','callback',{@VibratoActive,p});
        data.Bn.ImportSynMIDIVibrato{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized',...
            'Position', [0.15 0.29 0.05 0.1],'FontWeight','bold','Callback',@importVibratoFn);
        data.Bn.ExportSynMIDIVibrato{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized',...
            'Position', [0.4 0.29 0.05 0.1],'FontWeight','bold','Callback',@exportVibratoFn);
        data.channelEdit{p,2} = uicontrol('Parent',temptab,'Style','edit','units','normalized','String',protocol.vibrato,...
        'Position', [0.5 0.29 0.03 0.1],'HorizontalAlignment','left');
    
        data.CB.Portamento{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
            'Position', [0.29 0.15 0.2 0.12],'HorizontalAlignment','left','callback',{@PortamentoActive,p});
        data.Bn.ImportSynMIDIPortamento{p} = uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.15 0.17 0.05 0.1],'FontWeight','bold','Callback',@importPortamentoFn);
        data.Bn.ExportSynMIDIPortamento{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.4 0.17 0.05 0.1],'FontWeight','bold','Callback',@exportPortamentoFn);
        data.channelEdit{p,3} = uicontrol('Parent',temptab,'Style','edit','units','normalized','String',protocol.slide,...
        'Position', [0.5 0.17 0.03 0.1],'HorizontalAlignment','left');
        data.CB.Tremolo{p}=uicontrol('Parent',temptab,'Style','checkbox','units','normalized',...
            'Position', [0.29 0.03 0.2 0.12],'HorizontalAlignment','left','callback',{@TremoloActive,p});
        data.Bn.ImportSynMIDITremolo{p}= uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
           'Position', [0.15 0.05 0.05 0.1],'FontWeight','bold','Callback',@importTremoloFn);
        data.Bn.ExportSynMIDITremolo{p} = uicontrol('Parent',temptab, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
            'Position', [0.4 0.05 0.05 0.1],'FontWeight','bold','Callback',@exportTremoloFn);
        data.channelEdit{p,4} = uicontrol('Parent',temptab,'Style','edit','units','normalized','String',protocol.tremolo,...
        'Position', [0.5 0.05 0.03 0.1],'HorizontalAlignment','left');
    end
       
    %Polytrack
    uicontrol('Parent',panelControlpoly,'Style','text','units','normalized','String','Polyphonic Audio:',...
        'FontWeight','bold','Position', [0.008 0.51 0.2 0.15],'HorizontalAlignment','left'); 
    data.Bn.ImportSynMIDIAudio = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
        'Position', [0.15 0.51 0.05 0.15],'FontWeight','bold','Callback',{@importDenoisedWaveFn,data.track_nb+1});
    data.CB.MIDIDenoisedWave{data.track_nb+1}=uicontrol('Parent',panelControlpoly,'Style','checkbox','units','normalized',...
        'Position', [0.29 0.45 0.2 0.17],'HorizontalAlignment','left','callback',{@DenoisedActive,data.track_nb+1});
    data.CB.Strumming=uicontrol('Parent',panelControlpoly,'Style','checkbox','units','normalized',...
        'Position', [0.29 0.25 0.2 0.17],'HorizontalAlignment','left','callback',@StrummingActive);
    %data.Bn.ExportSynMIDIAudio = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
    %    'Position', [0.4 0.51 0.05 0.15],'FontWeight','bold','Callback',@exportStrummingFn);
    
    uicontrol('Parent',panelControlpoly,'Style','text','units','normalized','String','Strumming:',...
        'FontWeight','bold','Position', [0.042 0.27 0.2 0.17],'HorizontalAlignment','left'); 
    data.CB.Strumming=uicontrol('Parent',panelControlpoly,'Style','checkbox','units','normalized',...
        'Position', [0.29 0.25 0.2 0.17],'HorizontalAlignment','left','callback',@StrummingActive);
    data.Bn.ImportSynMIDIStrumming = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
        'Position', [0.15 0.27 0.05 0.15],'FontWeight','bold','Callback',@importStrummingFn);
    data.Bn.ExportSynMIDIStrumming = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
        'Position', [0.4 0.27 0.05 0.15],'FontWeight','bold','Callback',@exportStrummingFn);
    data.channelEdit{data.track_nb+1,1} = uicontrol('Parent',panelControlpoly,'Style','edit','units','normalized','String',protocol.strumming,...
        'Position', [0.5 0.25 0.03 0.15],'HorizontalAlignment','left');
    
%     uicontrol('Parent',panelControlpoly,'Style','text','units','normalized','String','Synthesized music:',...
%         'FontWeight','bold','Position', [0 0.05 0.2 0.15],'HorizontalAlignment','left');
%     data.Bn.ImportSynMIDI = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
%         'Position', [0.15 0.05 0.05 0.15],'FontWeight','bold','Callback',@importMAT);%only import MAT
%     data.Bn.ExportSynMIDI = uicontrol('Parent',panelControlpoly, 'Style', 'pushbutton', 'String', '...','units','normalized', ...
%         'Position', [0.4 0.05 0.05 0.15],'FontWeight','bold','Callback',@exportMIDI);%convert,export MAT or MIDI
    
    
    %----------END of Multitrack+MIDI build-----------
     
    %----------START of about build-----------
    %get text
    fileID = fopen('ReadMe.txt','r');
%     text = fscanf(fileID,'s');
    textRaw = textscan(fileID,'%s','delimiter','\n');
    text = [];
    for i = 1:length(textRaw{1})
        text = [text,char(10),textRaw{1}{i}];
    end
    data.aboutText = uicontrol('Parent',tabAbout,'Style','text','units','normalized','String',text,...
        'Position', [0.05 0.1 0.9 0.9],'HorizontalAlignment','left'); 
    data.aboutText.FontSize = 12;
    %----------END of about build-----------
end


%-------START of Callback functions-------------------
function featureListBoxFn(hObject,eventData)
    global data;
    numFeatureSelected = eventData.Source.Value;
    
    if  strcmp(eventData.Source.Parent.Title,'Notes')
        %if it is for note listbox
        patchFeatureArea = data.patchNoteArea;
        data.numNoteSelected = numFeatureSelected;
        featureDetail = data.NoteDetail;
        featureXaxisPara = data.noteXaxisPara;
        axe = data.axePitchTabNoteIndi;%small window
        note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
        data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1},'+',num2str(data.velocity(data.numNoteSelected))];
        %show individual vibrato statistics
        %plotNoteStatistics(data.textNote,data.NotePara,data.numNoteSelected);
        
    elseif strcmp(eventData.Source.Parent.Title,'Vibratos')
        %if it is for vibrato listbox
        patchFeatureArea = data.patchVibratoArea;
        data.numViratoSelected = numFeatureSelected;
        featureDetail = data.vibratosDetail;
        featureXaxisPara = data.vibratoXaxisPara;
        axe = data.axePitchTabVibratoIndi;
        %show individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
        data.vibratoXEdit.String=[num2str(data.vibratos(numFeatureSelected,1)),'-',num2str(data.vibratos(numFeatureSelected,2))];
        if isfield(data,'vibratos')
            data.VibratoType.Value=data.vibratos(numFeatureSelected,4);
        end
    elseif strcmp(eventData.Source.Parent.Title,'Slidings')
        %if it is for portamento listbox
        patchFeatureArea = data.patchPortamentoArea;
        data.numPortamentoSelected = numFeatureSelected;
        featureDetail = data.portamentosDetail;
        featureXaxisPara = data.portamentoXaxisPara;
        axe = data.axePitchTabPortamentoIndi;
        %show individual feature's x(time) range in the edit text
        data.portamentoXEdit.String=[num2str(data.portamentos(numFeatureSelected,1)),'-',num2str(data.portamentos(numFeatureSelected,2))];
        if isfield(data,'portamentos')
            data.PortamentoType.Value=data.portamentos(numFeatureSelected,4);
        end
    elseif strcmp(eventData.Source.Parent.Title,'Strummings')
        %if it is for strumming listbox
        patchFeatureArea = data.patchStrummingArea;
        data.numStrummingSelected = numFeatureSelected;
        %featureDetail = data.portamentosDetail;
        featureXaxisPara = data.StrumXaxisPara;
        axe = data.axeTabStrummingIndi;
        %show individual feature's x(time) range in the edit text
%         if size(data.strummings,2)==4
%             data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
%         else
            data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
%         end
    elseif  strcmp(eventData.Source.Parent.Title,'Candidate Notes')
        %if it is for Candidate Note/tremolo listbox
        patchFeatureArea = data.patchTremoloArea;
        data.numTremoloSelected = numFeatureSelected;
        time=data.candidateNote(data.numTremoloSelected,1:2);
        timerange=round(time(1)*data.fs):round(time(end)*data.fs);
        time=timerange/data.fs;
        featureDetail = time;
        featureXaxisPara = data.tremoloXaxisPara;
        axe = data.axeWaveTabTremoloIndi;%small window
        %data.tremoloXEdit.String=[num2str(data.candidateNote(numFeatureSelected,1)),'-',num2str(data.candidateNote(numFeatureSelected,2))];

        %show individual vibrato statistics
        if isfield(data,'tremoloPara')
            plotTremoloStatistics(data.textTremolo,data.tremoloPara,data.numTremoloSelected);%(:,data.NoteClass)
            data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5);
        end
    end
    %higlight the selected feature
    plotHighlightFeatureArea(patchFeatureArea,numFeatureSelected,1);
    
    %show individual feature in the sub axes
    if ~strcmp(eventData.Source.Parent.Title,'Candidate Notes')
        if strcmp(eventData.Source.Parent.Title,'Strummings')
            range=data.strummings(data.numStrummingSelected,:);
            onset_tracks=cell(1,4);
            for i=1:data.track_nb
                temp=data.onset_tracks{i};
                onset_tracks{i}=temp(logical((temp>=range(1)).*(temp<=range(2))));
            end
            if data.StrumXaxisPara.Value==2
                for i=1:data.track_nb
                    onset_tracks{i}=onset_tracks{i}-range(1);
                end
                range=range-range(1);
            end                 
            if isfield(data,'polyStrumAudio')
                time=(0:size(data.polyStrumAudio,1)-1)'/data.fs;
                pos=data.strummings(data.numStrummingSelected,1:2)+[-0.1,0.5];
                [~,time1]=min(abs(pos(1)-time));
                [~,time2]=min(abs(pos(2)-time));
                if isfield(data,'plotStrumAudio')
                    delete(data.plotStrumAudio);
                end
                hold on;
                data.plotStrumAudio=plotAudio(time(time1:time2),data.polyStrumAudio(time1:time2),data.axeTabStrummingIndi,'Selected Strum',1);
                hold off;
            end
            if isfield(data,'patchFeaturesTrackOnsetsIndi')
                delete(data.patchFeaturesTrackOnsetsIndi);
                delete(data.patchFeaturesAreaOnsetsIndi);
            end
            data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
            data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);
            plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
            data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end};
        else      
            if strcmp(eventData.Source.Parent.Title,'Notes')
                if isfield(data,'Cleaned_speech')
                time=data.notes(numFeatureSelected,1:2);
                timerange=round(time(1)*data.fs):round(sum(time)*data.fs);
                time=timerange/data.fs;
                audio=data.Cleaned_speech(timerange);

                %audio=audio/max(abs(audio)).*diff(minmax)/2+diff(minmax)/2+minmax(1);%normalize the audio
                xAxis = get(featureXaxisPara,'Value');
                if xAxis == 2%normalized time
                    time=time-time(1);
                end
                plotAudio(time,audio,data.axePitchTabNoteIndi,'Selected Note',1);
                end               
            end
            plotPitchFeature(featureDetail,numFeatureSelected,featureXaxisPara,axe);%for note/vibrato/portamento
        end
    else
        if isfield(data,'Cleaned_speech')
%             time=data.notes(numFeatureSelected,1:2);
%             timerange=round(time(1)*data.fs):round(sum(time)*data.fs);
%             time=timerange/data.fs;
            audio=data.Cleaned_speech(timerange);
            xAxis = get(featureXaxisPara,'Value');
            if xAxis == 2%normalized time
                time1=time(1);
                time=time-time1;
            end
            plotAudio(time,audio,data.axeWaveTabTremoloIndi,'Selected Note',0);
            if isfield(data,'tremoloPara')
                %if data.tremoloPara{data.numTremoloSelected,2}>=2
                    axes(data.axeWaveTabTremoloIndi);
                    onset=data.onset_tremolo{data.numTremoloSelected};
                    if isfield(data,'patchTremoloOnset')
                        delete(data.patchTremoloOnset);
                        data=rmfield(data,'patchTremoloOnset');
                    end
                    y=data.axeWaveTabTremoloIndi.YLim;
                    xAxis = get(featureXaxisPara,'Value');
                    for j=1:length(onset)
                        if xAxis == 2%normalized time
                            data.patchTremoloOnset(j) = line([onset(j)-time1,onset(j)-time1],y,'color','red'); 
                        else
                            data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red'); 
                        end
                    end
                    time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                    hold on;
                    if data.changeTremoloMethod.Value~=1
                        [~,a]=min(abs(data.EdgeTime-time(1)));
                        [~,b]=min(abs(data.EdgeTime-time(2)));
                        data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                    else
                        [~,a]=min(abs(data.log_energy_time-time(1)));
                        [~,b]=min(abs(data.log_energy_time-time(2)));     
                        data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                    end
                    hold off;
                %end
            end
        else
            msgbox('No denoised audio input.')
            return
        end
    end     
    if strcmp(eventData.Source.Parent.Title,'Slidings') && isfield(data,'portamentosDetailLogistic')      
        %plot the portamento Logistic fitting line
        plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
        data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);
    
        %plot the portamneto statistics
        plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected);
    end
end

function changeXaxisFeatureIndi(hObject,eventData)%��Ҫ�����
    %this is the call back function when axis of feature individual is
    %changed
    global data;
    
    currentTabName = data.tgroup.SelectedTab.Title;
    %show individual vibrato in the sub axes
    if strcmp(currentTabName,'Vibrato Analysis')
        plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi);
    elseif strcmp(currentTabName,'Sliding Analysis')
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);      
        
        %plot the portamento logisitic fitting line and portamento para
        if isfield(data,'portamentosDetailLogistic')  
            %plot the portamento Logistic fitting line
            plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
            data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);

            %plot the portamneto statistics
            plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected);
        end
    elseif strcmp(currentTabName,'Tremolo Analysis')
        time=data.candidateNote(data.numTremoloSelected,1:2);
        timerange=round(time(1)*data.fs):round(time(end)*data.fs);
        time=timerange/data.fs;
        audio=data.Cleaned_speech(timerange);
        xAxis = get(data.tremoloXaxisPara,'Value');
        if xAxis == 2%normalized time
            time1=time(1);
            time=time-time1;  
        end
        plotAudio(time,audio,data.axeWaveTabTremoloIndi,'Selected Note',0);
        if isfield(data,'onset_tremolo')
            y=data.axeWaveTabTremoloIndi.YLim;
            if ~isempty(data.onset_tremolo{data.numTremoloSelected})
                if isfield(data,'patchTremoloOnset')
                    delete(data.patchTremoloOnset);
                    data=rmfield(data,'patchTremoloOnset');
                end
                onset=data.onset_tremolo{data.numTremoloSelected};
                if data.tremoloXaxisPara.Value==2
                    onset=onset-data.candidateNote(data.numTremoloSelected,1);
                end
                for j=1:length(onset)
                    data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
                end
                time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                hold on;
                if data.changeTremoloMethod.Value~=1
                    [~,a]=min(abs(data.EdgeTime-time(1)));
                    [~,b]=min(abs(data.EdgeTime-time(2)));
                    data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                else
                    [~,a]=min(abs(data.log_energy_time-time(1)));
                    [~,b]=min(abs(data.log_energy_time-time(2)));     
                    data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                end
                hold off;
            end
        end
        if isfield(data,'tremoloPara')
        %if data.tremoloPara{data.numTremoloSelected,2}>=2
            axes(data.axeWaveTabTremoloIndi);
            onset=data.onset_tremolo{data.numTremoloSelected};
            if isfield(data,'patchTremoloOnset')
                delete(data.patchTremoloOnset);
                data=rmfield(data,'patchTremoloOnset');
            end
            y=data.axeWaveTabTremoloIndi.YLim;
            for j=1:length(onset)
                if xAxis == 2%normalized time
                    data.patchTremoloOnset(j) = line([onset(j)-time1,onset(j)-time1],y,'color','red'); 
                else
                    data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red'); 
                end
            end
            time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
            hold on;
            if data.changeTremoloMethod.Value~=1
                [~,a]=min(abs(data.EdgeTime-time(1)));
                [~,b]=min(abs(data.EdgeTime-time(2)));
                data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
            else
                [~,a]=min(abs(data.log_energy_time-time(1)));
                [~,b]=min(abs(data.log_energy_time-time(2)));     
                data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
            end
            hold off;
        %end
        end
    elseif strcmp(currentTabName,'Strumming Analysis')
        if isfield(data,'polyStrumAudio')
            time=(0:size(data.polyStrumAudio,1)-1)'/data.fs;
            pos=data.strummings(data.numStrummingSelected,1:2)+[-0.1,0.5];
            [~,time1]=min(abs(pos(1)-time));
            [~,time2]=min(abs(pos(2)-time));
            if isfield(data,'plotStrumAudio')
                delete(data.plotStrumAudio);
            end
            hold on;
            data.plotStrumAudio=plotAudio(time(time1:time2),data.polyStrumAudio(time1:time2),data.axeTabStrummingIndi,'Selected Strum',1);
            hold off;
        end
        range=data.strummings(data.numStrummingSelected,:);
        onset_tracks=cell(1,4);
        for i=1:data.track_nb
            temp=data.onset_tracks{i};
            onset_tracks{i}=temp(logical((temp>=range(1)).*(temp<=range(2))));
        end
        if data.StrumXaxisPara.Value==2
            for i=1:data.track_nb
                onset_tracks{i}=onset_tracks{i}-range(1);
            end
            range=range-range(1);
        end
        if isfield(data,'patchFeaturesTrackOnsetsIndi')
            delete(data.patchFeaturesTrackOnsetsIndi);
            delete(data.patchFeaturesAreaOnsetsIndi);
        end
        data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
        data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);
        plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
        data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end};
    end
end

function mouseClick(hObject,eventData)
    %when the user click the vibrato, show the corresponding vibrato
    global data;
    
    currentTabName = data.tgroup.SelectedTab.Title;
    figMouse = get(data.f,'CurrentPoint');
    figx = figMouse(1,1); figy = figMouse(1,2);
    %Get the coordinate range of the four axes
    %axeRange = zeros(4,4);
    axeRange = [data.axeWave.get('position');data.axedenoisedWave.get('position');data.axePitchWave.get('position');data.axePitchTabAudio.get('position');data.axeTabSynMIDI.get('position');data.axeWaveTabTremolo.get('position');data.axeWaveTabTremoloIndi.get('position')];
    for i = 1:7
        axeRange(i,3) = axeRange(i,1)+axeRange(i,3);
        axeRange(i,4) = axeRange(i,2)+axeRange(i,4);
    end
    
    clickableArea = 9;
    
    if strcmp(currentTabName,'Read Audio')
        if axeRange(1,1) <=figx && figx <= axeRange(1,3) && axeRange(1,2) <= figy && figy <= axeRange(1,4)
            axe=data.axeWave;
            clickableArea = 2;
            if isfield(data,'patchNoiseRangeArea')
                patchFeatureArea = data.patchNoiseRangeArea;
            end
            if isfield(data,'audio')
                data.audioFeaturePlayer = audioplayer(data.audio,data.fs);
            end
        elseif axeRange(2,1) <=figx && figx <= axeRange(2,3) && axeRange(2,2) <= figy && figy <= axeRange(2,4)        
            axe = data.axedenoisedWave;         
            if isfield(data,'Cleaned_speech')
                clickableArea = 3;
                data.audioFeaturePlayer = audioplayer(data.Cleaned_speech,data.fs);
            end
        end
    elseif strcmp(currentTabName,'Pitch Detection')
        if axeRange(3,1) <=figx && figx <= axeRange(3,3) && axeRange(3,2) <= figy && figy <= axeRange(3,4)
            axe = data.axePitchWave;
            clickableArea = 4;
        elseif axeRange(4,1) <=figx && figx <= axeRange(4,3) && axeRange(4,2) <= figy && figy <= axeRange(4,4)
            clickableArea = 0;%Point click
            %in pitch tab
            axe = data.axePitchTabAudio;
            if isfield(data,'pitchPointArea')
                delete(data.pitchPointArea);
                data=rmfield(data,'pitchPointArea');
                data=rmfield(data,'pitchPoint');
                data=rmfield(data,'pitchPointTime');
                data.PitchXEdit.set('string',[]);
                data.PitchXMIDI.set('string',[]);
            end
        end
    elseif strcmp(currentTabName,'Note Detection')
        clickableArea = 5;%block click in case of monophonic music,it means X Axis Area click
        axe=data.axeOnsetOffsetStrength;
        %For future  
    elseif strcmp(currentTabName,'Vibrato Analysis')
        clickableArea = 1;%X Area click
        %in vibrato tab
        axe = data.axePitchTabVibrato;
        featureName = 'vibratos';
        if isfield(data,'patchVibratoArea')
            patchFeatureArea = data.patchVibratoArea;
            featuresDetail = data.vibratosDetail;
            featureXaxisPara = data.vibratoXaxisPara;
            axePitchTabFeatureIndi = data.axePitchTabVibratoIndi;
            featureListbox = data.vibratoListBox;
            features = data.vibratos;
        end           
    elseif strcmp(currentTabName,'Sliding Analysis')
        clickableArea = 1;%Area click
        %in portamento tab
        axe = data.axePitchTabPortamento;
        featureName = 'portamentos'; 
        if isfield(data,'patchPortamentoArea')
            patchFeatureArea = data.patchPortamentoArea;
            featuresDetail = data.portamentosDetail;
            featureXaxisPara = data.portamentoXaxisPara;
            axePitchTabFeatureIndi = data.axePitchTabPortamentoIndi;
            featureListbox = data.portamentoListBox;
            features = data.portamentos;
        end
        
    elseif strcmp(currentTabName,'Tremolo Analysis')  
        %in portamento tab
        if axeRange(6,1) <=figx && figx <= axeRange(6,3) && axeRange(6,2) <= figy && figy <= axeRange(6,4)
            axe = data.axeWaveTabTremolo;
            clickableArea = 1;%Area click
            featureName = 'candidateNote'; 
            if isfield(data,'patchTremoloArea')
                patchFeatureArea = data.patchTremoloArea;
                time=data.candidateNote(data.numTremoloSelected,1:2);
                timerange=round(time(1)*data.fs):round(time(end)*data.fs);
                time=timerange/data.fs;
                featuresDetail = time;
                featureXaxisPara = data.tremoloXaxisPara;
                axePitchTabFeatureIndi = data.axeWaveTabTremoloIndi;
                featureListbox = data.tremoloListBox;
                features = data.candidateNote;
            end
        end
        if axeRange(7,1) <=figx && figx <= axeRange(7,3) && axeRange(7,2) <= figy && figy <= axeRange(7,4)
            axe = data.axeWaveTabTremoloIndi;
            clickableArea = 8;%Pluck select or add.
            featureName = 'candidateNote'; 
        end
    elseif strcmp(currentTabName,'Strumming Analysis')
        clickableArea = 7;%point click for short area
        axe = data.axeTabStrumming;
    elseif strcmp(currentTabName,'Multitrack+MIDI')
        axe=data.axeTabSynMIDI;
        if axeRange(5,1) <=figx && figx <= axeRange(5,3) && axeRange(5,2) <= figy && figy <= axeRange(5,4) 
            clickableArea = 6;
        end
    end

    if clickableArea == 1
        %get click position in the corresponding axe for an interval
        numFeatureSelected = 0;
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);
        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            %in the pitch axes
            if isfield(data,featureName)
                for i = 1:size(features,1)
                   %check which feature is clicked
                   startTime = features(i,1);
                   endTime = features(i,2);
                   if startTime <= x && x <= endTime
                       numFeatureSelected = i;
                       break;
                   end
                end
               if isfield(data,'addTremolo_valid') && ~numFeatureSelected%add tremolo if needed
                   if data.addTremolo_valid
                       for i=1:size(data.notes,1)
                           if data.notes(i,1)<=x && sum(data.notes(i,1:2))>=x
                              data.addTremolo_valid=0;
                              data.candidateNote=[data.candidateNote;[data.notes(i,1),sum(data.notes(i,1:2)),data.notes(i,2),data.notes(i,3)]];
                              [data.candidateNote,list]=sortrows(data.candidateNote,1);
                              numFeatureSelected=find(list==size(data.candidateNote,1));
                              break
                           end
                       end
                       if isfield(data,'patchTremoloArea')
                           delete(data.patchTremoloArea);
                       end
                       data.patchTremoloArea=plotFeaturesArea(data.candidateNote,data.axeWaveTabTremolo);
                       patchFeatureArea = data.patchTremoloArea;
                       plotFeatureNum(data.candidateNote,data.tremoloListBox);
                       featureListbox=data.tremoloListBox;
                   end
               end
                
                if numFeatureSelected ~= 0
                    if strcmp(currentTabName,'Vibrato Analysis') 
                        %in vibrato tab
                        data.numViratoSelected = numFeatureSelected;

                        %show individual vibrato statistics
                        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
                        %show thes vibrato's X(time) range in the edit text
                        data.vibratoXEdit.String=[num2str(data.vibratos(numFeatureSelected,1)),'-',num2str(data.vibratos(numFeatureSelected,2))];
                        if isfield(data,'vibratos')
                            data.VibratoType.Value=data.vibratos(numFeatureSelected,4);
                        end
                    elseif strcmp(currentTabName,'Sliding Analysis')
                        %in portamento tab  
                        data.numPortamentoSelected = numFeatureSelected;                        
                        if isfield(data,'portamentos')
                            data.PoramentoType.Value=data.portamentos(numFeatureSelected,4);
                        end
                    elseif strcmp(currentTabName,'Tremolo Analysis')
                        %in tremolo tab  
                        data.numTremoloSelected = numFeatureSelected;
                        
                        if isfield(data,'tremoloPara')   
                            %plot the tremolo statistics
                            plotTremoloStatistics(data.textTremolo,data.tremoloPara,data.numTremoloSelected);%(:,data.NoteClass)
                            data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5); 
                        end  
                    end

                    %higlight the selected feature
                    plotHighlightFeatureArea(patchFeatureArea,numFeatureSelected,1);

                    %show the highlighted num of feature in the corresponding feature listbox
                    featureListbox.Value = numFeatureSelected;

                    %show individual feature in the sub axes
                    if ~strcmp(currentTabName,'Tremolo Analysis')
                        time=features(numFeatureSelected,1:2);
                        timerange=round(time(1)*data.fs):round(time(end)*data.fs);
                        time=timerange/data.fs;
                        audio=data.Cleaned_speech(timerange);
                        xAxis = get(featureXaxisPara,'Value');
                        if xAxis == 2%normalized time
                            time=time-time(1);
                        end
                        if strcmp(currentTabName,'Note Analysis')  
                            plotAudio(time,audio,axePitchTabFeatureIndi,'Selected Note',0);
                        end
                        plotPitchFeature(featuresDetail,numFeatureSelected,featureXaxisPara,axePitchTabFeatureIndi);
                        if strcmp(currentTabName,'Sliding Analysis') 
                            %plot the portamento logisitic fitting line and portamento para
                        if isfield(data,'portamentosDetailLogistic')                      
                            plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);      
                            %plot the portamneto statistics
                            plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected)            
                        end
                        end
                    else
                        if isfield(data,'Cleaned_speech') && isfield(data,'candidateNote')
                            time=data.candidateNote(numFeatureSelected,1:2);
                            timerange=round(time(1)*data.fs):round(time(end)*data.fs);
                            time=timerange/data.fs;
                            audio=data.Cleaned_speech(timerange);
                            xAxis = get(featureXaxisPara,'Value');
                            if xAxis == 2%normalized time
                                time1=time(1);
                                time=time-time1;
                            end
                            plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
                            if isfield(data,'tremoloPara')
                            %if data.tremoloPara{data.numTremoloSelected,2}>=2
                                axes(data.axeWaveTabTremoloIndi);
                                onset=data.onset_tremolo{numFeatureSelected};
                                if isfield(data,'patchTremoloOnset')
                                    delete(data.patchTremoloOnset);
                                    data=rmfield(data,'patchTremoloOnset');
                                end
                                y=data.axeWaveTabTremoloIndi.YLim;
                                for j=1:length(onset)
                                    if xAxis == 2%normalized time
                                        data.patchTremoloOnset(j) = line([onset(j)-time1,onset(j)-time1],y,'color','red'); 
                                    else
                                        data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red'); 
                                    end
                                end
                                time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                                hold on;
                                if data.changeTremoloMethod.Value~=1
                                    [~,a]=min(abs(data.EdgeTime-time(1)));
                                    [~,b]=min(abs(data.EdgeTime-time(2)));
                                    data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                                else
                                    [~,a]=min(abs(data.log_energy_time-time(1)));
                                    [~,b]=min(abs(data.log_energy_time-time(2)));     
                                    data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                                end
                                hold off;
                            %end
                            end
                        else
                            msgbox('No denoised audio input.')
                            return
                        end
                    end
                end
            end
        end
    elseif clickableArea == 0%point click for pitch
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);
        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            [~,data.pitchIndex]=min(abs(x-data.pitchTime));
            if ~isscalar(data.pitchIndex)
                data.pitchIndex=max(data.pitchIndex);
            end
            data.pitchPoint=freqToMidi(data.pitch(data.pitchIndex));
            data.pitchPointTime=data.pitchTime(data.pitchIndex);
            data.pitchPointArea=plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio);
            model=get(data.PitchXaxisPara,'value');
            midi=notename(data.pitchPoint);
            data.PitchXMIDI.set('string',num2str(midi{1}));
            if model==1%freq
                data.PitchXEdit.set('string',num2str(data.pitch(data.pitchIndex)));
            else%MIDI
                data.PitchXEdit.set('string',num2str(data.pitchPoint));
            end
        end
    elseif clickableArea==2%choose a noise range within a patch or a progress bar jump point
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);

        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            %data.audioFeaturePlayer=
            if ~isplaying(data.audioFeaturePlayer)
                if isfield(data,'noise_ranges')
                    change_area=0;
                    for i=1:size(data.patchNoiseRangeArea,2)
                        %choose a noise range within a patch when is not playing
                        if x<=data.noise_ranges(i,2) && x>=data.noise_ranges(i,1)
                            plotHighlightFeatureArea(data.patchNoiseRangeArea,i,1);
                            if isfield(data,'patchNoiseRangeArea_2')
                                plotHighlightFeatureArea(data.patchNoiseRangeArea_2,i,1);
                            end
                            data.noise_range=data.noise_ranges(i,:);
                            data.noise_range_num=i;
                            change_area=1;
                            break
                        %choose a progress bar jump point outside the noise range
                        end
                    end
                    if change_area==0%if (x<data.noise_ranges(1,1))||(x>data.noise_ranges(i,2) && x<data.noise_ranges(i+1,1))||...
                            %x>data.noise_ranges(size(data.patchNoiseRangeArea,2),2)
                        data.PlayPoint = floor(x*data.fs);  
                        clickPlay(axe,data.PlayPoint);
                    end
                else %��ʾ�ϱܿ�data.noise
                    data.PlayPoint = floor(x*data.fs);
                    clickPlay(axe,data.PlayPoint);
                end
            else %isplaying(data.audioFeaturePlayer)   
                data.PlayPoint = floor(x*data.fs);
                clickPlay(axe,data.PlayPoint);
            end         
        end
        
    elseif clickableArea==3 ||clickableArea==4 %choose a progress bar jump point
        posMousedenoise = get(axe,'CurrentPoint');
        xdenoise = posMousedenoise(1,1); ydenoise = posMousedenoise(1,2);
        if axe.XLim(1) <=xdenoise && xdenoise <= axe.XLim(2) && axe.YLim(1) <= ydenoise && ydenoise <= axe.YLim(2)
%             if isfield(data,'audioFeaturePlayer')
%                     data.DenoisePlayPoint = floor(xdenoise*data.fs);
%                     clickPlay(axe,data.DenoisePlayPoint);
%             else
                data.audioFeaturePlayer = audioplayer(data.Cleaned_speech,data.fs);
                data.DenoisePlayPoint = floor(xdenoise*data.fs);
                clickPlay(axe,data.DenoisePlayPoint);
            %end
        end
    elseif clickableArea==5
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);
        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            note_valid=0;
            if isfield(data,'NoteOnset')%selected note as the priority
                for i=1:length(data.NoteOnset)
                    if data.NoteOnset(i) <=x && x <= data.NoteOnset(i)+data.NoteDuration(i) && round(freqToMidi(data.avgPitch(i)))-1<= y && y <= round(freqToMidi(data.avgPitch(i)))+1
                        data.numNoteSelected=i;
                        note_valid=1;
                        break
                    end  
                end
            end
            if note_valid
                if isfield(data,'selected_edge')
                data=rmfield(data,'selected_edge');
                end
                if isfield(data,'Cleaned_speech')
                time=[data.NoteOnset(data.numNoteSelected),data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)];
                timerange=round(time(1)*data.fs):round(time(2)*data.fs);
                time=timerange/data.fs;
                audio=data.Cleaned_speech(timerange);
                xAxis = get(data.noteXaxisPara,'Value');
                if xAxis == 2%normalized time
                    time=time-time(1);
                end
                plotAudio(time,audio,data.axePitchTabNoteIndi,data.NoisefileNameSuffix,1);
                end
                plotPitchFeature(data.NoteDetail,data.numNoteSelected,data.noteXaxisPara,data.axePitchTabNoteIndi);

                plotHighlightFeatureArea(data.patchNoteArea,data.numNoteSelected,1);
                %Parameter display area
                note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
                data.noteListBox.Value = data.numNoteSelected;
                data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1},'+',num2str(data.velocity(data.numNoteSelected))];
            else%select the edge/boundaries
                if ~isfield(data,'addEdge_valid') 
                    if (isfield(data,'onset')|| isfield(data,'offset'))
                        if ~isempty(data.onset)||~isempty(data.offset)
                            [min_onset,min_onset_ind]=min(abs(x-data.onset*data.hop_length/data.fs));
                            [min_offset,min_offset_ind]=min(abs(x-data.offset*data.hop_length/data.fs));
                            if ~isempty(min_offset)
                                if ~isempty(min_onset)&& min_onset>=min_offset
                                    data.selected_edge=[min_offset_ind,2];
                                else
                                    data.selected_edge=[min_onset_ind,1];
                                end
                            else
                                data.selected_edge=[min_onset_ind,1];
                            end
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
                            data.patchFeaturesPoint(data.selected_edge(1),data.selected_edge(2)).Color=[1,0,1];                            
                        end
                    end
                else
                    if data.addEdge_valid==1%add onset
                    auto_edge=get(data.CB.Auto_Edge,'value');
                    x=round(x*data.fs/data.hop_length);
                    if auto_edge
                        x=auto_adjust_edge(x,data.onset_env);
                    end
%                     if data.OnsetOffsetMethodChange.Value==4
%                         align=floor(data.win_length/4/data.hop_length);%due to different window size
%                     else
%                         align=floor(data.win_length/2/data.hop_length);
%                     end
%                     x=x+align;
                    %Add an onset point and plot the new point.
                    data.onset=sort([data.onset,x]);
                    end
                    if data.addEdge_valid==2
                    %auto_edge=get(data.CB.Auto_Edge,'value');
                    x=round(x*data.fs/data.hop_length);
%                     if auto_edge
%                         x=auto_adjust_edge(x,data.offset_env);
%                     end
                    %Add an onset point and plot the new point.
                    data.offset=sort([data.offset,x]);
                    end
                    if isfield(data,'patchFeaturesPoint')
                        delete(data.patchFeaturesPoint)
                        data=rmfield(data,'patchFeaturesPoint');
                    end
                    if data.OnsetOffsetMethodChange.Value~=4
                        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
                    else
                        data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);
                    end
                    data=rmfield(data,'addEdge_valid');%clear data.addEdge_valid;
                end
            end
        end
    elseif clickableArea==6
        posMousedenoise = get(axe,'CurrentPoint');
        xdenoise = posMousedenoise(1,1); ydenoise = posMousedenoise(1,2);
        if isfield(data,'denoisedWaveTrack') && (axe.XLim(1) <=xdenoise && xdenoise <= axe.XLim(2) && axe.YLim(1) <= ydenoise && ydenoise <= axe.YLim(2))
            for p=1:data.track_nb+1
                if data.CB.MIDIDenoisedWave{p}.Value
                if p<=length(data.denoisedWaveTrack)
                    if ~isempty(data.denoisedWaveTrack{p})
                        data.audioFeaturePlayer=audioplayer(data.denoisedWaveTrack{p},data.fs);
                        data.DenoisePlayPoint = floor(xdenoise*data.fs);
                        clickPlay(axe,data.DenoisePlayPoint); 
                        break
                    else
                        msgbox('No audio input for this track.')
                        return
                    end
                else
                    msgbox('No audio input for this track.')
                    return
                end
                end
            end
%         else
%             msgbox('No audio input for this track.')
%             return
        end
    elseif clickableArea==7%Closest point to several short intervals
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);
        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            middle_pt=mean(data.strummings(:,1:2),2);
            [~,data.numStrummingSelected]=min(abs(x-middle_pt));
            plotHighlightFeatureArea(data.patchStrummingArea,data.numStrummingSelected,1);

            %plot the strumming num in the listbox
            plotFeatureNum(data.strummings,data.StrummingListBox);

            %show the first Strumming in Strumming listbox
            data.StrummingListBox.Value = data.numStrummingSelected;

            %show the first Strumming's X(time) range in the edit text
%             if size(data.strummings,2)==4
%                 data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2)),'+',num2str(data.strummings(data.numStrummingSelected,4))];
%             else
                data.StrumXEdit.String=[num2str(data.strummings(data.numStrummingSelected,1)),'-',num2str(data.strummings(data.numStrummingSelected,2))];
%             end
            %show individual strumming in the sub axes
            %plotPitchFeature(data.strummingsDetail, data.numStrummingSelected,data.StrumXaxisPara,data.axeTabStrummingIndi);
            range=data.strummings(data.numStrummingSelected,:);
            onset_tracks=cell(1,4);
            for i=1:data.track_nb
                temp=data.onset_tracks{i};
                onset_tracks{i}=temp(logical((temp>=range(1)).*(temp<=range(2))));
            end
            if data.StrumXaxisPara.Value==2
                for i=1:data.track_nb
                    onset_tracks{i}=onset_tracks{i}-range(1);
                end
                range=range-range(1);
            end
            if isfield(data,'patchFeaturesTrackOnsetsIndi')
                delete(data.patchFeaturesTrackOnsetsIndi);
                delete(data.patchFeaturesAreaOnsetsIndi);
            end
            data.patchFeaturesTrackOnsetsIndi=plotStrumming(onset_tracks,hsv(data.track_nb),data.track_nb,range,data.axeTabStrummingIndi);
            data.patchFeaturesAreaOnsetsIndi=plotFeaturesArea(range,data.axeTabStrummingIndi);
            
            plotStrumStatistics(data.textPortStrumming,data.strumPara,data.numStrummingSelected);
            data.StrummingType.Value=data.strumPara{data.numStrummingSelected,end};
            if isfield(data,'polyStrumAudio')
                time=(0:size(data.polyStrumAudio,1)-1)'/data.fs;
                pos=data.strummings(data.numStrummingSelected,1:2)+[-0.1,0.5];
                [~,time1]=min(abs(pos(1)-time));
                [~,time2]=min(abs(pos(2)-time));
                if isfield(data,'plotStrumAudio')
                   delete(data.plotStrumAudio);
                end
                hold on;
                data.plotStrumAudio=plotAudio(time(time1:time2),data.polyStrumAudio(time1:time2),data.axeTabStrummingIndi,'Selected Strum',1);
                hold off;
            end
        end
     elseif clickableArea==8
        posMouse = get(axe,'CurrentPoint');
        x = posMouse(1,1); y = posMouse(1,2);
        if axe.XLim(1) <=x && x <= axe.XLim(2) && axe.YLim(1) <= y && y <= axe.YLim(2)
            if isfield(data,'addPluck_valid')
                %add a new pluck
                if data.addPluck_valid==1%add pluck
                    %Add an onset point and plot the new point.
                    if data.CB.Auto_pluck.Value
                        if data.tremoloXaxisPara.Value==2%normalized
                            x=auto_adjust_edge(round((x+data.candidateNote(data.numTremoloSelected,1))*data.fs/data.hop_length),data.onset_env_tremolo);%-axe.XLim(1)
                        else%axe.XLim(1)
                            x=auto_adjust_edge(round(x*data.fs/data.hop_length),data.onset_env_tremolo);
                        end
                        x=x*data.hop_length/data.fs;
                    else
                        if data.tremoloXaxisPara.Value==2
                            x=x+data.candidateNote(data.numTremoloSelected,1);%axe.XLim(1)
                        end
                    end                    
                    data.onset_tremolo{data.numTremoloSelected}=sort([data.onset_tremolo{data.numTremoloSelected},x]);
                    data=rmfield(data,'addPluck_valid');%clear data.addPluck_valid;
                end
                %update and display parameters
                %Update and display the parameter
                if data.double_peak
                    onset_tmp=data.onset_tremolo{data.numTremoloSelected};
                    data.tremoloPara{data.numTremoloSelected,2}=(length(data.onset_tremolo{data.numTremoloSelected})+1)/2;
                    data.tremoloPara{data.numTremoloSelected,1}=tremolo_velocity(onset_tmp(1));
                else
                    data.tremoloPara{data.numTremoloSelected,2}=length(data.onset_tremolo{data.numTremoloSelected});
                end
                if data.tremoloPara{data.numTremoloSelected,2}>=2
                    if data.track_index==1
                        data.candidateNote(data.numTremoloSelected,5)=2;%Wheel
                    else
                       data.candidateNote(data.numTremoloSelected,5)=4;%Shaking by default for the other strings
                    end
                    
                    if data.double_peak
                         data.tremoloPara{data.numTremoloSelected,3}=1/mean(diff([data.candidateNote(data.numTremoloSelected,1),data.onset_tremolo{data.numTremoloSelected}(2:2:end)]));
                    else
                        data.tremoloPara{data.numTremoloSelected,3}=1/mean(diff([data.candidateNote(data.numTremoloSelected,1),data.onset_tremolo{data.numTremoloSelected}]));               
                    end
                else
                    data.tremoloPara{data.numTremoloSelected,3}=nan;
                    data.candidateNote(data.numTremoloSelected,5)=1;
                end
                if data.tremoloPara{data.numTremoloSelected,2}==2
                    msgbox('Two normal plucks detected within a note, modify the pluck points or note segment in note tab.');
                end
                data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5); 
                %Show the tremolo parameters in statistics tab.
                for i=1:length(data.treParaName)
                    data.textTremolo(i,1).String=num2str(data.tremoloPara{data.numTremoloSelected,i});
                end 
                %plot
                axes(axe);
                y=data.axeWaveTabTremoloIndi.YLim;
                if isfield(data,'patchTremoloOnset')
                    delete(data.patchTremoloOnset);
                    data=rmfield(data,'patchTremoloOnset');
                end
                    onset=data.onset_tremolo{data.numTremoloSelected};
                    if data.tremoloXaxisPara.Value==2
                        onset=onset-data.candidateNote(data.numTremoloSelected,1);
                    end
                    hold on;
                    for j=1:length(onset)
                        data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
                    end
                    hold off;
                    time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                    hold on;
                    if data.changeTremoloMethod.Value~=1
                        [~,a]=min(abs(data.EdgeTime-time(1)));
                        [~,b]=min(abs(data.EdgeTime-time(2)));
                        data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                    else
                        [~,a]=min(abs(data.log_energy_time-time(1)));
                        [~,b]=min(abs(data.log_energy_time-time(2)));     
                        data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                    end
                    hold off;
            else
            if isfield(data,'onset_tremolo')%selected a pluck
                if ~isempty(data.onset_tremolo{data.numTremoloSelected})
                    if isfield(data,'selected_pluck')
                        data=rmfield(data,'selected_pluck');
                    end
                    if data.tremoloXaxisPara.Value==2
                        x=x+data.candidateNote(data.numTremoloSelected,1);
                    end
                    [data.selected_pluck,data.numPluckSelected]=min(abs(x-data.onset_tremolo{data.numTremoloSelected}));
                    %plot
                    axes(axe);
                    y=axe.YLim;
                    if isfield(data,'patchTremoloOnset')
                        delete(data.patchTremoloOnset);
                        data=rmfield(data,'patchTremoloOnset');
                    end
                    onset=data.onset_tremolo{data.numTremoloSelected};
                    if data.tremoloXaxisPara.Value==2
                        onset=onset-data.candidateNote(data.numTremoloSelected,1);
                    end
                    for j=1:length(onset)
                        data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
                    end
                    data.patchTremoloOnset(data.numPluckSelected).Color=[1,0,1]; %highlight selected pluck
                time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                hold on;
                if data.changeTremoloMethod.Value~=1
                    [~,a]=min(abs(data.EdgeTime-time(1)));
                    [~,b]=min(abs(data.EdgeTime-time(2)));
                    data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                else
                    [~,a]=min(abs(data.log_energy_time-time(1)));
                    [~,b]=min(abs(data.log_energy_time-time(2)));     
                    data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                end
                hold off;
                end
            end      
            end
        end
    end
end

function clickPlay(axe,clickpoint)
    global data;
    pause(data.audioFeaturePlayer);
    set(data.audioFeaturePlayer,'TimerPeriod',128/44000,'TimerFcn',{@plotBar,axe.get('Ylim'),axe});
    play(data.audioFeaturePlayer,clickpoint);
end

function keyPressedFunction(hObject,eventData)
    global data;
    currentTabName = data.tgroup.SelectedTab.Title;
    
    if strcmp(eventData.Key,'backspace')
        if strcmp(currentTabName,'Note Detection')
            %use the 'backspace' key for deleting vibrato
            if isfield(data,'selected_edge')
                if ~iscell(data.selected_edge)
                    if data.selected_edge(2)==1%onset
                        data.onset(data.selected_edge(1))=[];
                    else%offset
                        data.offset(data.selected_edge(1))=[];
                    end
                else
                    if ~isempty(data.selected_edge{1})
                        data.onset(data.selected_edge{1})=[];
                    end
                    if ~isempty(data.selected_edge{2})
                        data.offset(data.selected_edge{2})=[];
                    end
                end
                delete(data.patchFeaturesPoint);
                data=rmfield(data,'patchFeaturesPoint');
                if  data.OnsetOffsetMethodChange.Value~=4
                    data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
                else
                    data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);
                end
                data=rmfield(data,'selected_edge');
            else
                if isfield(data,'numNoteSelected')
                    delNoteFn();%remove the selected note.
                end
            end
        elseif strcmp(currentTabName,'Vibrato Analysis')
            %use the 'backspace' key for deleting vibrato
            delVibratoFn();
        elseif strcmp(currentTabName,'Sliding Analysis')
            %use the 'backspace' key for deleting portamento
            delPortamentoFn();   
        elseif strcmp(currentTabName,'Tremolo Analysis')
            %use the 'backspace' key for deleting portamento
            delPluckFn(); 
        elseif strcmp(currentTabName,'Strumming Analysis')
            %use the 'backspace' key for deleting portamento
            delStrummingFn();
        end
    elseif strcmp(eventData.Key,'leftarrow')%��Ҫ����note/tremolo
        %the left key is pressed to select feature on the pitch curve
        if strcmp(currentTabName,'Pitch Detection') && isfield(data,'pitch') && isscalar(data.pitchPoint)
            data=rmfield(data,'pitchPointArea');
            if data.pitchIndex~=1
                data.pitchIndex=data.pitchIndex-1;
            end
            data.pitchPoint=freqToMidi(data.pitch(data.pitchIndex));
            data.pitchPointTime=data.pitchTime(data.pitchIndex);
            data.pitchPointArea=plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio);
            model=get(data.PitchXaxisPara,'value');
            midi=notename(data.pitchPoint);
            data.PitchXMIDI.set('string',num2str(midi{1}));
            if model==1%freq
                data.PitchXEdit.set('string',num2str(data.pitch(data.pitchIndex)));
            else%MIDI
                data.PitchXEdit.set('string',num2str(data.pitchPoint));
            end
        elseif strcmp(currentTabName,'Vibrato Analysis') && isfield(data,'patchVibratoArea')
            %if it is for vibrato listbox
            if data.numViratoSelected == 1
                data.numViratoSelected = size(data.vibratos,1);
            else
                data.numViratoSelected = data.numViratoSelected - 1;
            end
            
            %higlight the selected feature
            plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);

            %show individual feature in the sub axes
            plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi);
            %show the highlighted num of feature in the corresponding feature listbox
            data.vibratoListBox.Value = data.numViratoSelected;
            
            %show individual vibrato statistics
            plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
        elseif strcmp(currentTabName,'Sliding Analysis') && isfield(data,'patchPortamentoArea')
            %if it is for portamento listbox
            if data.numPortamentoSelected == 1
                data.numPortamentoSelected = size(data.portamentos,1);
            else
                data.numPortamentoSelected = data.numPortamentoSelected - 1;
            end
                     
            %higlight the selected feature
            plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);

            %show the highlighted num of feature in the corresponding feature listbox
            data.portamentoListBox.Value = data.numPortamentoSelected;
            
            %show individual feature in the sub axes
            plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
            
            %plot the portamento logisitic fitting line and portamento para
            %in the sub axes
            if isfield(data,'portamentosDetailLogistic')  
                %plot the portamento Logistic fitting line
                plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
                data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);

                %plot the portamneto statistics
                plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected)            
            end
        end
    elseif strcmp(eventData.Key,'rightarrow')%��Ҫ����note/tremolo
        %the right key is pressed to select feature on the pitch curve
        if strcmp(currentTabName,'Pitch Detection') && isfield(data,'pitch') && isscalar(data.pitchPoint)
            data=rmfield(data,'pitchPointArea');
            if data.pitchIndex~=length(data.pitch)
                data.pitchIndex=data.pitchIndex+1;
            end
            data.pitchPoint=freqToMidi(data.pitch(data.pitchIndex));
            data.pitchPointTime=data.pitchTime(data.pitchIndex);
            data.pitchPointArea=plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio);
            model=get(data.PitchXaxisPara,'value');
            midi=notename(data.pitchPoint);
            data.PitchXMIDI.set('string',num2str(midi{1}));
            if model==1%freq
                data.PitchXEdit.set('string',num2str(data.pitch(data.pitchIndex)));
            else%MIDI
                data.PitchXEdit.set('string',num2str(data.pitchPoint));
            end
        elseif strcmp(currentTabName,'Vibrato Analysis') && isfield(data,'patchVibratoArea')
            %if it is for vibrato listbox
            if data.numViratoSelected == size(data.vibratos,1)
                data.numViratoSelected = 1;
            else
                data.numViratoSelected = data.numViratoSelected + 1;
            end
            
            %higlight the selected feature
            plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);

            %show individual feature in the sub axes
            plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi);

            %show the highlighted num of feature in the corresponding feature listbox
            data.vibratoListBox.Value = data.numViratoSelected;
            
            %show individual vibrato statistics
            plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
        elseif strcmp(currentTabName,'Sliding Analysis') && isfield(data,'patchPortamentoArea')
            %if it is for portamento listbox
            if data.numPortamentoSelected == size(data.portamentos,1)
                data.numPortamentoSelected = 1;
            else
                data.numPortamentoSelected = data.numPortamentoSelected + 1;
            end
                     
            %higlight the selected feature
            plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);
            
            %show the highlighted num of feature in the corresponding feature listbox
            data.portamentoListBox.Value = data.numPortamentoSelected;

            %show individual feature in the sub axes
            plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
            
            %plot the portamento logisitic fitting line and portamento para
            %in the sub axes
            if isfield(data,'portamentosDetailLogistic')  
                %plot the portamento Logistic fitting line
                plotLogisticFittingCurve(data.portamentosDetail,data.numPortamentoSelected,...
                data.portamentoXaxisPara,data.portamentosDetailLogistic,data.axePitchTabPortamentoIndi);

                %plot the portamneto statistics
                plotPortamentoStatistics(data.textPort,data.portamentoPara,data.numPortamentoSelected)            
            end
        end   
    elseif strcmp(eventData.Key,'p')%OK
        %the key 'p' is pressed that play the corresponding feature (note/vibrato/portamento/tremolo)
        playAudioFn(hObject,eventData);
    end
end

function closereq1(hObject,eventData)
    delete('temp\*');%delete the temporary audio before window closing;
    delete('temp_multichannel\*');%delete the temp channel 
    delete('output\*');%delete the debleeded audio
    global data;
    if isfield(data,'f2')    
        delete(data.f2);
    end
    clear global data;%clear glabal variable data;
    if isempty(gcbf)
        if length(dbstack) == 1
            warning(message('MATLAB:closereq:ObsoleteUsage'));
        end
        close('force');
    else
        delete(gcbf);
    end
end
%-------END of Callback functions-------------------
