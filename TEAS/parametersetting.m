function data=parametersetting(hObject,eventData)
data.filenamedefault='pipa';
% Definition for string and open string
data.track_nb=4;%[];
data.track_index=4;%[];
data.str={57,52,50,45};%deviation of tuning%{57,52,50,45};%notename({'A3','E3','D3','A2'}) for open string
data.highest={87,82,73,65};%{88,83,74,66};%notename({'E6','B5','D5','F4#'}) for open string
%Basic parameter setting
data.fs=44100;
data.hop_length=221;%5 ms,about 200 frames per second
data.win_length=2048;
data.double_peak=2;%fake nail property, pluck peak+natural transient;

%Preset for MIDI export, not important if you don't want a score.
data.beats_per_second=2;%120 BPM, initial guess of BPM
data.ticks_per_beat=384;

% Note alignment configure
data.onset_align_valid=0;
data.offset_align_valid=1;

% Warnning: max velocity will determine the velocity value, check the gain and reset it.
data.max_velocity=128;%max level to normalize the velocity for corresponding max!!64 by default
data.gain=1;
data.offset_threshold=0.05;
data.microseconds_per_beat=1e6/data.beats_per_second;%Tempo
data.time_signature=[4,4];
data.key=[];%the key to play, required if you want to convert to a numbered score.
data.tempo_win_length=384;
data.tempo_hop_length=512;
%Denoise
data.LEQthreshold=35;

%Vibrato
data.xAxisVibrato = 1; %for x axis chosen, 1: Original time; 2: Normalized time

%Strumming
data.selectedtrack=1;%Initial setting for track in strumming
data.criteria_strum=50;% between two onsets,0.05s
data.criteria_strumRate=0.3;%strum speed criteria
end