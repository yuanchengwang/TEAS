function readAudioFn(hObject,eventData)
%READAUDIOFUNCTION Summary of this function goes here
%   Detailed explanation goes here
    global data;
    %input audio
    [fileNameSuffix,filePath] = uigetfile({'*.wav';'*.mp3';'*.mat'},'Select File');
    
    if isnumeric(fileNameSuffix) == 0
        splitResults = strsplit(fileNameSuffix,'.');
        suffix = splitResults{2};
        %if the user doesn't cancel, then read the audio
        fullPathName = strcat(filePath,fileNameSuffix);
        if strcmp(suffix,'mat')
            a=load(fullPathName);
            audio=a.audio;
            fs=a.fs;
        else
            [audio,fs] = audioread(fullPathName);
        end
        if fs~=44100
            audio=resample(audio,data.fs,fs);
        end
        %sum the two channels into one channel
        channels = size(audio,2);
        if channels>length(audio)
            audio=audio';
        end
        if channels > 1
            audio = sum(audio,2);
        end
        
        if strcmp(data.tgroup.SelectedTab.Title,'Read Audio')
            data.time = (1:size(audio,1))/data.fs;

            data.fileName  = splitResults{1};
            data.audio = audio;
            data.filePath = filePath;
            data.fileNameSuffix = fileNameSuffix; 
            %clear the noise range
            if isfield(data,'noise_ranges')
                data=rmfield(data,'noise_ranges');
            end
            plotAudio(data.time,data.audio,data.axeWave,data.fileNameSuffix,0);  
        end
    end
end

