function selectPitchPoints(hObject,eventData)
%SELECTPITCHPOINTS Select the pitch point within a rectangle to
%modify

    global data;
    data.Bn.selectPitches.set('Enable','inactive');
    axe=data.axePitchTabAudio;
    rect = getrect(axe);%[xmin ymin max(x)-xmin max(y)-ymin]
    
    %----START of pitch point---------------
    if rect(3)==0 || rect(4)==0
        msgbox('Bad area selected');
    else
        if ((axe.XLim(1)<=rect(1)&& rect(1)<=axe.XLim(2)) || (axe.XLim(1)<=rect(1)+rect(3) && rect(1)+rect(3)<=axe.XLim(2))) && ...
            ((axe.YLim(1)<= rect(2) && rect(2)<=axe.YLim(2))|| (axe.YLim(1)<= rect(2)+rect(4)&& rect(2)+rect(4)<=axe.YLim(2)))
            %delete the result
            if isfield(data,'pitchPointArea')
                delete(data.pitchPointArea);
                data=rmfield(data,'pitchPointArea');
                data=rmfield(data,'pitchPoint');
                data=rmfield(data,'pitchPointTime');
                data.PitchXEdit.set('string',[]);
                data.PitchXMIDI.set('string',[]);
            end
            [~,PitchStart]=min(abs(rect(1)-data.pitchTime));
            [~,PitchEnd]=min(abs(rect(1) + rect(3)-data.pitchTime));
            if ~isscalar(PitchStart)
                PitchStart=max(PitchStart);
            end
            if ~isscalar(PitchEnd)
                PitchEnd=max(PitchEnd);
            end
            pitchseg=freqToMidi(data.pitch(PitchStart:PitchEnd));
            pitchIndex=[];
            %check if there exists a pitch points in the rect
            for i=1:(PitchEnd-PitchStart+1)
                if pitchseg(i)>=rect(2) && pitchseg(i)<=rect(2)+rect(4)
                    pitchIndex=[pitchIndex,i];
                end
            end

            if isempty(pitchIndex)
                msgbox('No pitch point selected');
            else
                data.pitchIndex=pitchIndex+PitchStart-1;
                data.pitchPoint=freqToMidi(data.pitch(data.pitchIndex));
                data.pitchPointTime=data.pitchTime(data.pitchIndex);
                data.pitchPointArea=plotPitchPoints(data.pitchPoint,data.pitchPointTime,data.axePitchTabAudio);
            end
        else
            msgbox('Bad area selected')
        end
    end
    data.Bn.selectPitches.set('Enable','on');
    %----END of Pitch Area setting------------ 
end

