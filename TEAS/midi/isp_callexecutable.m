function [status, result] = isp_callexecutable(cmd, arg, directory, pre)
%ISP_CALLEXECUTABLE  Locate and execute external command (internal ISP toolbox command).
%
% SYNTAX
%     [status, result] = isp_callexecutable(cmd, arg, directory, pre)
%
% DESCRIPTION
%   Locates the ISP toolbox directory and executes a file in there.
%
% INPUT
%   cmd:
%     The command to execute
%   arg:
%     Arguments for the command. The string '{}' will be replaced by the
%     directory where the executable is found.
%   directory:
%     The directory in which the command shall be executed. If it is
%     empty, the current directory is used. Default: ''
%   pre:
%     Stuff to be put before the command, such as environment variables
%     in Unix.  The string '{}' will be replaced by the directory where
%     the executable is found. Default: ''
%
% OUTPUT
%   status, result:
%     Outputs from the 'system' command
%
% SEE ALSO
%   system
%
% HISTORY
%   Created by Jesper Højvang Jensen (jhj@es.aau.dk)

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


    if ~exist('pre', 'var')
        pre='';
    end


    % The following is a hack to make this function works in octave too.
    computertype=computer;
    if ~isempty(regexp(computertype, 'i.*86-pc-linux-gnu'))
        computertype = 'GLNX86';
    end

    if strcmp('PCWIN', computertype)
        computertype = 'PCWIN.exe';
    end

    ispdir=isp_toolboxpath;%'C:\Users\wyc\Desktop\enhanced_AVA_matlab\midi\';
    
    pathcmd = fullfile(ispdir, [cmd '.' computertype]);

    if ~exist(pathcmd, 'file')
        % Maybe we're lucky the file is somewhere else on the path
        pathcmd = which([cmd '.' computertype]);
        ispdir=fileparts(pathcmd);
    end

    if ~exist(pathcmd, 'file')
        % We're still not lucky - just try and hope for the best
        warning(['Cannot find ' cmd '. Maybe a binary does not exist for ' ...
                 'your platform? Anyways, we just assume it is in ' ...
                 'your path and hope for the best.'])
        ispdir='.';
        pathcmd = cmd;
    end

    if exist('directory', 'var') && ~isempty(directory)
        olddir=cd;
        cd(directory);
    end

    fullcmd = [strrep(pre, '{}', ispdir) pathcmd ' ' strrep(arg, '{}', ispdir)];

    fprintf('Executing %s\n', fullcmd);
    [status, result] = system(fullcmd);

    if 0 ~= status
        warning(['Error executing ' fullcmd arg '.'])
    end

    if exist('olddir', 'var')
        cd(olddir);
    end
end


