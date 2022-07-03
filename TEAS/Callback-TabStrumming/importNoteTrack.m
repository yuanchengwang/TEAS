function importNoteTrack(hObject,eventData,i)
%IMPORTONSETTRACK import the note track for ith string, only note can be
%imported, otherwise the chord cannot be defined.
global data;
%input onset by edge file or note file.
    [fileNameSuffix,filePath] = uigetfile({'*.csv';'*.txt'},'Select File');
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the note filepath
        fullPathName = strcat(filePath,fileNameSuffix);  
        data.TrackfileName=fileNameSuffix(1:end-4);
        %pitchData is the matrix in the file
        noteData = importdata(fullPathName);
        %assert(size(noteData,2)==2 || 4,'Bad format for the note file or no note in imported file.');%only edge
        data.OnsetStr{i}= noteData(:,1);%good for note and double_peak or not edge
        if size(noteData,2)==5
            data.velocity_track{i}=noteData(:,5);
        end
    end
end