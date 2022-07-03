function delPluckFn(hObject,eventData)
%DELPLUCKFN Delete all the onset points within a candidate note and refresh the plot
    global data;
    if isfield(data,'onset_tremolo')
        if isempty(data.onset_tremolo{data.numTremoloSelected})
            msgbox('Normal pluck for this note, no pluck to delete.');
            return
        else
            if ~isfield(data,'selected_pluck')
                msgbox('No pluck selected.');
                return
            end
            if isempty(data.onset_tremolo{data.numTremoloSelected})
                disp('No pluck to delete.');
                return
            end
            data.onset_tremolo{data.numTremoloSelected}(data.numPluckSelected)=[];
            %Update and display the parameter
            if data.double_peak
                onset_tmp=data.onset_tremolo{data.numTremoloSelected};
                data.tremoloPara{data.numTremoloSelected,2}=(length(data.onset_tremolo{data.numTremoloSelected})+1)/2;
                if isempty(onset_tmp)
                    data.tremoloPara{data.numTremoloSelected,1}=[];
                else
                    data.tremoloPara{data.numTremoloSelected,1}=tremolo_velocity(onset_tmp(1));   
                end
            else
                data.tremoloPara{data.numTremoloSelected,2}=length(data.onset_tremolo{data.numTremoloSelected});
            end
            if data.tremoloPara{data.numTremoloSelected,2}>=2
                if data.double_peak
                    data.tremoloPara{data.numTremoloSelected,3}=1/mean(diff([data.candidateNote(data.numTremoloSelected,1),data.onset_tremolo{data.numTremoloSelected}(2:2:end)]));
                else
                    data.tremoloPara{data.numTremoloSelected,3}=1/mean(diff([data.candidateNote(data.numTremoloSelected,1),data.onset_tremolo{data.numTremoloSelected}]));
                end
            else
                data.tremoloPara{data.numTremoloSelected,3}=nan;
            end
            if data.tremoloPara{data.numTremoloSelected,2}==2
                msgbox('Two plucks detected within a note, modify the pluck points or note segment in note tab.');
            end
            %Show the tremolo parameters in statistics tab.
            for i=1:length(data.treParaName)
                data.textTremolo(i,1).String=num2str(data.tremoloPara{data.numTremoloSelected,i});
            end

            %Show the types of tremolo
            if data.tremoloPara{data.numTremoloSelected,2}==1
                data.candidateNote(data.numTremoloSelected,5)=1;
            end
            data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5); 
            
            %visualization
            axes(data.axeWaveTabTremoloIndi);
            y=data.axeWaveTabTremoloIndi.YLim;
            if isfield(data,'patchTremoloOnset')
                delete(data.patchTremoloOnset);
                data=rmfield(data,'patchTremoloOnset');
            end
            %if ~isempty(data.onset_tremolo{data.numTremoloSelected})
                onset=data.onset_tremolo{data.numTremoloSelected};
                if data.tremoloXaxisPara.Value==2
                    onset=onset-data.candidateNote(data.numTremoloSelected,1);
                end
                for j=1:length(onset)
                    data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
                end
                time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
                hold on;
                if data.changeTremoloMethod.Value~=1
                    [~,a]=min(abs(data.EdgeTime-time(1)));
                    [~,b]=min(abs(data.EdgeTime-time(2)));
                    data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                else
                    [~,a]=min(abs(data.log_energy_time-time(1)));
                    [~,b]=min(abs(data.log_energy_time-time(2)));     
                    data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
                end
                hold off;
            %end
            data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5); 
            %Show the tremolo parameters in statistics tab.
            for i=1:length(data.treParaName)
                data.textTremolo(i,1).String=num2str(data.tremoloPara{data.numTremoloSelected,i});
            end
        end
    end
end