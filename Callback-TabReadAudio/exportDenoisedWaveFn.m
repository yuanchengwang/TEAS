function exportDenoisedWaveFn(hObject,eventData,varargin)
%EXPORTDENOISEDWAVEFN export the denoised audio
%   Detailed explanation goes here

    global data;
    %defense code
    if strcmp(data.tgroup.SelectedTab.Title,'Read Audio')
        if isfield(data,'fileName')
            savedFileName = [data.fileName,'_DenoisedWave'];
        else
            if ~isfield(data,'NoisefileName')
                msgbox('No denoised signal');
                return
            end
            savedFileName = data.NoisefileName;%rewrite the input denoised file
        end
    else
        if ~isfield(data,'denoisedWaveTrack')
            msgbox('No imported audio');
            return
        else
            if length(data.denoisedWaveTrack)~=data.track_nb
                msgbox('Imported track audio not enough.');
                return
            end
            for i=1:data.track_nb
                if isempty(data.denoisedWaveTrack{i})
                    msgbox('No',num2str(i),'track audio');
                    return
                end
            end
            audiofile=dir('.\temp_multichannel');
            savedFileName=split(audiofile(3).name,'-');
            p=varargin{1};
            savedFileName=[savedFileName{1},'_source_',num2str(p)];
        end
    end
    savedFileType = {'*.wav';'*.mp3';'*.mat'};
    
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
    if isnumeric(savedFileName) == 0
    splitResults = strsplit(savedFileName,'.');
    if strcmp(data.tgroup.SelectedTab.Title,'Read Audio')
        if isnumeric(savedFileName) == 0
            %if the user doesn't cancel, then save the data
            if strcmp(splitResults{2},'mat')
               %save the mat data
               save([savedPathName,savedFileName],'data.fs','data.Cleaned_speech');
            elseif strcmp(splitResults{2},'wav')
               audiowrite(strcat(savedPathName,savedFileName),data.Cleaned_speech,data.fs); 
            else%mp3write module is already in the file
               mp3write(data.Cleaned_speech,data.fs,strcat(savedPathName,savedFileName));
            end
        end
    else
        if isfield(data,'denoisedWaveTrack')
            audiowrite(strcat(savedPathName,savedFileName),data.denoisedWaveTrack{p},data.fs);
        end
    end
    end
end

