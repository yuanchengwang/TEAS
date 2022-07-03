function exportEdgeFn(hObject,eventData)
%EXPORTNOTEFN export the [onset,duration,offset] for each note.
%   Detailed explanation goes here

    global data;
    if isfield(data,'fileName')
        savedFileName = data.fileName;
    elseif isfield(data,'NoisefileName')
        savedFileName = data.NoisefileName;%rewrite the input denoised file
    else
        savedFileName=[];
    end
    savedFileName = [savedFileName,'_edge_str',num2str(data.track_index)];
    savedFileType = {'*.csv';'*.txt';};
    
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);

    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        if ~isempty(strfind(savedFileName,'.csv')) == 1
            %save the pitch curve as csv
            %csvwrite([savedPathName,savedFileName],[data.onset*data.hop_length/data.fs;data.offset*data.hop_length/data.fs]');
            if data.double_peak
                if length(data.onset(1:2:end))~=length(data.onset(2:2:end))
                    msgbox('Odd number for onset.');
                    return
                end
                if isfield(data,'offset')
                    dlmwrite([savedPathName,savedFileName],[data.onset(1:2:end)*data.hop_length/data.fs;data.onset(2:2:end)*data.hop_length/data.fs;data.offset*data.hop_length/data.fs]','precision','%.4f');
                else
                    dlmwrite([savedPathName,savedFileName],[data.onset(1:2:end)*data.hop_length/data.fs;data.onset(2:2:end)*data.hop_length/data.fs]','precision','%.4f');
                end    
            else
                if isfield(data,'offset')
                    dlmwrite([savedPathName,savedFileName],data.onset'*data.hop_length/data.fs,'precision','%.4f');
                else
                    dlmwrite([savedPathName,savedFileName],[data.onset*data.hop_length/data.fs;data.offset*data.hop_length/data.fs]','precision','%.4f');
                end
            end
        elseif ~isempty(strfind(savedFileName,'.txt')) == 1
            %save the pitch curve as txt
            fid = fopen([savedPathName,savedFileName],'w');
            if data.double_peak
                if isfield(data,'offset')
                    for j = 1:length(data.onset)/2
                        fprintf(fid,[num2str(data.onset(2*(j-1)+1)*data.hop_length/data.fs),'	',num2str(data.onset(2*j)*data.hop_length/data.fs),'	',num2str(data.offset(j)*data.hop_length/data.fs),'\r\n']);
                    end
                else
                    for j = 1:length(data.onset)/2
                        fprintf(fid,[num2str(data.onset(2*(j-1)+1)*data.hop_length/data.fs),'	',num2str(data.onset(2*j)*data.hop_length/data.fs),'\r\n']);
                    end
                end
            else
                if isfield(data,'offset')
                    for j = 1:length(data.onset)/2
                        fprintf(fid,[num2str(data.onset*data.hop_length/data.fs),'	',num2str(data.offset(j)*data.hop_length/data.fs),'\r\n']);
                    end
                else
                    for j = 1:length(data.onset)/2
                        fprintf(fid,[num2str(data.onset*data.hop_length/data.fs),'\r\n']);
                    end
                end
            end
            fclose(fid);                                  
         end
    end
end

