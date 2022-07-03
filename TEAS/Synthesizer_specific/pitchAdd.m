function note_add=pitchAdd(pitch_seg,note)
%note in pitch
if abs(note-pitch_seg(1))>abs(note-pitch_seg(end))% slide-up 
    note_add=round(freqToMidi(pitch_seg(1)));
else%slide-down
    note_add=round(freqToMidi(pitch_seg(end)));
end