%ISP_MIDISYNTH  Synthesize a MIDI song to wave data.
%
% SYNTAX
%  [wav,fs,nbits]=isp_midisynth(midisong, soundfont, options, 'field', 'value', ...)
%  [wav,fs,nbits]=isp_midisynth(midisong, options, 'field', 'value', ...)
%
% INPUT
%   midisong:
%     Either a Filename of a MIDI file or a struct (as returned by
%     isp_midiread) that defines a MIDI song.
%   soundfont:
%     Timidity configuration file or sf2 soundfont. In the latter case,
%     the extension must be sf2 or SF2.
%   options, field/value pairs:
%     The following options can be specified as fields of the options
%     struct (which is optional), or as field/value pairs.
%     soundfont:
%       Equivalent way of specifying the sound font.
%     mono:
%       boolean specifying if output shall be mono or
%       stereo. Default: true.
%     nChannels:
%       Number of output channels. Use only one of 'mono' and
%       'nChannels'. Default: []
%     samplerate:
%       Sampling frequency. Default: 44100.
%
% OUTPUT
%   wav:
%     Wave data as returned by wavread.
%   fs:
%     Sampling frequency as returned by wavread.
%   nbits:
%     Number of bits per sample as returned by wavread.
%
% SEE ALSO
%   isp_midiread, isp_midiwrite.
%
% HISTORY
%   First public release in Oct 2006 by Jesper Højvang Jensen. Merged
%   with the ISP Toolbox in Nov. 2007.
%         

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


function [y,fs]=isp_midisynth(midi, varargin)

    % In windows, this function uses Timidity from
    % http://timidity.s11.xrea.com/files/TiMidity++-2.13.0-w32.zip. In Linux,
    % it uses Timidity 2.13.2 from the Debian repository.

    if ~exist('midi', 'var')
        error('A midi song must be specified.')
    end
    
    % If the input is a midi struct, write it to a file
    inputIsStruct = isstruct(midi);
    if inputIsStruct
        % Generate temporary file name
        filename = isp_tempfile('.mid');
        isp_midiwrite(midi, filename);
    else
        filename = midi;
    end
    
    % Interpret input arguments
    options.nChannels = [];
    options.samplerate = 44100;
    options.mono = true;
    options.soundfont = '';
    if length(varargin) == 1 || (~isempty(varargin) && ischar(varargin{1}) ...
                                 && ~isfield(options, varargin{1}))
        options.soundfont = varargin{1};
        options = isp_interpretarguments(options, varargin{2:end});
    else
        options = isp_interpretarguments(options, varargin{:});
    end

    if ~isempty(options.nChannels)
        % We can only distinguish between mono and stereo
        options.mono = options.nChannels==1;
    end

    if ~exist(filename, 'file')
        error(['File ' filename ' does not exist.'])
    end

    if isempty(options.soundfont)
        options.soundfont = fullfile(isp_toolboxpath, 'FluidR3 GM.SF2');
    end

    if ~exist(options.soundfont, 'file')
        error('Invalid sound font specified.')
    end

    [dummy, dummy, ext] = fileparts(options.soundfont);
    sf2 = strcmp(lower(ext), '.sf2');
    if sf2
        soundfont=isp_tempfile('.cfg');
        fid=fopen(soundfont, 'w');
        fprintf(fid, 'soundfont "%s"', options.soundfont);
        fclose(fid);
    else
        soundfont=options.soundfont;
    end

    if options.mono
        flags = '--output-mono';
    else
        flags = '--output-stereo';
    end
    tempfile = isp_tempfile('.wav');
    cmd = sprintf('-idq -s %d -Ow %s -o "%s" -c "%s" "%s"', ...
                  options.samplerate, flags, tempfile, soundfont, ...
                  filename );
    status = 1;
    computertype=computer;
    if regexp('i.86-pc-linux-gnu', computertype)
        computertype = 'GLNX86';
    end

    if strcmp('PCWIN64', computertype)
        computertype = 'PCWIN.exe';
    end
    while status ~= 0
        [status, output] = isp_callexecutable(['.\midi\isp_timidity.',computertype], cmd);
        fprintf(1, '%s', output);
        if ~isempty(strfind(output, 'No instrument mapped to'))
            status = 1;
        end
        if ~isempty(strfind(output, 'No space left on device'))
            error('No space left on device')
        end
        if status ~= 0
            fprintf('Error converting MIDI file. Trying again.\n')
            pause(1)
        end
    end

    [y,fs]=audioread(tempfile);
    delete(tempfile);

    if sf2
        delete(soundfont);
    end

    if inputIsStruct
        delete(filename);
    end    
end
