function [onset,duration]=hmm_baseline_core(pitch,time,pitchDeviation)
%get pitch deviation i
pitch = smooth(pitch,10);
midiPitchOriginal = freqToMidi(pitch);
pitchDevGround = pitchDeviation(1);
pitchDevCeil = pitchDeviation(2);
midiPitchGround = zeros(size(midiPitchOriginal));
midiPitchCeil = zeros(size(midiPitchOriginal));
midiPitchGround(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)-pitchDevGround;
midiPitchCeil(midiPitchOriginal > 0) = midiPitchOriginal(midiPitchOriginal > 0)+pitchDevCeil;

pitchRangeTrans = 0:128; %[0,1,2,...128], 0 means silent,
initialStateDistribution = 1/length(pitchRangeTrans)*ones(1,length(pitchRangeTrans));
transPitch = GetTransMatrix(pitchRangeTrans,[]);
observsPitchOriginal = GetObservsMatrixBaseline(midiPitchOriginal,pitchRangeTrans);
observsPitchGround = GetObservsMatrixBaseline(midiPitchGround,pitchRangeTrans);
observsPitchCeil = GetObservsMatrixBaseline(midiPitchCeil,pitchRangeTrans);
%%
midiTranscriptionOriginal(:,1) = ViterbiAlgHMM(transPitch,observsPitchOriginal,initialStateDistribution);
midiTranscriptionOriginal(:,2) = ViterbiAlgHMM(transPitch,observsPitchGround,initialStateDistribution);
midiTranscriptionOriginal(:,3) = ViterbiAlgHMM(transPitch,observsPitchCeil,initialStateDistribution);
NotesHMMNoteModel = NoteAggreBaseline(midiTranscriptionOriginal,1/(time(2)-time(1)));% why midiTranscriptionOriginal
onset=NotesHMMNoteModel{1}(:,1)+time(1);
duration=NotesHMMNoteModel{1}(:,3);
end