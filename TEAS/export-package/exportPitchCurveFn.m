function exportPitchCurveFn(hObject,eventData)
%EXPORTPITCHCURVEFN export the pitch curve
%   Detailed explanation goes here

    global data;
    if isfield(data,'fileName')
        savedFileName = data.fileName;
    else
        savedFileName = data.NoisefileName;%use the input denoised file
    end
    savedFileName = [savedFileName,'_pitch_str',num2str(data.track_index)];
    savedFileType = {'*.csv';'*.txt';};
    
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
    
    if isnumeric(savedFileName) == 0
        pitch=data.pitch;
        pitch_flag=zeros(size(data.pitch));
        pitchTime=data.pitchTime;
        if isfield(data,'notes')
            ansOnset = questdlg('Warning: Clip and export the pitch with the correct note segment(s)?','Attention','Yes','No','No');
            switch ansOnset
            case 'Yes'     
                %pitch_dilate([0,0,0,2,4,5,0,0,6],1:9,[2,2;6,2])
                pitch=pitch_dilate(pitch,pitchTime,data.notes);
            case 'No'
            end
        end
        %if the user doesn't cancel, then save the data
        if ~isempty(strfind(savedFileName,'.csv')) == 1
            %save the pitch curve as csv
            %csvwrite([savedPathName,savedFileName],[data.pitchTime,data.pitch]);
            dlmwrite([savedPathName,savedFileName],[pitchTime,pitch],'precision','%.9f');
        elseif ~isempty(strfind(savedFileName,'.txt')) == 1
                %save the pitch curve as txt
                fid = fopen([savedPathName,savedFileName],'w');
                for j = 1:size(pitchTime,1)
                    fprintf(fid,[num2str(pitchTime(j)),'	',num2str(pitch(j)),'\r\n']);
                end
                fclose(fid);                                  
         end
    end
end

