function midisong = isp_midiread(fn)
%ISP_MIDIREAD  Read MIDI file
% Modified by Yuancheng Wang
% SYNTAX
%     midisong = isp_readmidi(filename)
%
% DESCRIPTION
%   Reads a MIDI file into a struct.
%
% INPUT
%   filename:
%     name of the MIDI file
%
% OUTPUT
%   midisong:
%     Struct with the following fields:
%     notes:
%       Notes of the song. Columns: onset (beats), duration (beats), channel,
%       pitch, velocity, onset (sec), duration (sec)
%     instruments:
%       Instrument matrix. Columns: onset (beats), channel, instrument,
%       onset (sec)
%     controller:
%       Controller commands. Columns: onset (beates), channel, command,
%       value, onset(sec)
%     Pitch Bend:
%       Pitch bend matrix: Columns: onset (beates), channel, value(pitch
%       fraction in hz), onset(sec).
% SEE ALSO
%   isp_midiwrite, isp_mididemo.
%
% HISTORY
%   Originally part of the MIDI Toolbox, Copyright ï¿? 2004, University of
%   Jyvaskyla, Finland.
%   Speeded up and extended by Jesper H. Jensen to also read instrument and
%   controller information.

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


    nmat=[];
    %disp(fn);

    % The following is a hack to make this function work in octave too.
    computertype=computer;
    if regexp('i.86-pc-linux-gnu', computertype)
        computertype = 'GLNX86';
    end

    if strcmp('PCWIN64', computertype)
        computertype = 'PCWIN.exe';
    end

    % Use actual shell command  2004-08-13 dpwe@ee.columbia.edu
    of = isp_tempfile('.txt');
    isp_callexecutable(['.\midi\isp_mf2t.',computertype], ['"',fn,'" "',of,'"']);
    [nmat, instruments, controller,bend] = mftxt2nmat2(of);
    delete(of)

    midisong.notes = nmat;
    midisong.instruments = instruments;
    midisong.controller = controller;
    midisong.bend = bend;
end


function [data, instrData, ctrlData, pbData] = mftxt2nmat2(fn)
% Conversion of MIDI text file to notematrix
% [data, instruments] = mftxt2nmat(fn);
% converts a MIDI text file to a notematrix data=[];
%
% Input arguments:
%	FN = Input filename
%
% Output:
%	DATA = Notematrix. Columns: onset (beats), duration (beats), channel,
%		pitch, velocity, onset (sec), duration (sec)
%	INSTRUMENTS = Instrument matrix. Columns: onset (beats), channel, instrument,
%		onset (sec)
%	CTRLDATA = controller commands. Columns: onset (beates), channel, command,
%		value, onset(sec)
%
% Remarks:
%
% Change History :
% Date		Time	Prog	Note
% 11.8.2002	18:36	PT	Created under MATLAB 5.3 (Macintosh)
% 28.11.2002	21:32	TE	Revised
% 1.5.2003	12:00	PT	Revised
% 24.3.2006	22:30	JHJ	Added support for reading instrument number and did
% 						some minor optimizations
% Part of the MIDI Toolbox Software Package, Copyright 2004, University of Jyvaskyla, Finland
% See License.txt

    tmpdata=zeros(0,4);
    tempo = 0.5; % default value: duration of one beat in seconds
    fid=fopen(fn,'rt');
    if fid==-1
        disp(strcat('Could not open file:',fn));
        return;
    end

    % read header
    [a,count] = fscanf(fid,'MFile %d %d %d');
    if count == 0 % empty file
        disp('Could not read file!!!');
        return;
    end
    counter=0;
    instrCounter=0;
    instrData=[];
    ctrlCounter=0;
    ctrlData=[];
    pbCounter=0;%new for pitch bend
    pbData=[];%new for pitch bend
    %mftype=a(1); 
    nTracks=a(2); nTicks=a(3);
    %read tracks
    for tr=1:nTracks
        holdnote=cell(16,1); holdpedal=zeros(16,1);
        trkHeader = fgets(fid);
        a=[];

        while true
            C=textscan(fid, '%f %s ch=%f n=%f v=%f');
            time=C{1};
            cmd=C{2};
            ch=C{3};
            n=C{4};
            v=C{5};

            if isempty(time)
                % No time signature found
                a = fscanf(fid, '%s', 1);
                if strcmp(a, 'TrkEnd')
                    fgets(fid); % read the end-of-line character (PT 220502)
                    break; % Exit while-loop
                else
                    fgets(fid);
                    continue;
                end
            else

              timeend = time(end);
              cmdend = cmd{end};
              if ~isempty(ch), chend = ch(end); end

              % For octave compatibility
              if length(time) > length(v)
                time(end)=[];
                cmd(end)=[];
                if length(ch) > length(v)
                    chend=ch(end);
                    ch(end)=[];
                end
              end

              if length(v) ~=0
                  onEvents = strcmp(cmd, 'On');
                  offEvents = strcmp(cmd, 'Off');
                  pedaldown = holdpedal(ch) ~= 0;

                  % (Note on) or (note released and no pedal down)
                  noPedal = ((onEvents | offEvents) & ~pedaldown) | (onEvents & v>0);
                  nTmp = sum(noPedal);
                  v(offEvents)=0;
                  if nTmp > 0
                      tmpdata(counter+1:counter+nTmp,:) = [time(noPedal) ch(noPedal) n(noPedal) v(noPedal)];
                      counter = counter+nTmp;
                  end
                  
                  % Pedal down and note released
                  pedal = pedaldown & (offEvents | (onEvents & v==0));
                  for iCh=1:16
                      if ~holdpedal(iCh), continue, end
                      holdnote{iCh}=[holdnote{iCh} n(ch(1:length(v))==iCh & pedal)'];
                  end
              end
              
              switch cmdend
               case 'PrCh'
                [p,count] = fscanf(fid,' p=%d',1);
                instrCounter = instrCounter + 1;
                instrData(instrCounter, :) = [timeend/nTicks chend p+1 timeend*tempo/nTicks];         
               case 'Tempo'
                [tempo,count] = fscanf(fid,' %d',1);
                tempo = tempo/1000000; % duration of one beat in seconds
               case 'Par'% CC
                [c,count] = fscanf(fid,' c=%d',1);
                [v,count] = fscanf(fid,' v=%d',1);
                if c==64%pedal
                    if v>63
                        holdpedal(chend)=1;
                    else
                        holdpedal(chend)=0;
                        if ~isempty(holdnote{chend})
                            for k=1:length(holdnote{chend})
                                % event = [time ch holdnote{ch}(k) 0];
                                counter=counter+1;
                                % tmpdata(counter,:) = event;
                                tmpdata(counter,:) = [timeend chend holdnote{chend}(k) 0];
                            end
                            holdnote{chend}=[];
                        end
                    end
                else
                    ctrlCounter = ctrlCounter + 1;
                    ctrlData(ctrlCounter, :) = [timeend/nTicks chend c v timeend*tempo/nTicks];
                end
                  case 'Pb'%newly added by yuanchengwang, pitch bend
                    [v,count] = fscanf(fid,' v=%d',1);%there is only velocity
                    v_new=2^((v-8192)/8192);%the equation, convert the 14bit->hz fraction 
                    pbCounter = pbCounter + 1;
                    pbData(pbCounter,:)= [timeend/nTicks chend v_new timeend*tempo/nTicks];
               otherwise
                li = fgets(fid); % read the rest of the line and ignore it
              end
            end
        end
    end

    for ch=1:16
        if ~isempty(holdnote{ch})
            for k=1:length(holdnote{ch})
                event = [time ch holdnote{ch}(k) 0];
                counter=counter+1;
                tmpdata(counter,:) = event;
            end
            holdnote{ch}=[];
        end
    end

    % Sort to speed up search later on
    [tmp,ind]=sort(tmpdata(:,3));
    tmpdata=tmpdata(ind,:);

    tmpdata2=zeros(floor(size(tmpdata,1)/2), 7);

    % create notematrix
    counter2=0;
    for k=1:size(tmpdata,1)
        if tmpdata(k,4)>0
            for m=k+1:size(tmpdata,1)
                if tmpdata(k,2:3) == tmpdata(m,2:3)
                    ch = tmpdata(k,2); n = tmpdata(k,3); v = tmpdata(k,4);
                    timeBeats = tmpdata(k,1)/nTicks;
                    timeSecs = timeBeats*tempo;
                    dur = tmpdata(m,1)-tmpdata(k,1);
                    durBeats = dur/nTicks;
                    durSecs = durBeats*tempo;
                    counter2=counter2+1;
                    
                    % Apparently, it is faster to split up the assignment
                    % (guess it space is otherwise allocated for the rhs)
                    % tmpdata2(counter2,:) = [timeBeats durBeats ch n v timeSecs durSecs];
                    tmpdata2(counter2,1) = timeBeats;
                    tmpdata2(counter2,2) = durBeats;
                    tmpdata2(counter2,3) = ch;
                    tmpdata2(counter2,4) = n;
                    tmpdata2(counter2,5) = v;
                    tmpdata2(counter2,6) = timeSecs;
                    tmpdata2(counter2,7) = durSecs;
                    break;
                end
            end
        end
    end

    [tmp,ind] = sort(tmpdata2(1:counter2,1));
    data = tmpdata2(ind,:);

    % sort instrument matrix
    if ~isempty(instrData)
        [tmp, ind] = sort(instrData(:,1));
        instrData = instrData(ind, :);
    end

    % sort ctrl matrix
    if ~isempty(ctrlData)
        [tmp, ind] = sort(ctrlData(:,1));
        ctrlData = ctrlData(ind, :);
    end
    % sort pb matrix
    if ~isempty(pbData)
        [tmp, ind] = sort(pbData(:,1));
        pbData = pbData(ind, :);
    end

    fclose(fid);
end