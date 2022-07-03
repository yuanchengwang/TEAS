function importDenoisedWaveFn(hObject,eventData,varargin)
%IMPORTDENOISEDWAVEFUNCTION read audio for denoised signal
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
            audio=a.audio;%This type corresponds to the denoised wave export
            fs=a.fs;
        else
            [audio,fs] = audioread(fullPathName);
        end
        if fs~=data.fs
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
        %remove the things after steps
        
        
        if strcmp(data.tgroup.SelectedTab.Title,'Read Audio')
            data.time = (1:size(audio,1))/data.fs;
            data.NoisefileName  = splitResults{1};       
            data.Cleaned_speech = audio;
            data.NoisefilePath = filePath;
            data.NoisefileNameSuffix = fileNameSuffix; 

            plotAudio(data.time,data.Cleaned_speech,data.axedenoisedWave,data.NoisefileNameSuffix,0);  
            plotAudio(data.time,data.Cleaned_speech,data.axePitchWave,data.NoisefileNameSuffix,0);
            plotAudio(data.time,data.Cleaned_speech,data.axeWaveTabTremolo,data.NoisefileNameSuffix,0);
            %temporary save for pitch detection task
            cla(data.axePitchTabAudio);
            if isfield(data,'pitch')
                data=rmfield(data,'pitch');
                data=rmfield(data,'pitchTime');
            end
            if isfield(data,'Cleaned_speech_spec')
                data=rmfield(data,'Cleaned_speech_spec');
            end
            if isfield(data,'energy')
                data=rmfield(data,'energy');
            end 
            if isfield(data,'onset')
                data=rmfield(data,'onset');
            end
            if isfield(data,'offset')
                data=rmfield(data,'offset');
            end
            
            if isfield(data,'tremoloListBox')
               data.tremoloListBox.String=[];
               cla(data.axeWaveTabTremoloIndi);
            end
            if isfield(data,'mel_spec')
                data=rmfield(data,'mel_spec');
            end
            delete('temp\*');
            audiowrite(['temp\',data.NoisefileName,'.wav'],data.Cleaned_speech,data.fs);   
        elseif strcmp(data.tgroup.SelectedTab.Title,'Strumming Analysis')
            data.polyStrumAudio=audio;
            data.polyStrumAudioSuffix=fileNameSuffix;
        else%synthesis+MIDI mono
            p=varargin{1};
            data.denoisedWaveTrack{p}=audio;
            data.denoisedWaveTrackSuffix{p}=fileNameSuffix;
            %delete('temp_multichannel\*');%it will remove all the other tracks
            %only remove the same track
            file=dir('temp_multichannel\*.wav');
            for i=1:length(file)
                if str2num(file(i).name(end-4))==p
                    delete(['temp_multichannel\',file(i).name]);
                end
            end
            audiowrite(['temp_multichannel\',splitResults{1},'_str',num2str(p),'.wav'],audio,data.fs); 
        end
    end
end

