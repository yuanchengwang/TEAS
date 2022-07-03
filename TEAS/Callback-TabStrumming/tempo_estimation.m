function bpm=tempo_estimation(onset_env,start_bpm)
%TEMPO_ESTIMATION to find a performance bpm close to the initial guess bpm.
global data;
%Cyclic tempogram
% tau=8;
% win_length=floor(tau*data.fs/data.hop_length);%8 hops
tg=tempogram(onset_env,data.tempo_win_length,data.tempo_hop_length);%onset,log_energy based,not the data.win_length,data.hop_length
tg=mean(tg,2);%mean local autocorrelation
bpms = zeros(data.tempo_win_length,1);
bpms(1) = inf;
bpms(2:end) = 60 * data.fs ./ (data.hop_length * (1:data.tempo_win_length-1));
% Weight the autocorrelation by a log-normal distribution prior
logprior = -0.5 * ((log2(bpms) - log2(start_bpm))).^2;%std_bpm=1
[~,best_period] = max(log1p(1e6 * max(tg,0)) + logprior);%差一个
bpm=bpms(best_period);
end