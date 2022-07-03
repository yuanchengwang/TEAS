function MIDIplot(hObject,eventData)
% MIDIPLOT real-time change the midi symbol if change the midi or frequency
% in the data.PitchXEdit.String Editbox
global data;
if ~isempty(data.PitchXEdit.String)
    model=get(data.PitchXaxisPara,'value');
    number=str2num(data.PitchXEdit.String);
    midi=notename(data.pitchPoint);
    data.PitchXMIDI.set('string',num2str(midi{1}));
    if model==2%freq
        data.pitch(data.pitchIndex)=number;
        data.pitchPoint=freqToMidi(number);
    else%MIDI
        data.pitchPoint=number;
        data.pitch(data.pitchIndex)=MidiToFreq(number);
    end
end
end