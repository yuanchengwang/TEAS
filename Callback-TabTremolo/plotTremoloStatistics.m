function plotTremoloStatistics(textPort,tremoloPara,numTremoloSelected)
%PLOTTREMOLOSTATISTICS plot (show) the tremolo statistics
%   Input
%   @textPort: text UI list to show tremolo parameters (A,B,G,L,M,U).
%   @tremoloPara: the parameters of tremolo.
%   @numTremoloSelected: the number of selected tremolo.
    
    %plot the tremolo parameters
    for i = 1:length(textPort)
        textPort(i).set('String',tremoloPara(numTremoloSelected,i));
    end
end

