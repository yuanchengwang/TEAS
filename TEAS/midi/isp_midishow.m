%ISP_MIDISHOW  Visualize a midi song
%
% SYNTAX
%    isp_midishow(midi, options)
%
% DESCRIPTION
%   Shows a graphical visualization of a MIDI song.
%
% INPUT
%   midi:
%     Structure describing a MIDI song as returned by isp_midiread
%   options, field/value pairs:
%     yaxis:
%       What to display on the y axis. Possible values: 'channels',
%       'pitch'. Default: 'pitch'
%     singleoctave:
%       Boolean specifying whether to wrap all notes into a single
%       octave. Possible values: true, false. Default: false.
%
% EXAMPLE
%   m=isp_midiread('midifile.mid');
%   isp_midishow(m)
%
% HISTORY
%   Created by Jesper H. Jensen 2007.

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


% Note: this function is not optimized at all.
function isp_midishow(midi, varargin)
    
    options=isp_interpretarguments(struct('yaxis', 'pitch', ...
                                          'singleoctave', false), ...
                                   varargin{:});
    
    notes=midi.notes;
    chColor=linspace(0,1,16);

    channels=unique(notes(:,3));
    hold off
    [ch, t0, t1, v, note]=deal(notes(:,3), notes(:,6), ...
                               notes(:,6)+notes(:,7), notes(:, 4), ...
                               notes(:, 5));

    hold off
    for iCh=1:length(channels)
        surf([nan nan], [nan nan], repmat(chColor(channels(iCh)), 2, 2));
        hold all
    end

    if options.singleoctave
        note = mod(note-1, 12) + 1;
    end

    for iCh=1:length(channels)
        thisCh = ch==channels(iCh);
        switch options.yaxis
          case 'channels'
            x = [t0(thisCh) t1(thisCh) repmat(nan, sum(thisCh), 1)]';
            surf(x(:), channels(iCh)+[-.4 .4], repmat(chColor(channels(iCh)), 2, numel(x)), ...
                 'EdgeColor', 'none')
          case 'pitch'
            uniqNotes=unique(note(thisCh));
            for iNote=1:length(uniqNotes)
                relevant=thisCh & note==uniqNotes(iNote);
                x = [t0(relevant) t1(relevant) repmat(nan, sum(relevant), 1)]';
                surf(x(:), uniqNotes(iNote)+[-.4 .4], ...
                     repmat(chColor(channels(iCh)), 2, numel(x)), ...
                     'EdgeColor', 'none')
            end
          otherwise
            error('Invalid ')
        end
        leg{iCh} = sprintf('Channel %d', channels(iCh));
    end

    view(0,90)
    axis xy

    xlabel('Time')
    switch options.yaxis
      case 'channels'
        ylabel('Channel')
      case 'pitch'
        ylabel('Pitch')
        if options.singleoctave        
            ylim([0 13])
        end
        legend(leg{:}, 'Location', 'EastOutside')
    end

end

