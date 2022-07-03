function Candidate_noise_range(hObject,eventData)
%CANDIDATENOISERANGE using LEQ implemented by Welch method
global data;
FminCut_LEQ = 2200;
FmaxCut_LEQ = data.fs/2-1;
Sref=2e-5;
min_note_length=0.1;
aa=1;
bb=0;
if isfield(data,'audio')
    audio=data.audio;
else
    if isfield(data,'Cleaned_speech')
        audio=data.Cleaned_speech;
    else
        msgbox('No audio input.')
        return
    end
end

num_win=floor(length(audio)/data.win_length);
leq=zeros(num_win,1);
loc=zeros(num_win,2);
h = waitbar(0,'Noise range detecting...');
for L=1:num_win%number of window,no overlap for frame
    waitbar(L/num_win,h,sprintf('%d%% Noise range detecting...',round(L/num_win*100)));
    Sn = LEQ(audio(1+data.win_length*(L-1):data.win_length*L),[FminCut_LEQ,FmaxCut_LEQ]/data.fs);  %noise level 
    leq(L)=20*log10(Sn/Sref);%10 * log10((sqrt(sum(y.^2))./sqrt(n1)./Pref).^2);
    if leq(L)<data.LEQthreshold && aa
        loc(L,1)=L;
        bb = 1;
        aa = 0;
    end
    if leq(L)>data.LEQthreshold && bb
        loc(L,2)=L;
        bb = 0;
        aa = 1;
    end
end
close(h);
% figure;
% plot(leq)
%Extract the segmentation....
start=loc(loc(:,1)~=0,1);
fin=loc(loc(:,2)~=0,2);
if length(start)==length(fin)
data.noise_ranges=[start,fin]*data.win_length/data.fs;
else
fin=[fin;num_win];
data.noise_ranges=[start,fin]*data.win_length/data.fs;
end
data.noise_ranges(diff(data.noise_ranges,[],2)<=min_note_length,:)=[];

%Choose the longest and plotting
if ~isempty(data.noise_ranges)
    if isfield(data,'patchNoiseRangeArea')
        delete(data.patchNoiseRangeArea);
    end  
    if isfield(data,'patchNoiseRangeArea_2')
        delete(data.patchNoiseRangeArea_2);
    end
    if isfield(data,'patchNoiseRangeArea_3')
        delete(data.patchNoiseRangeArea_3);
    end
    [~,data.noise_range_num]=max(diff(data.noise_ranges,[],2));
    data.noise_range=data.noise_ranges(data.noise_range_num,:);
    if isfield(data,'audio')
        data.patchNoiseRangeArea=plotFeaturesArea(data.noise_ranges,data.axeWave);
        plotHighlightFeatureArea(data.patchNoiseRangeArea,data.noise_range_num,1);
    end
%     if isfield(data,'Cleaned_speech')
%         data.patchNoiseRangeArea_2=plotFeaturesArea(data.noise_ranges,data.axedenoisedWave);
%         data.patchNoiseRangeArea_3=plotFeaturesArea(data.noise_ranges,data.axePitchWave); 
%         plotHighlightFeatureArea(data.patchNoiseRangeArea_2,data.noise_range_num,1);
%     end
else
    msgbox('No noise range found.');
end
end