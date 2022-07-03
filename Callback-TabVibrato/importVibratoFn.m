function importVibratoFn( hObject,eventData )
%IMPORTVIBRATOFN import the vibrato annotation.csv file
%   The vibrato annotation file should be [start(s):end(s):duration(s)]
    global data;
    %input vibrato annation file
    [fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the audio
        fullPathName = strcat(filePath,fileNameSuffix);
        vibratos = csvread(fullPathName);
        if strcmp(data.tgroup.SelectedTab.Title,'Vibrato Analysis')
            h = waitbar(0,'Import vibrato...');
            data.vibratos=vibratos;
            if size(data.vibratos,2)==3
                data.vibratos(:,4)=ones(size(data.vibratos,1),1);
                msgbox('The pitch fluctuation playing technique types are not defined, we set all by vibrato by default. Please modify it yourself.');
            end
        %Get the individual vibrato time and pitch vector 
        %vibratosDetail:[time from 0:pitch:orginal time]
        data.vibratosDetail = getPassages(data.pitchTime,data.pitch,data.vibratos,0);

%         splitResults = strsplit(fileNameSuffix,'.');
%         data.fileName  = splitResults{1};
%         suffix = splitResults{2};
%         data.audio = audio;
%         data.filePath = filePath;
%         data.fileNameSuffix = fileNameSuffix; 

        %----START of getting vibrato para-------
        %get the threshold for DT
        freThreshRaw = strsplit(data.vibFreThresEdit.String,'-');
        ampThreshRaw = strsplit(data.vibAmpThresEdit.String,'-');

        freqThresh = [str2double(cell2mat(freThreshRaw(1))),str2double(cell2mat(freThreshRaw(2)))];
        ampThresh = [str2double(cell2mat(ampThreshRaw(1))),str2double(cell2mat(ampThreshRaw(2)))];
        
        %vibratosParaFDM: [vibrato rate:vibrato extent]
        method = get(data.methodVibratoChange,'Value');
        method1= get(data.methodVibratoDetectorChange,'Value');
        if ~isfield(data,'FDMoutput')
            [data.FDMtime,data.FDMoutput] = FDMestimate(data.pitch,data.pitchTime);
        end
        thres=[min(freqThresh(2),10),min(ampThresh(2),4)];
        vibratosParaFDM = getVibratoParaFDM2(data.vibratos,data.FDMtime,data.FDMoutput,thres);
        waitbar(50/100,h,sprintf('%d%% Import vibrato...',50))
        %get vibrato rate, extent(using max-min method) vibrato sinusoid similarity for all passages
        vibratoNames = fieldnames(data.vibratosDetail);
        
        %vibratoParaMin: [rate, extent, std rate, std extent, SS]
        vibratoParaMaxMin = zeros(length(vibratoNames),5);
        vibratosSS = [];%zeros(length(vibratoNames),1);
        for i = 1:length(vibratoNames)
            vibratoTimePitch = getfield(data.vibratosDetail, char(vibratoNames(i)));
            vibratoTimePitch=vibratoTimePitch(:,[1,2]);
            avgpitch=median(vibratoTimePitch(:,2)).*[2^(-1/4),2^(1/4)];
            vibratoTimePitch=vibratoTimePitch(vibratoTimePitch(:,2)<avgpitch(2) & vibratoTimePitch(:,2)>avgpitch(1),:);
            %sinusoid similarity
            SS = vibratoShape(vibratoTimePitch);
            if SS>1                
                continue
            end
            vibratosSS(i)=SS;
            vibratoParaMaxMin(i,[1:4]) = vibratoRateExtent(vibratoTimePitch);
            vibratoParaMaxMin(i,5) = vibratosSS(i);
        end
        %add sinusoid similarity to the vibratosParaFDM ([rate:extent:SS])        
            vibratosParaFDM = [vibratosParaFDM,vibratosSS'];

        %vibratosPara{1}from FDM
        %vibratosPara{2}from Max-min
        data.vibratoPara{method,method1,1} = vibratosParaFDM;
        data.vibratoPara{method,method1,2} = vibratoParaMaxMin;
        %----END of getting vibrato para-------

        waitbar(75/100,h,sprintf('%d%% Import vibrato...',75))
        %plot the vibratos on the pitch curve
        if isfield(data,'patchVibratoArea') == 1
            %if there are already some vibratos
            delete(data.patchVibratoArea);
        end
        data.patchVibratoArea =  plotFeaturesArea(data.vibratos,data.axePitchTabVibrato);

        %highlight the first vibrato
        data.numViratoSelected = 1;
        plotHighlightFeatureArea(data.patchVibratoArea,data.numViratoSelected,1);

        %plot the vibrato num in the listbox
        plotFeatureNum(data.vibratos,data.vibratoListBox);

        %show the first vibrato in vibrato listbox
        data.vibratoListBox.Value = data.numViratoSelected;
        
        %show thes vibrato's X(time) range in the edit text
        data.vibratoXEdit.String=[num2str(data.vibratos(data.numViratoSelected,1)),'-',num2str(data.vibratos(data.numViratoSelected,2))];
        
        %show individual vibrato in the sub axes
        plotPitchFeature(data.vibratosDetail, data.numViratoSelected,data.vibratoXaxisPara,data.axePitchTabVibratoIndi)
        
        %show the type
        data.VibratoType(data.numViratoSelected).Value=data.vibratos(data.numViratoSelected,4);
        
        %show the first individual vibrato statistics
        plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoChange,data.methodParameterChange);
        close(h)
        else%for time
            %defense code, the note must exist for corresponding track
            if isfield(data,'NoteTrack')
                currentname=data.subgroup.SelectedTab.Title;
            	p=str2num(currentname(isstrprop(currentname,'digit'))); 
                if p>length(data.NoteTrack)
                    msgbox('No note for corresponding track imported.');
                else
                if isempty(data.NoteTrack{p})
                    msgbox('Empty note for corresponding track imported.');
                    return
                else
                    notes=data.NoteTrack{p};
                end 
                end
            else
                msgbox('No notes for corresponding track imported.')
                return
            end
            %vibrato must be within a note.
            for i=1:size(vibratos,1)
                if vibratos(i,1)<notes(1,1)
                    disp(['Vibrato and note no.:',num2str(i),',',num2str(1)]);
                    msgbox('Bad vibrato imported');
                    return
                end
                if vibratos(i,2)>round(sum(notes(end,1:2)),4)%end
                    disp(['Vibrato and note no.:',num2str(i),',',num2str(size(notes,1))]);
                    msgbox('Bad vibrato imported');
                    return
                end
                %if isfield(data,'notes')
                if size(notes,1)>1%in middle
                    for j=1:size(notes,1)-1
                        if (vibratos(i,1)<notes(j+1,1)&& vibratos(i,1)>round(sum(notes(j,1:2)),4))||(vibratos(i,2)<notes(j+1,1)&& vibratos(i,2)>round(sum(notes(j,1:2)),4))
                            disp(['Vibrato and note no.:',num2str(i),',',num2str(j)]);
                            msgbox('Bad vibrato imported');
                            return
                        end
                    end
                end
            end
            %add note for vibrato
            a=zeros(size(vibratos,1),1);
            for i=1:size(vibratos,1)
                for j=1:size(notes,1)
                    if vibratos(i,1)<=round(sum(notes(j,1:2)),4) && vibratos(i,1)>=notes(j,1)
                        a(i)=notes(j,3);
                        break
                    end
                end
            end
            data.VibratoTrack{p}=[vibratos,a];
        end
    end 
end

