function fret=fret_estimation(varargin)
% FRET_ESTIMATION Fret estimation with known track number and open string
global data;
if nargin==1%for modification
    str=data.str{data.track_index};
    notes=varargin{1};
    fret_tmp=notes-str;%define it on the onset of a not!
    if prod(fret_tmp>=0)~=1
        msgbox('Bad definition for track index or open string.')
        return
    else
        fret=fret_tmp;
    end  
else %global 
    if nargin~=3
        pitch=data.avgPitch;
    else%3
        pitch=varargin{3};
    end
    str=data.str{data.track_index};
    fret=round(freqToMidi(pitch))-str;%define it on the onset of a not!
    if prod(fret>=0)~=1
        msgbox('Bad definition for track index or open string.')
        return
    end
end
end