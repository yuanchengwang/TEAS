function [transPitchBaseline, transPitchStructure ] = GetTransMatrix( stateRangeTransBaseline,stateRangeTransition )
%GETTRANSMATRIX Return transition matrix for basline and structure HMM.
%   Input
%   @stateRangeTransBaseline: state range for baseline HMM
%   @stateRangeTransition: state range for transition. (up, steady, down).
%   Output
%   @transPitchBaseline: the transition matrix for baseline HMM 
%   @transPitchStructure: thetransition matrix for structure HMM

    %----------START of transiton matrix--------------------
    transPitchBaseline = zeros(length(stateRangeTransBaseline));
    numStatesBaseline = length(stateRangeTransBaseline);
    numStatesTransition = max(1,length(stateRangeTransition));

    %-----create the transition matrix for baseline HMM-------
    for i = 1:numStatesBaseline
        if (i == 1)
            %for "slient" part
            %norma distribution
%             paraTransPitch = [i-1,1];
%             transPitchBaseline(i,:) = normpdf(stateRangeTransBaseline,paraTransPitch(1),paraTransPitch(2))*1;
            %uniform distribution
            transPitchBaseline(i,:) = 1/numStatesBaseline*ones(size(transPitchBaseline(1,:)));
        else
            paraTransPitch = [i-1,4];
            transPitchBaseline(i,:) = normpdf(stateRangeTransBaseline,paraTransPitch(1),paraTransPitch(2))*1;
        end        
    end
    transPitchBaseline(:,1) = transPitchBaseline(1,:)';
%     transPitchBaseline = transPitchBaseline + eye(size(transPitchBaseline,1));
    %----------------------------------------------------------
    
    %----create the transition matrix for structure HMM-------- 
    %expand from the baseline
    transPitchStructure = repelem(transPitchBaseline,numStatesTransition,numStatesTransition);
    transPitchStructure = transPitchStructure(numStatesTransition:end,numStatesTransition:end);
    %----------END of transition matrix-------------------------

end

