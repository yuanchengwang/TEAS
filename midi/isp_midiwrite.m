function isp_midiwrite(midistruct, filename)
%ISP_MIDIWRITE  Write MIDI file. 
% Modified by yuanchengwang
%
% SYNTAX
%   isp_midiwrite(midistruct, filename)
%
% DESCRIPTION
%   Creates a MIDI file from a struct containing note information and
%   optionally instrument and controller information.
%
% INPUT
%   midistruct:
%     Struct with the following fields:
%     notes:
%       Notes of the song. Columns: onset (beats), duration (beats), channel,
%       pitch, velocity, onset (sec), duration (sec).
%     instruments:
%       Instrument matrix. Columns: onset (beats), channel, instrument,
%       onset (sec) (default: empty).
%     controller:
%       Controller commands. Columns: onset (beates), channel, command,
%       value, onset(sec) (default: empty).
%     pitch Bend:
%       Pitch bend matrix: Columns: onset (beates), channel, value(pitch
%       fraction in hz), onset(sec).
%     tpq:
%       Ticks per quarter note (default 120).
%     tempo: 
%       Beats per minute (default 100).
%     tsig1, tsig2:
%       Time-signature, e.g. 6/8 -> TSIG1 = 6, TSIG2 = 8 (default 4/4).
%   filename:
%     Output filename
%   
% SEE ALSO
%   isp_readmidi, isp_mididemo.
%
% HISTORY
%   Created by T. Eerola as part of the MIDI Toolbox (Copyright 2004,
%   University of Jyvaskyla, Finland).
%   Modified by Jesper H. Jensen to support instruments and controller events.
%

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


    if nargin < 2
        error('Not enough input arguments')
    end

    nmat = midistruct.notes;
    [dummy, n]=max(nmat(:,end));
    deftempo=60/(nmat(n, end)/nmat(n, 2));

    defmidistruct=struct('instruments', zeros(0,4), ...
                         'controller', zeros(0,5), ...
                         'bend',zeros(0,4),...%new for pitch bend
                         'tpq', 120, ...
                         'tempo', deftempo, ...
                         'tsig1', 4, 'tsig2', 4);

    midistruct = isp_interpretarguments(defmidistruct, midistruct);
    

    % Create a temporary text filename
    %ofname0 = regexprep(ofname, '\.mid$', '.txt');
    ofname0 = isp_tempfile('.txt');

    % Convert to text file
    nmat2mft2(midistruct.notes, ofname0, midistruct.instruments, ...
              midistruct.controller, midistruct.bend, midistruct.tpq, midistruct.tempo, ...
              midistruct.tsig1, midistruct.tsig2);%midistruct.bend added.

    % Convert to MIDI file
    computertype=computer;
    if regexp('i.86-pc-linux-gnu', computertype)
        computertype = 'GLNX86';
    end

    if strcmp('PCWIN64', computertype)
        computertype = 'PCWIN.exe';
    end
    isp_callexecutable(['.\midi\isp_t2mf.',computertype], [' "',ofname0,'" "',filename,'"']);

    % Delete text file
    delete(ofname0)
end

function nmat2mft2(nmat,ofname,instrmat, ctrlmat, bendmat, tpq, tempo, tsig1, tsig2)
% Conversion of notematrix to MIDI text file
% nmat2mft(nmat, ofname, tpq, tempo, tsig1, tsig2)
%
% Input arguments: 
%	NMAT = notematrix
%	OFNAME = Output filename
%	INSTRMAT = Instrument matrix
%	CTRLMAT = Controller event matrix
%	BENDMAT = Pitch bend event matrix
%	TPQ = Ticks per quarter note
%	TEMPO = bpm, beats per minute
%	TSIG1&2 = Time-signature, e.g. 6/8 -> TSIG1 = 6, TSIG2 = 8
%
% Remarks: TEXT2MIDI converter needs to be handled differently in PC and Mac.
%
% Example: nmat2mft(nmat,'demo.txt', 120, 80, 4, 4);
%
%  Author		Date
% 30.2.2003	11:40	TE	Created under MATLAB 5.3 (PC)
% 24.3.2006 23.20	JHJ	Added a horrible hack to support specifying
%						instruments, controller events and a more sensible
%						default for the tempo
% 
%ï¿? Part of the MIDI Toolbox Software Package, Copyright ï¿? 2002, University of Jyvï¿½skylï¿?, Finland
% See License.txt

    if isempty(nmat), return; end

    if nargin <2, ofname = 'temp.txt'; disp('Output filename missing, wrote results to "temp.txt" file'); end
    if nargin <3, instrmat = zeros(0,4); end
    if nargin <4, ctrlmat = zeros(0,5); end
    if nargin <5, bendmat = zeros(0,4); end
    if nargin <6, tpq=120;end
    if nargin <7 %tempo=100; end
        [dummy, n]=max(nmat(:,end));
        tempo=60/(nmat(n, end)/nmat(n, 2));
    end
    if nargin <8, tsig1=4; end
    if nargin <9, tsig2=4; end % disp('Default parameters used'); end

    fid = fopen(ofname,'w');
    ch = unique(nmat(:,3));
    NCH = length(ch)+1;

    % write header
    fprintf(fid,'MFile 1 %d %d\r\n', NCH, tpq);

    % write conductor track
    fprintf(fid,'MTrk\r\n');
    fprintf(fid,'0 TimeSig %d/%d 24 8\r\n', tsig1, tsig2);
    fprintf(fid,'0 Tempo %d\r\n', floor(1000000*60/tempo));
    fprintf(fid,'0 Meta TrkEnd\r\n');
    fprintf(fid,'TrkEnd\r\n');

    for k=1:length(ch)
	tmp = [];
	nm = nmat( nmat(:,3)==ch(k), :);
	ontime=floor(nm(:,1)*tpq);
	offtime = floor((nm(:,1)+nm(:,2))*tpq);
	p = nm(:,4);
	v = nm(:,5);
        
        % Controller events
        for m=find(ctrlmat(:,2)==ch(k))'
            tmp = [tmp; round(ctrlmat(m, 1)*tpq) ch(k)-100 ctrlmat(m, 3) ctrlmat(m, 4)];
        end

        % Instruments
        if ~isempty(instrmat)
        for m=find(instrmat(:,2)==ch(k))'
            tmp = [tmp; round(instrmat(m, 1)*tpq) ch(k) instrmat(m, 3) nan];
        end
        end
        % Pitch bend
        if ~isempty(bendmat)
        for m=find(bendmat(:,2)==ch(k))'
            tmp = [tmp; round(bendmat(m, 1)*tpq) ch(k) round(log2(bendmat(m, 3))*8192+8192) inf];%differ from nan
        end
        end
        % Notes
        nNotes = size(nm,1);
        notetmp = zeros(2*nNotes, 4);
        notetmp(1:2:2*nNotes, :) = [ontime ch(k*ones(nNotes,1)) p v];
        notetmp(2:2:2*nNotes, :) = [offtime ch(k*ones(nNotes,1)) p zeros(nNotes,1)];
        tmp = [tmp; notetmp];
        
	[Y,I] = sort(tmp(:,1));
	tmp2 = tmp(I,:);
	
	fprintf(fid,'MTrk\r\n');
        
        isnotes = isfinite(tmp2(:,4)) & (tmp2(:,2) >=0 );
        sectionLengths = diff(find(diff([~isnotes(1); isnotes; ~isnotes(end)])));
        if ~isnotes(1)
            sectionLengths = [0; sectionLengths];
        end
        if isnotes(end)
            sectionLengths(end+1) = 0;
        end
        
        tmpIdx = 1;

	for n=1:2:length(sectionLengths)
            if sectionLengths(n)>0
                fprintf(fid,'%d On ch=%d n=%d v=%d\r\n', tmp2(tmpIdx:tmpIdx+sectionLengths(n)-1,:)');
            end
            tmpIdx = tmpIdx + sectionLengths(n);
            for m=tmpIdx:tmpIdx+sectionLengths(n+1)-1
                if isnan(tmp2(m, 4))% instrument
                    fprintf(fid,'%d PrCh ch=%d p=%d\r\n', tmp2(m,1), tmp2(m,2), tmp2(m,3)-1);
                elseif tmp2(m,2)<0 % CC
                    fprintf(fid,'%d Par ch=%d c=%d v=%d\r\n', tmp2(m,1), tmp2(m,2)+100, tmp2(m,3), tmp2(m,4));
                elseif isinf(tmp2(m, 4))% pitch bend
                    fprintf(fid,'%d Pb ch=%d v=%d\r\n', tmp2(m,1), tmp2(m,2), tmp2(m,3));
                else
                    error('Something is wrong!')
                end
            end
            tmpIdx = tmpIdx + sectionLengths(n+1);
 end
 fprintf(fid,'%d Meta TrkEnd\r\n', tmp2(end,1));
 fprintf(fid,'TrkEnd\r\n');
    end
    status = fclose(fid);
end
