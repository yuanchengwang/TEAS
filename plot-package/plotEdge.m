function patchFeaturesPoint=plotEdge(varargin)
    onset=varargin{1};
    offset=varargin{2};
    assert(nargin==3||6,'Bad input for plotEdge.');
    if nargin==3
        axeInput=varargin{3};
    else
        onset_env=varargin{3};
        %offset_env=varargin{4};
        EdgeTime=varargin{4};
        axeInput=varargin{5};
    end
    axes(axeInput);
    yyaxis left;
    hold on
    if nargin==5
    %the y axis in plot pitch starts with 55 midi note£¬ onset_env+offset_env are
    %normalized to 17 midi note to better show the envelope.
    patchFeaturesPoint(length(onset)+1,1) = plot(EdgeTime,onset_env./max(onset_env)*17+55,'-','Color','blue');%onset_env
    %patchFeaturesPoint(length(offset)+1,2) = plot(EdgeTime,offset_env./max(offset_env)*17+55,'-','Color','green');%offset_env
    axis([EdgeTime(1),EdgeTime(end),axeInput.YLim(1),axeInput.YLim(2)]);
    end
    
    y=[0,200];%axeInput.YLim();
    if ~isempty(offset)
        for j=1:length(offset)
            patchFeaturesPoint(j,2) = line([offset(j),offset(j)],...
                    y,'color','yellow');%offset[25,105]
        end%[axeInput.YLim(1),axeInput.YLim(2)]
    end
    if ~isempty(onset)
        for i = 1:length(onset)  
            patchFeaturesPoint(i,1) = line([onset(i),onset(i)],...
                y,'color','red');%onset[25,105]
        end%[axeInput.YLim(1),axeInput.YLim(2)]
    end
    hold off
end