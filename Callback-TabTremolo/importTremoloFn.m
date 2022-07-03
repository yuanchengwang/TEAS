function importTremoloFn(hObject,eventData)
%importTremoloFn Import the tremolo annotation.csv file
%   The tremolo annotation file should be [start(s):end(s):duration(s)]
    global data;
    %input tremolo annation file
    [fileNameSuffix,filePath] = uigetfile('*.csv','Select File');
    if isnumeric(fileNameSuffix) == 0      
        %if the user doesn't cancel, then read the tremolo annotation
        %.csv file
        fullPathName = strcat(filePath,fileNameSuffix);
        candidateNote = csvread(fullPathName);
        if strcmp(data.tgroup.SelectedTab.Title,'Tremolo Analysis')
            if size(candidateNote,2)==4
                data.candidateNote(:,5)=1;
            end
            data.candidateNote=candidateNote(:,1:5);
            
            %remove the old tremolosDetailLogistic
            if isfield(data,'tremolosPara') 
                data = rmfield(data,'tremolosPara');
            end

            %plot the tremolos on the pitch curve
            if isfield(data,'patchTremoloArea')
                %if there are already some tremolos
                delete(data.patchTremoloArea);
            end
            data.patchTremoloArea =  plotFeaturesArea(data.candidateNote,data.axeWaveTabTremolo);

            %highlight the first tremolo
            data.numTremoloSelected = 1;
            plotHighlightFeatureArea(data.patchTremoloArea,data.numTremoloSelected,1);

            %plot the tremolo num in the listbox
            plotFeatureNum(data.candidateNote,data.tremoloListBox);

            %show the first tremolo in tremolo listbox
            data.tremoloListBox.Value = data.numTremoloSelected;

            %show individual tremolo in the sub axes
            time=data.notes(data.numTremoloSelected,1:2);
            timerange=round(time(1)*data.fs):round(sum(time)*data.fs);
            time=timerange/data.fs;
            audio=data.Cleaned_speech(timerange);
            xAxis = get(data.tremoloXaxisPara,'Value');
            if xAxis == 2%normalized time
                time=time-time(1);
            end
            %Type of the selected note are not defined here.
            data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5);
            plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
            if isfield(data,'tremoloPara')
            data=rmfield(data,'tremoloPara');
            end
            for i=1:length(data.treParaName)
                data.textTremolo(i,1).String=[];
            end 
            if size(candidateNote,2)~=5
                for i=1:size(candidateNote,1)
                    non_zeros=candidateNote(i,6:end);
                    if sum(non_zeros)~=0%If there exists at least a pluck
                        pos=non_zeros~=0;
                        data.onset_tremolo{i}=non_zeros(pos);
                    end
                end
                %plot
                axes(data.axeWaveTabTremoloIndi);
                y=data.axeWaveTabTremoloIndi.YLim;
                onset=data.onset_tremolo{data.numTremoloSelected};
                if data.tremoloXaxisPara.Value==2
                    onset=onset-data.candidateNote(data.numTremoloSelected,1);
                end
                if isfield(data,'patchTremoloOnset')
                    delete(data.patchTremoloOnset);
                    data=rmfield(data,'patchTremoloOnset');
                end
                hold on;
                for j=1:length(onset)
                    data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
                end
                tremolo_estimation(0);
                if data.changeTremoloMethod.Value~=1
                    [~,a]=min(abs(data.EdgeTime-time(1)));
                    [~,b]=min(abs(data.EdgeTime-time(end)));
                    data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                else
                    [~,a]=min(abs(data.log_energy_time-time(1)));
                    [~,b]=min(abs(data.log_energy_time-time(end)));     
                    data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                end
                hold off;
                %update the parameters
                data.tremoloPara=cell(size(data.candidateNote,1),length(data.treParaName));
                
                if data.double_peak
                    %velocity=round(20*log10(data.energy(max(round(data.notes(:,1)*data.fs/data.hop_length)-round(data.win_length/2/data.hop_length),1)))); 
                    velocity=tremolo_velocity(candidateNote(:,6));
                else
                    velocity=tremolo_velocity(data.notes(:,1));
                end
                for i=1:size(data.candidateNote,1)
                    data.tremoloPara{i,1}=velocity(i);
                    if data.double_peak
                        data.tremoloPara{i,2}=(length(data.onset_tremolo{i})+1)/2;
                    else
                        data.tremoloPara{i,2}=length(data.onset_tremolo{i})+1;%length([])=0
                    end                    
                    if data.tremoloPara{i,2}>=2
                        if data.double_peak
                            data.tremoloPara{i,3}=1/mean(diff([data.candidateNote(i,1),data.onset_tremolo{i}(2:2:end)]));
                        else
                            data.tremoloPara{i,3}=1/mean(diff([data.candidateNote(i,1),data.onset_tremolo{i}]));
                        end
                    else
                        data.tremoloPara{i,3}=nan;
                    end
                end
                %Show the tremolo parameters in statistics tab.
                for i=1:length(data.treParaName)
                    data.textTremolo(i,1).String=num2str(data.tremoloPara{data.numTremoloSelected,i});
                end
                %tremolo_estimation(0);%compute onset_tremolo_env
            end
        else%import tremolo is similar to that in vibrato, for multitrack tab
            %defense code, the note must exist for corresponding track
            if isfield(data,'NoteTrack')
                currentname=data.subgroup.SelectedTab.Title;
            	p=str2num(currentname(isstrprop(currentname,'digit'))); 
                if isempty(data.NoteTrack{p})
                    msgbox('No note for corresponding track imported.');
                    return
                else
                    notes=data.NoteTrack{p};
                end 
            else
                msgbox('No notes for corresponding track imported.')
                return
            end
            candidateNote=candidateNote(candidateNote(:,5)~=1,1:5);%Remove the normal candidate note
            %Tremolo must be within a note.
            for i=1:size(candidateNote,1)
                if candidateNote(i,1)<notes(1,1)
                    msgbox('Bad tremolo imported');
                    return
                end
                if candidateNote(i,2)>round(sum(notes(end,1:2)),4)%end
                    msgbox('Bad tremolo imported');
                    return
                end
                if size(notes,1)>1%in middle
                    for j=1:size(notes,1)-1
                        if (candidateNote(i,1)<notes(j+1,1)&& candidateNote(i,1)>round(sum(notes(j,1:2)),4))||(candidateNote(i,2)<notes(j+1,1)&& candidateNote(i,2)>round(sum(notes(j,1:2)),4))
                            msgbox('Bad tremolo imported');
                            return
                        end
                    end
                end
            end
            data.TremoloTrack{p}=candidateNote;
        end
    end    
end

