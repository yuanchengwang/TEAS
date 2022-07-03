function changeMethodVibratoParaFn(hObject,eventData)
%CHANGEMETHODVIBRATOPARAFN The vibrato para have to be updated when the
%method for extracting vibrato paras is changed.

    global data;
    %show the corresponding vibrato parametes
    if ~isfield(data,'vibratoPara')
        data.vibratoPara={};
        data.numViratoSelected={};
    end
    method = get(data.methodVibratoChange,'Value');
    method1 = get(data.methodVibratoDetectorChange,'Value');
    if ~isempty(data.vibratoPara)
        if prod(size(data.vibratoPara)>=[method,method1,2])%good size
            if isempty(data.vibratoPara{method,method1,1})
                getVibratoFn;
            end
        else
            getVibratoFn;
        end
    end
    plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
end

