function tempfile = isp_tempfile(suffix)
%ISP_TEMPFILE  Generate temporary file name
%
% SYNTAX
%     tempfile = isp_tempfile(extension)
%
% DESCRIPTION
%   If possible, the unix tempfile command is used to generate a truly
%   unique temporary filename. Otherwise the Matlab TEMPNAME function is
%   used, but to avoid clashes if more than one instance of Matlab is
%   running, the temporary file is created to mark to other instances that
%   it already is in use.
%
% INPUT
%   extension:
%     Filename extension. Default: ''
%
% OUTPUT
%   tempfile:
%     Filename of unique temporary file.
%
% EXAMPLE
%   Get the filename of a temporary wav file:
%     >> f=isp_tempfile('.wav')
%     f =
%     /tmp/fileDys3sr.wav
%
% SEE ALSO
%   tempname.
%
% HISTORY
%   Created by Jesper Højvang Jensen (jhj@es.aau.dk)

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


    if ~exist('suffix', 'var')
        suffix = '';
    end

    [status, tempfile] = unix(['tempfile --suffix ' suffix]);
    if status == 0
        tempfile = [sscanf(tempfile, '%s')];
    else
        fileexists=true;
        while fileexists
            tempfile = [tempname suffix];
            fileexists = exist(tempfile, 'file');
        end
        % Mark file name as used. Paranoia to avoid clash on multiprocessor machines
        fclose(fopen(tempfile, 'wb'));
    end
end