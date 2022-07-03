function getPitchCurveFn(hObject,eventData)
%GETPITCHCURVE get the pitch curve using pyin method and plot pitch curve 
    global data;  
    f0thres=split(data.PitchFreThresEdit.String,'-');
    audiopath=dir('temp\*');
    audio_path=fullfile(audiopath(end).folder,audiopath(end).name);
    disp('Pitch detection started...');
    if strcmp(data.pitchMethod,'Yin') == 1
        %--------using YIN method------------------
        P.minf0=str2num(f0thres{1});
        P.maxf0=str2num(f0thres{2});
        P.hop = 256;
        %h = waitbar(0,'Detecting pitch using YIN...');
        yinOutput = yin(audio_path,P); 
        %close(h);
        data.pitch = ((2.^yinOutput.f0)*440)'; %convert YIN's original output F0 from 440Hz octave to Hz, colum vector
    %     data.pitch(yinOutput.ap>0.4) = nan; %raw remove non-pitched sound
        data.pitchTime = ((1:length(data.pitch))/(yinOutput.sr/yinOutput.hop));   
        %------------------------------------------
        
    elseif strcmp(data.pitchMethod,'Pyin(Matlab)') == 1
        %--------using PYIN method MATLAB------------------
        P.minf0=str2num(f0thres{1});
        P.maxf0=str2num(f0thres{2});
        [data.pitch,data.pitchTime] = getPitchPyin(audio_path,P);
        %------------------------------------------
    elseif strcmp(data.pitchMethod,'Pyin(Tony)') == 1
    %use pYin to get f0
    %use the changed parameters in pyinParameters.n3 file.
    %force to override the existing file.
%     system(['./sonic-annotator -t pyinParameters.n3 ',data.filePath,data.fileNameSuffix,' -w csv --csv-force']);
    
%     system(['./sonic-annotator -t pyinParameters.n3 ',data.filePath,data.fileNameSuffix,' -w csv']);
    %------using pyin sv plugin---------------
%     get the cmd output and directly use the cmd output
%     shoud add the dumb quotes before and after file names to allow the
%     file name has spaces
    %h = waitbar(0,'Detecting pitch using Pyin(Tony)...');
    [~,cmdout] = system(['sonic-annotator -t pyin.n3 "',audio_path,'" -w csv --csv-stdout'],'-echo');
    C = strsplit(cmdout,',');
    data.pitchTime = zeros((length(C)-2)/2,1);
    data.pitch = zeros((length(C)-2)/2,1);
    for i = 3:2:length(C)
        data.pitchTime(floor(i/2),1) = str2double(C{i});
        data.pitch(floor(i/2),1) = str2double(C{i+1});
    end
        
    %close(h);
    %---------------------------------------   
    
    elseif  strcmp(data.pitchMethod,'BNLS') == 1%Bayesian non-linear square
        %[signal,fs]=audioread(fullfile(data.filePath,data.fileNameSuffix));
        %[signal,fs]=audioread(audiopath);
        cmdout = BF0NLS(data.Cleaned_speech,data.fs,[str2num(f0thres{1}),str2num(f0thres{2})]); %BF0NLS_origin the version with original parameters
        %data.loss=cmdout.loss;
        data.pitch = cmdout.ff;
        data.pitchTime=cmdout.tt;
        
%     elseif strcmp(data.pitchMethod,'SFPE') == 1%String fret plucking estimation
%         [signal,fs]=audioread(fullfile(data.filePath,data.fileNameSuffix));
%         [data.pitchcmdout,data.pitchTime] = SFPE(signal(:,1),fs,[str2num(f0thres{1}),str2num(f0thres{2})]); %BF0NLS_origin the version with original parameters
    end
    disp('Pitch detection finished.');
    %make it to column vector
    if iscolumn(data.pitchTime) == 0
        data.pitchTime = data.pitchTime';
    end
    
    if iscolumn(data.pitch) == 0
        data.pitch = data.pitch';
    end
    
    %zero padding if the pitch time doesn't increase continuously
    [data.pitch,data.pitchTime]=modify_pitch(data.pitch,data.pitchTime);
    
    %delete all NaNs in pitchTime and pitch vectors
%     data.pitchTime(isnan(data.pitchTime)) = [];
%     data.pitch(isnan(data.pitch)) = [];
    %clear Note
    if isfield(data,'onset')
        data=rmfield(data,'onset');
    end
    if isfield(data,'offset')
        data=rmfield(data,'offset');
    end
    plotClearFeature('Note');
    if isfield(data,'NoteOnset')
        data = rmfield(data,'NoteOnset');
        data = rmfield(data,'NoteDuration');
        data = rmfield(data,'avgPitch');
        if isfield(data,'fret')
            data = rmfield(data,'fret');
        end
    end
    %clear vibrato
    plotClearFeature('Vibrato');
    if isfield(data,'FDMoutput')
        data = rmfield(data,'FDMoutput');
    end
    if isfield(data,'PERoutput')
        data = rmfield(data,'PERoutput');
    end
    %clear portamento
    plotClearFeature('Portamento');
    
    plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio,1,1);%plot_flag,plot_clean
    plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato,0,1);
    plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,1);
    plotPitch(data.pitchTime,data.pitch,data.axePitchTabPortamento,0,1);
    if data.CB.plot_audio.Value
        data.plotEdgeWave=plotAudio((1:size(data.Cleaned_speech,1))/data.fs,data.Cleaned_speech,data.axeOnsetOffsetStrength,data.NoisefileNameSuffix,1); 
    end
end
