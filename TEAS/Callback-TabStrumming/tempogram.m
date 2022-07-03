function tg=tempogram(onset_env,win_length,hop_length)
L=win_length*2-1;
tg=zeros(L,floor(length(onset_env)/hop_length));
for i=1:floor(length(onset_env)/hop_length)
    tg(:,i)=xcorr(onset_env(hop_length*(i-1)+1:hop_length*(i-1)+win_length)-mean(onset_env(hop_length*(i-1)+1:hop_length*(i-1)+win_length)),'unbiased');
end
%unilateralize and normalize
tg=tg(win_length:L,:);
tg=tg-min(tg);
tg=tg./max(tg);
end