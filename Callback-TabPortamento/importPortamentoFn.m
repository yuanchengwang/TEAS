function importPortamentoFn(hObject,eventData)
%importPortamentoFn Import the portamento annotation.csv file
%   The portamento annotation file should be [start(s):end(s):duration(s)]
    global data;
    %input portamento annation file
    [fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the portamento annotation
        %.csv file
        fullPathName = strcat(filePath,fileNameSuffix);
        portamentos = csvread(fullPathName);
        if strcmp(data.tgroup.SelectedTab.Title,'Sliding Analysis')
            data.portamentos= portamentos;
        if size(data.portamentos,2)==3
            data.portamentos(:,4)=ones(size(data.portamentos,1),1);
            msgbox('The pitch transition playing techniques types are not defined, we set all by portamento by default. Please modify it yourself.');
        end
        
        %Get the individual portamento time and pitch vector 
        %portamentosDetail:[time from 0:pitch:orginal time]
        if isfield(data,'pitchVFree')
            data.portamentosDetail = getPassages(data.pitchTime,data.pitchVFree,data.portamentos,0);
        else
            data.portamentosDetail = getPassages(data.pitchTime,data.pitch,data.portamentos,0);
        end

        %remove the old portamentosDetailLogistic
        if isfield(data,'portamentosDetailLogistic') 
            data = rmfield(data,'portamentosDetailLogistic');
        end
        %plot the portamentos on the pitch curve
        if isfield(data,'patchPortamentoArea') == 1
            %if there are already some portamentos
            delete(data.patchPortamentoArea);
        end
        data.patchPortamentoArea =  plotFeaturesArea(data.portamentos,data.axePitchTabPortamento);

        %highlight the first portamento
        data.numPortamentoSelected = 1;
        plotHighlightFeatureArea(data.patchPortamentoArea,data.numPortamentoSelected,1);

        %plot the portamento num in the listbox
        plotFeatureNum(data.portamentos,data.portamentoListBox);

        %show the first portamento in vibrato listbox
        data.portamentoListBox.Value = data.numPortamentoSelected;
        
        %show the first portamento's X(time) range in the edit text
        data.portamentoXEdit.String=[num2str(data.portamentos(data.numPortamentoSelected,1)),'-',num2str(data.portamentos(data.numPortamentoSelected,2))];
        
        %show the type
        data.PortamentoType(data.numPortamentoSelected).Value=data.portamentos(data.numPortamentoSelected,4);
        
        %show individual portamento in the sub axes
        plotPitchFeature(data.portamentosDetail, data.numPortamentoSelected,data.portamentoXaxisPara,data.axePitchTabPortamentoIndi);
        else
            %defense code, the note must exist for corresponding track
            if isfield(data,'PitchTrack')
                currentname=data.subgroup.SelectedTab.Title;
            	p=str2num(currentname(isstrprop(currentname,'digit'))); 
                if isempty(data.PitchTrack{p})
                    msgbox('No pitch curve for corresponding track imported.');
                    return
                else
                    pitch=data.PitchTrack{p};
                    pitchTime=data.PitchTimeTrack{p};
                end 
            else
                msgbox('No pitch for corresponding track imported.')
                return
            end
            
            %Silence cannot be located in portamento area and Add pitch-range for portamento
            a=zeros(size(portamentos,1),2);
            for i=1:size(portamentos,1)
                [~,time1]=min(abs(pitchTime-portamentos(i,1)));%find the closest onset/offset.
                [~,time2]=min(abs(pitchTime-portamentos(i,2)));
                pitch_temp=pitch(time1:time2);
                if sum(pitch_temp==0)>0
                    disp(i);
                    msgbox('Bad portamento imported, no silence can be located in portamento areas.');
                    return
                end
                a(i,:)=[min(pitch_temp),max(pitch_temp)];
            end
            data.PortamentoTrack{p}=[portamentos,a];
        end
    end 
end

