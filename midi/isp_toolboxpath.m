%ISP_TOOLBOXPATH  Returns the path to the ISP Toolbox
%
% SYNTAX
%   isppath = isp_toolboxpath
%
% DESCRIPTION
%   Returns the path to the Intelligent Sound Processing Toolbox.
%
% OUTPUT
%   isppath:
%     Path to the ISP Toolbox

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


function isppath = isp_toolboxpath
  isppath = fileparts(which(mfilename));
end
