function [onset,duration,avgPitch]=hmm_note(pitchRaw,time,h,varargin)%,onset,offset)
%pitch2note HMM version combines the MIDI spelling and onset/voice/unvoiced area
    global data;
    waitbar(0.1,h,sprintf('%d%% Pitch2Note converting...',10));
    tau=10;%the shortest note to keep(sec)
    %-------START pitch pre-processing------------
    offsetTime=[];
    if nargin>3 %&& data.CB.auto_NoteEdge.Value
        if data.double_peak%log-energy
            onsetTime=varargin{1}'*data.hop_length/data.fs;
            onsetTime2=onsetTime(2:2:end);
            onsetTime=onsetTime(1:2:end);%only the pluck get
        else     
            onsetTime=varargin{1}'*data.hop_length/data.fs;
        end
        
        if nargin==5
           offsetTime=varargin{2}*data.hop_length/data.fs;
        end
    else%Original version for onset detection
        widowLengthf0 = data.win_length/2;%1024
        pitchFs = 1/(time(2)-time(1));
        stepf0 = round(data.fs/pitchFs);
        onsetTime = onsetCorrectFlux(data.Cleaned_speech,widowLengthf0,stepf0,data.fs);%corrected specflux
    end
    
    %get pitch deviation
    if ~isempty(offsetTime)
        pitchRaw=offsetChangedpitch(pitchRaw,time,onsetTime,offsetTime);
    end
    pitchDeviation = GetPitchDeviation(pitchRaw);  
    midiPitchOriginal = freqToMidi(pitchRaw);
    zero_position=midiPitchOriginal>0;
    diff_zeros_position=diff(zero_position);
    down=find(diff_zeros_position==-1);
    up=find(diff_zeros_position==1)+1;
    if zero_position(1)==1
        segment(1,1)=1;
        segment(2:1+length(up),1)=up;
    else
        segment(:,1)=up;
    end
    if zero_position(end)==1
        segment(1:length(down),2)=down;
        segment(length(down)+1,2)=length(zero_position);
    else
        segment(:,2)=down;
    end
    %tau=ceil(threshold/(time(2)-time(1)));
    segment=segment(diff(segment,[],2)>=tau,:);%eliminate the note too short
    onset=[];
    duration=[];
    
    [midiPitchOriginal,segment]=pitch_correct(midiPitchOriginal,time,segment*(time(2)-time(1)),onsetTime,offsetTime');
    segment=round(segment/(time(2)-time(1)));
    for i=1:size(segment,1)
        waitbar(round(10+70/size(segment,1))/100,h,sprintf('%d%% Pitch2Note converting...',round(10+70/size(segment,1))));
        if data.double_peak
            [onset_temp,duration_temp]=hmm_note_core(midiPitchOriginal(segment(i,1):segment(i,2)),time(segment(i,1):segment(i,2)),pitchDeviation,onsetTime2);
        else
            [onset_temp,duration_temp]=hmm_note_core(midiPitchOriginal(segment(i,1):segment(i,2)),time(segment(i,1):segment(i,2)),pitchDeviation,onsetTime);   
        end
        onset=[onset;onset_temp];
        %last offset modification in a segment, unknow reason(maybe from hmm_note_core)
        [~,ind]=min(abs(onset_temp(end)+duration_temp(end)-offsetTime));
        duration_temp(end)=offsetTime(ind)-onset_temp(end);
        duration=[duration;duration_temp];
    end
    %-----------------------------------
    if ~isempty(onset)
        [onset,duration]=noteCorrection(onset,duration,onsetTime,offsetTime);
        avgPitch=zeros(length(onset),1);
        for i=1:length(onset)
            pitch_tmp=pitchRaw(logical((time>=onset(i)).*(time<=onset(i)+duration(i))));
            avgPitch(i)=median(pitch_tmp(pitch_tmp~=0));%median of the non-zero pitch within a note
        end%mean->median
        %Eliminate NAN and 0 notes
        nan_zero=(avgPitch==0)+(isnan(avgPitch));
        nan_zero=logical(nan_zero>0);
        onset(nan_zero)=[];
        duration(nan_zero)=[];
        avgPitch(nan_zero)=[];
        %if data.CB.auto_NoteEdge.Value
        
        %end
    else
        avgPitch=[];
    end
    waitbar(0.9,h,sprintf('%d%% Pitch2Note converting...',90));
end

