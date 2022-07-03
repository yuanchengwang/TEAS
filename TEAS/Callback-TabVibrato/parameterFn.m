function parameterFn(hObject,eventData)
%CHANGEMETHODVIBRATOPARAFN The vibrato para have to be updated when the
%method for extracting vibrato paras is changed.
    global data;
    %show the corresponding vibrato parametes
    %plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange);
    %clear vibratos;
    plotClearFeature('Vibrato');
    
    %method = get(data.methodVibratoChange,'Value');
    method1= get(data.methodVibratoDetectorChange,'Value');
    
    if ~isfield(data,'vibratoPara')
        data.vibratoPara={};
        data.numViratoSelected={};
    end
    
    if method1==2%power difference
        data.parametervalue.set('string',10^(1-1/get(data.parameter,'Value')));%logscale b=10^(1-1/a)        
        %getVibratoFn;
    elseif method1==3%power ratio
        data.parametervalue.set('string',get(data.parameter,'Value'));
        %getVibratoFn;
    else
        data.parametervalue.set('string',0);%keep 0 for the Decision Tree
        data.parameter.set('string',0);
        %plotVibratoStatistics(data.textVib,data.vibratoPara,data.numViratoSelected,data.methodVibratoChange,data.methodVibratoDetectorChange,data.methodParameterChange);
    end
    if isfield(data,'pitch')
        getVibratoFn;
        if data.methodVibratoDetectorChange.Value
            msgbox('Change Decision Tree into Power Difference or Power Ratio if sliding the scroll.');
        end
    end
end