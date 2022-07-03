function MIDInotes=NoteNameToMIDInotes(names)
% Conversion of MIDI numbers to American pitch spelling (text)
% names=notename(n)
% Converts MIDI numbers to American pitch spelling (text) where C4# 
% denotes C sharp in octave 4. Octave 4 goes from middle C up to 
% the B above middle C. 
%
% Input argument: 
%	N = The pitches of NMAT (i.e. pitch(nmat))
%
% Output: text string of equivalent size of N.
%
% Remarks:
%
% Example:
%
%  Author		Date
%  T. Eerola	3.1.2003
%© Part of the MIDI Toolbox, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

for num=1:8
eval(['Str(' num2str(num) ').SeqNotes = {''C' num2str(num) ''',''C' num2str(num) '#'',''D' num2str(num) ''',''D' num2str(num) '#'',''E' num2str(num) ''',''F' num2str(num) ''',''F' num2str(num) '#'',''G' num2str(num) ''',''G' num2str(num) '#'',''A' num2str(num) ''',''A' num2str(num) '#'',''B' num2str(num) '''};'])
end

LowestMIDInote = 24;

% for each input notename
MIDInotes = zeros(numel(names) ,1);
for ll=1:numel(names)    
    
    % for each octave
    for mm=1:8
        aa=strmatch(names{ll},Str(mm).SeqNotes,'exact');
        if ~isempty(aa)
            MIDInotes(ll,1) = LowestMIDInote + ((mm-1)*12) + (aa-1);
            break
        end
    end
end
