function [spec,time]=spect_onset(signal)
global data;
win=hann(data.win_length,'periodic');
%STFT transform 
%spec=stft(signal,'Window',win,'OverlapLength',win_length-hop_length);%FT,ÓÐ¸ºÆµÂÊ
[spec,data.FFF,time]=spectrogram(signal,win,data.win_length-data.hop_length,data.win_length,data.fs);
end