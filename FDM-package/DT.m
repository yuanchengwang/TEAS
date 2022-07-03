function vibratoCandidatesDT=DT(fdResonanceF,fdResonanceD,vibratoRateLimit,vibratoAmplitudeLimit,frameCriterion,timeF)
    vibratoIndicateDecisionTree = deleteOutlier(DecisionTree(fdResonanceF,fdResonanceD,vibratoRateLimit,vibratoAmplitudeLimit,1.25),1.25);
    vibratoCandidatesDT = vibratoCandidates(vibratoIndicateDecisionTree,1.25,frameCriterion,timeF);
    %vibratoParametersFDMDT = getVibratoParaFDM(vibratoIndicateDecisionTree,1.25,frameCriterion,[fdResonanceF',fdResonanceD']);
    if size(vibratoCandidatesDT,2)==1
        vibratoCandidatesDT=vibratoCandidatesDT';
    end
    if ~isempty(vibratoCandidatesDT)
    vibratoCandidatesDT(:,3) = vibratoCandidatesDT(:,2)-vibratoCandidatesDT(:,1);
    else
        return
    end
end