%ISP_MIDIMODIFY  Modifies properties of a MIDI struct.
%
% SYNTAX
%   [midiout, optsout] = isp_midimodify(midiin, options ...)
%   
% DESCRIPTION
%   Normalize and/or transpose MIDI songs, remove percussion and/or change
%   the duration.
%
% INPUT
%   midiin:
%     Structure describing a midi song.
%   options, field/value pairs:
%     The following parameters can be set as field names in structs or be
%     specified as field/value pairs:
%     normalize:
%       Transpose tracks relative to each other such that the median note
%       is as close as possible to the one specified by 'normalize'. All
%       tracks are only transposed an integer number of octaves relative
%       to each other to avoid destroying harmonic relationships. A
%       boolean false or [] indicates no normalization. True or -1 is
%       converted to 60 (middle C on the piano). Default: [].
%     percussion:
%       Boolean specifying whether percussive instruments should be
%       included. Default: true.
%     transpose:
%       Integer. Default: 0.
%     duration:
%       Duration of the song relative to the input. For instance, specifying
%       1.5 will increase the duration of a song by 50%. Default: 1.0
%
% OUTPUT
%   midiout:
%     Structure describing a midi song.
%   optsout:
%     Structure specifying the actual modification parameters.
%
% SEE ALSO
%   isp_midiread, isp_midiwrite, isp_mididemo.
%   
% HISTORY
%   Created by Jesper H. Jensen

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


function [midi, options]=isp_midimodify(midi, varargin)
    options = struct('normalize', [], ...
                     'transpose', 0, ...
                     'duration', 1, ...
                     'percussion', true);
    options = isp_interpretarguments(options, varargin{:});
    
    if islogical(options.normalize)
        if options.normalize, options.normalize=-1;
        else, options.normalize=[];
        end
    end

    % Normalize
    if ~isempty(options.normalize)
        if options.normalize==-1, options.normalize=60; end
        midi.notes = normalizeMidi(midi.notes, options.normalize);
    end

    % Remove percussion
    if ~options.percussion
         midi.notes = midi.notes( midi.notes(:,3)~=10, :);
    end

    % Change duration
    if options.duration~=1
        midi.notes(:,[1 2 6 7]) = options.duration * midi.notes(:,[1 2 6 7]);
    end

    % Transpose
    if options.transpose~=0
        tonalNotes = midi.notes(:, 3) ~= 10;
        midi.notes(tonalNotes, 4) =  midi.notes(tonalNotes, 4) + options.transpose;
    end        

    midi.notes(:,4) = max(midi.notes(:,4), 0);
    midi.notes(:,4) = min(midi.notes(:,4), 127);

end




% NORMALIZEMIDI Transpose MIDI notes to reduce the dynamic range of the notes.
%
% NORMALIZEMIDI transpose the individual tracks relative to each other by
% an integer number of octaves such that the standard deviation of the notes
% is minimized. Then the entire song is transposed such that the average
% note comes as close as possible to 'meanNote'.
%
% Syntax: nmat = normalizeMidi(nmat, meanNote)
%
% Input:
%     nmat: MIDI note matrix as returned by readmidi2.
%     meanNote: The average note value (0-127) of the resulting MIDI
%         file.
%
% Output:
%     nmat: Normalized MIDI note matrix.
%

function nmat = normalizeMidi(nmat, meanNote)

    tonalNotes = nmat(:,3) ~= 10;
    channels = unique(nmat(:,3));

    if ~exist('meanNote')
        % Compute average note weighted by their duration
        meanNote = (nmat(tonalNotes,4)'*nmat(tonalNotes,7)) / ...
                         sum(allNotes(tonalNotes,7));
    end

    % Find the number of octaves to transpose on a trial-and-error basis (it's
    % an integer problem, so I'm not sure there is a closed form solution)
    for candidate=1:12
        tempnmat{candidate} = nmat;
        tempnmat{candidate}(tonalNotes,4) = ...
            tempnmat{candidate}(tonalNotes,4)+candidate;
        for ch=channels(:)'
            if ch == 10, continue, end
            thisCh = (tempnmat{candidate}(:,3) == ch);
            thisMeanNote = (tempnmat{candidate}(thisCh, 4)'*tempnmat{candidate}(thisCh,7)) / sum(tempnmat{candidate}(thisCh,7));
            adjustment = round((meanNote - thisMeanNote)/12)*12;
            tempnmat{candidate}(thisCh,4) = tempnmat{candidate}(thisCh,4) + adjustment;
        end
        variance(candidate) = (((tempnmat{candidate}(tonalNotes, 4)-meanNote).^2)'*tempnmat{candidate}(tonalNotes,7));
    end

    [minValue, minIdx] = min(variance);
    nmat = tempnmat{minIdx};

end
