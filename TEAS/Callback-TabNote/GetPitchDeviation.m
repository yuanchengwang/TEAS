function [pitchDeviation] = GetPitchDeviation(pitch)
%PITCHDEVIATION Calualte the pitch ground the ceil deviation
%   Input:
%   @pitch: the pitch vector in Hz
%   Output:
%   @pitchDeviation: [ground pitch deviation, ceil pitch deviation]
    
    %for after R2014a
    [envelope,BinEdges,~]= histcounts(freqToMidi(pitch),10000);%10000
    pitchDistribution = [[(BinEdges(1:end-1)+(BinEdges(2)-BinEdges(1))/2),BinEdges(end-1)+(BinEdges(2)-BinEdges(1))/2+(BinEdges(2)-BinEdges(1))*(0:49)]',[envelope,zeros(1,50)]'];
    %deal with the high edge probability
    
    %before 2014b
%     [envelope,centers]= hist(freqToMidi(pitch),10000);
%     pitchDistribution = [centers',envelope'];
    
    %only look at the pitch range [1,120]
    pitchDistributionNew(:,1) = pitchDistribution((pitchDistribution(:,1) >= 1 & pitchDistribution(:,1) <=127),1);
    pitchDistributionNew(:,2) = pitchDistribution((pitchDistribution(:,1) >= 1 & pitchDistribution(:,1) <=127),2);
    %smooth the histogram envelope
%     pitchDistributionNew(:,2) = smooth(pitchDistributionNew(:,2),30); %or
    pitchDistributionNew(:,2) = smooth(pitchDistributionNew(:,2),50);
    %normalize the occurence between 0 and 1
    pitchDistributionNew(:,2) = (pitchDistributionNew(:,2)-min(pitchDistributionNew(:,2)))/(max(pitchDistributionNew(:,2)-min(pitchDistributionNew(:,2))));
    %get the peaks of the histogram envelope
    [peakValues,peakIndex] = findpeaks(pitchDistributionNew(:,2));
    peaks = [pitchDistributionNew(peakIndex,1),peakValues];

    %set a threshold for peak selection.
    peakThresholdOccur = 0.03;
    peaksSelect(:,1) = peaks((peaks(:,2)>= peakThresholdOccur),1);
    peaksSelect(:,2) = peaks((peaks(:,2)>= peakThresholdOccur),2);

    %sort the peaksSelect
    [temp,originalPos] = sort(peaksSelect(:,2),'descend');
    peaksSort = [peaksSelect(originalPos,1),temp];%抽取出现比较多的个别音高并排序

    %we assume the peaks should be 0.75 semitone away
    %And we start from the highest peak从最高的开始弄
    peakThresholdSemi = 0.75;
    
    peaksFinal = peaksSort(1,:);
    flag = 0;
    for ii = 2:size(peaksSort,1)
        flag = 0;
        for j = 1:size(peaksFinal,1)
            if abs(peaksSort(ii,1)-peaksFinal(j,1)) <= peakThresholdSemi
                flag = 1;
            end
        end

        if (flag == 0)
            peaksFinal(end+1,:) = peaksSort(ii,:);
        end
    end

    pitchDevGround = abs(mean(peaksFinal(:,1)-floor(peaksFinal(:,1))));%peakfinal向下平均绝对值
    pitchDevCeil = abs(mean(peaksFinal(:,1)-ceil(peaksFinal(:,1))));
    
    pitchDeviation = [pitchDevGround,pitchDevCeil];%和为1，一个大于0.5，一个小于0.5
    %---------------------------------------------

%     fontSize =30;
%     figure(4)
%     subplot(2,1,1)
%     histogram(freqToMidi(pitch),10000);
%     xlabel('Midi Note','FontSize',fontSize);
%     ylabel('Occurrence','FontSize',fontSize);
% %     title('Histogram of Original f0','FontSize',fontSize);
%     set(gca, 'FontSize', fontSize);
%     ylim([0,25]);
%     xlim([52,78]);
% 
%     subplot(2,1,2)
%     plot(pitchDistributionNew(:,1),pitchDistributionNew(:,2),'LineWidth',2);
%     hold on
%     plot([0,120],[peakThresholdOccur,peakThresholdOccur],'r--','LineWidth',2);
%     plot(peaksSort(1,1),peaksSort(1,2),'kx','LineWidth',2,'MarkerSize',12);
%     plot(peaksFinal(1,1),peaksFinal(1,2),'ro','LineWidth',2,'MarkerSize',12);
%     for i = 2:size(peaksSelect,1)
%         plot(peaksSort(i,1),peaksSort(i,2),'kx','LineWidth',2,'MarkerSize',12);
%     end
%     for i = 2:size(peaksFinal,1)
%         plot(peaksFinal(i,1),peaksFinal(i,2),'ro','LineWidth',2,'MarkerSize',12);
%     end
%     hold off
%     xlabel('Midi Note','FontSize',fontSize);
%     ylabel('Norm. Occurrence','FontSize',fontSize);
% %     title('Peak Selection','FontSize',fontSize);
%     set(gca, 'FontSize', fontSize);
%     ylim([0,1.2]);
%     xlim([52,78]);
%     legend('Histogram envelope','Peak threshold','Raw peak','Selected Peak','Location','NorthEast');
end

