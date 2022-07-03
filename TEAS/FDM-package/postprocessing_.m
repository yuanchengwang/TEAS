function [vibratoCandidatesDT]=postprocessing(PR,thres,frameCriterion,timeF)
    dm=zeros(size(PR));
    dm(PR>=thres)=1.25;
    vibratoIndicateDecisionTree = deleteOutlier(dm,1.25);
    vibratoCandidatesDT = vibratoCandidates(vibratoIndicateDecisionTree,1.25,frameCriterion,timeF);
    %vibratoParametersFDMDT = getVibratoParaFDM(vibratoIndicateDecisionTree,1.25,frameCriterion,[fdResonanceF',fdResonanceD']);
    if size(vibratoCandidatesDT,2)==1
        vibratoCandidatesDT=vibratoCandidatesDT';
    end
    if ~isempty(vibratoCandidatesDT)
        vibratoCandidatesDT(:,3) = vibratoCandidatesDT(:,2)-vibratoCandidatesDT(:,1);
        vibratoCandidatesDT = NotePruning(vibratoCandidatesDT,0.25);
    end    
end