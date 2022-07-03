function velocity=sliderate(duration_diff,note_diff)
%specific to Ample Sound Pipa(approximate)%offset=onset+0.03+note_diff*(0.03+0.06/127*(127-velocity))
duration_diff=max(duration_diff-0.03,0.03);%onset head
velocity=max(127-round(max(duration_diff/note_diff-0.03,0)/0.06*127),5);
end