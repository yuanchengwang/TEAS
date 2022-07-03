function [mel_spec,F_new,BW]=mel_spect_onset(spec)
global data;
M=221;%138;24 bins per octave (132.5-22.5)*2+1
[filterBank,F_new,BW] = MelFilterBank(data.fs,...
        'FrequencyRange',[30,17235],'FrequencyScale','mel','NumBands',M,...%MIDI:22.5-132.5/[30,17235]
        'FFTLength',data.win_length);
mel_spec=filterBank*abs(spec);
end