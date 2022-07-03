function names=notename(n)
% Mutual conversion between MIDI numbers and American pitch spelling (text)
% names=notename(n)
% Converts MIDI numbers to American pitch spelling (text) where C4# 
% denotes C sharp in octave 4 or the opposite. Octave 4 goes from middle C up to 
% the B above middle C. 
%
% Input argument: 
%	N = The pitches of NMAT (i.e. pitch(nmat))
%   N = Text string of equivalent size of N
% Output: text string of equivalent size of N.
%       The pitches of NMAT (i.e. pitch(nmat))
% Remarks:
%
% Example:
%
%  Author		Date
%  T. Eerola	3.1.2003
%? Part of the MIDI Toolbox, Copyright ? 2004, University of Jyvaskyla, Finland
% See License.txt

%n=pitch(nmat)
a=('CDDEEFGGAABBCCDDEFFGGAAB')';
b=(' - -  - - -  # #  # # # ')';
c=[0:11,0:11];
%Vector input supported
if ischar(n) %for example 'A3#' or 
    if length(n)==2
        n=[n,' '];
    end
    for i=1:24
        if n(1)==a(i)&& n(3)==b(i)
            break
        end
    end
    o=str2num(n(2)); 
    names=num2cell((o+1)*12+c(i));%A3=57
elseif iscell(n)%{'A3#','C5'}
    names=cell(length(n),1);
    for i=1:length(n)
        if length(n{i})==2
            m=[n{i},' '];
        else
            m=n{i};
        end
        for j=1:24
            if m(1)==a(j)&& m(3)==b(j)
                break
            end
        end
        o=str2num(m(2)); 
        names{i}=(o+1)*12+c(j);
    end
else%for example 55 or [55,23]£¬scalar or number vector
  m=round(n(:));
  o=floor(m/12)-1;
  m=m-12*o+6*sign(n(:))-5;
  names=cell(length(m),1);
  for i=1:length(m)
      names{i}= [a(m(i)) mod(o(i),10)+'0' b(m(i))];
  end
end
end