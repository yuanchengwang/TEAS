function [path,time] = getPitchPyin( fileName,P )
%GETPITCHPYIN get the pitch using pyin Direct Viterbi decoding (instead of HMM
%decoding) method.
%Input
%@fileName: the file name. e.g.'all_of_me.wav'
%Output
%@path: the decoded pitch path. Hz
%@time: the corresponding time vector. time(s)


    P.wsize = 2048;%0.046
    P.hop = 256;
    P.thresholds = 0.01:0.01:1;
    P.relflag = 1;
    numThresholds = length(P.thresholds);

    r = yin_for_pyin(fileName,P);%需要改的地方5.83s

    %get the threshold probability table
    step = 0.01;%与diff有关
    betaPD1 = makedist('Beta','a',2,'b',18); %b = 18,34/3,8，by default=4,leftward b+,a-,tony参数如何设定的？
    probThreshTable =  (pdf(betaPD1,P.thresholds)*step)';
    % probThreshTable = ones(numThresholds,1);

    %---Calculate the probability for each frequency estimate----
    %the last row is the unvoiced state
    uniqueFre = ones(5,size(r.f0,2));%size(r.f0,2)=T%如何保证最多4个candidate pitches？
    probFreqEst = zeros(5,size(r.f0,2));
    %alpha: the probability
    alpha = r.good_flag;
    alpha(alpha == 0) = 0.01;%prior
    for j = 1:size(r.f0,2)%2218 frames
        uniqueVal = unique(r.f0(:,j));%j=1,nan
        tempProbTable = probThreshTable.*alpha(:,j);%100*2218
        if ~isnan(uniqueVal)
            uniqueFre(1:length(uniqueVal),j) = uniqueVal;%前几个用，1575
            for i = 1:length(uniqueVal)
                probFreqEst(i,j) = sum(tempProbTable(r.f0(:,j) == uniqueVal(i)));
    %             %--if there is only one frequency estimate--
    %                 if length(uniqueVal) == 1 && probFreqEst(i,j) < 0.5
    %                     probFreqEst(i,j) = 0.51;
    %                 end
    %           
            end
        end
    end
    probFreqEst(5,:) = 1-sum(probFreqEst(1:4,:)); %the last row is the un-pitched state
    %------------------------------------------------------------

    %-----Viterbi decoding----------
    path = ViterbiAlgPyin(uniqueFre,probFreqEst);
    %------------------------------
    time = (1:length(path))/(r.sr/r.hop);
end

