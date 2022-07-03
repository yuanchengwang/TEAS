function options = isp_interpretarguments(varargin)

%ISP_INTERPRETARGUMENTS  Interpret arguments and set default values for unspecified fields.
%
% SYNTAX
%   optionstruct = isp_interpretarguments(options ...)    
%   optionstruct = isp_interpretarguments(allowUnknown, options ...)    
%
% DESCRIPTION
%   This function is quite similar to the 'struct' function, except that it
%   besides 'field name'/'value' pairs also accept structs, whose fields
%   will be merged, as inputs. The function is intended to be called by
%   other functions for interpreting user arguments. Let a function accept
%   mandatory input arguments as usual, but replace all the optional
%   arguments with varargin. Now call isp_interpretarguments with a struct
%   specifying default values for the optional arguments as the first
%   argument, and with varargin{:} as the following argumnets. The returned
%   struct will contain default values for all parameters the user did not
%   specify.
%    
% INPUT
%   options ...
%     Either structs or field name/value pairs.
%   allowUnknown:
%     Optional parameter that specifies whether field/value pairs not
%     previously specified are allowed. Unknown fields in
%     structs are always allowed. Default: false.
%
% OUTPUT
%   optionstruct:
%     Struct where the value of each field is given by the first of the
%     following that apply:
%
% EXAMPLE
%   isp_interpretarguments is intended to be used at the beginning of
%   other functions. Assume we have a function 'spec' that starts with
%
%     function spec(wav, varargin)
%       defaults = struct('fs', 22050, 'fftsize', 512, 'hopsize', 256);
%       options = isp_interpretarguments(defaults, varargin{:});
%       options
%
%   The output when called with different inputs follows:
%     >> spec(wav)
%     options = 
%              fs: 22050
%         fftsize: 512
%         hopsize: 256
%
%     >> spec(wav, 'fs', 44100, 'fftsize', 1024)
%     options = 
%              fs: 44100
%         fftsize: 1024
%         hopsize: 256
%     >> opt=struct; opt.fs=16000; spec(wav, opt)
%     options = 
%              fs: 16000
%         fftsize: 512
%         hopsize: 256
%
% SEE ALSO
%   Pretty much every function in the ISP Toolbox call this function.
%
% HISTORY
%   Created by Jesper H. Jensen

% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License version 2 as published
% by the Free Software Foundation.


    if length(varargin) == 0
        error('Requires at least one input')
    end

    allowUnknown = false;
    iVararg = 1;
    if islogical(varargin{1})
        allowUnknown = varargin{iVararg};
        iVararg = iVararg + 1;
    end

    if isstruct(varargin{iVararg}) 
        options = varargin{iVararg};
        iVararg = iVararg + 1;
    else
        if ~allowUnknown
            error(['When not allowing unknown parameters/fields, the first ' ...
                   'argument must be a struct defining valid fields.']);
        end
        options = struct;
    end


    while iVararg <= length(varargin)
        switch(class(varargin{iVararg}))
          case 'struct'
            for f=fieldnames(varargin{iVararg})'
                options.(f{1}) = varargin{iVararg}.(f{1});
            end 
            iVararg = iVararg + 1;
          case 'char'
            if allowUnknown || isfield(options, varargin{iVararg})
                options.(varargin{iVararg}) = varargin{iVararg+1};
            else
                error(['Unknown parameter ' varargin{iVararg}])
            end
            iVararg = iVararg + 2;
          otherwise
            error(['Unknown class ' class(varargin{iVararg}) ' of input argument'])
        end

    end
end