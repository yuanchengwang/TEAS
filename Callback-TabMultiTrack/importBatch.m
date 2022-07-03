function importBatch(hObject,eventData)
%import the .m file for a fast import
global data;
%Overlap warning
ansOnset = questdlg('Warning: Comfirm to overlap all imported data in syn tab?','Attention','Yes','No','No');
if strcmp(ansOnset,'No')
    return
end
%Create or overlap for the next step
[fileNameSuffix,filePath] = uigetfile({'*.mat'},'Select File');
if isnumeric(fileNameSuffix)==0
fullPathName = strcat(filePath,fileNameSuffix);
data_temp=load(fullPathName);
file=fieldnames(data_temp.data_temp);
for i=1:length(file)
    eval(['data.',file{i},'=data_temp.data_temp.',file{i},';']);
end
end
end