function plotStrumStatistics(textList,strumPara,numStrumSelected)
%PLOTSTRUMSTATISTICS plot (show) the strum statistics
%   Input
%   @testList: text UI to show strum parameters
%   @strumPara: {'Types','Rate','Start/End strings','Direction','Dynamic'};
%   @numStrumSelected: which strum 
    if ~isempty(strumPara)
        for i=1:3            
            if i==3
                if strumPara{numStrumSelected,i}==0
                    textList(i).set('String',[]);
                elseif strumPara{numStrumSelected,i}==1%down
                    textList(i).set('String','Down');
                else
                    textList(i).set('String','Up');
                end
            else
                textList(i).set('String',strumPara{numStrumSelected,i});
            end
        end
    else
        for i=1:3
            textList(i).set('String',[]);
        end
    end
end

