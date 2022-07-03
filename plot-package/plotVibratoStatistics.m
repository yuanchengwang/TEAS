function plotVibratoStatistics(textList,vibratosParaAll,numViratoSelected,methodVibratoChange,methodVibratoDetectorChange,methodParameterChange)
%PLOTVIBRATOSTATISTICS plot (show) the vibrato statistics
%   Input
%   @testList: text UI to show vibrato rate, extent and sinusoid similarity
%   @vibratosParaAll: vibratosParaAll{1} from FDM, vibratosParaAll{2} from
%   Max-min
%   @numViratoSelected: the number of selected vibrato.
%   @methodVibratoChange: （popup Uicontrol）indicates which method of extracting vibrato para shoud be used. (1: FDM, 2: Max-min)
    method = get(methodVibratoChange,'Value');
    method1 = get(methodVibratoDetectorChange,'Value');
    method2 = get(methodParameterChange,'Value');
    rateIndex = 1;
    extentIndex = 2;
    vibratosPara={};
    %SSIndex = 0;
    if size(vibratosParaAll,1)<method || size(vibratosParaAll,2)<method1 || size(vibratosParaAll,3)<method2
        msgbox('Algorithm isn''t launched, please press buton Get Vibrato(s) first.');
        return
    end
    if method2 == 1
        %mean
        if ~isempty(vibratosParaAll)
            vibratosPara = vibratosParaAll{method,method1,1};
            SSIndex = 3;
        end        
    elseif method2 == 2
        %Max-min
        if ~isempty(vibratosParaAll)
            vibratosPara = vibratosParaAll{method,method1,2};
            SSIndex = 5;
        end
        %Sinusoidal similarity 的标号
        %methodVibratoDetectorChange.set('String',{'Decision Tree'})
        %parameter.set('Value',0)
        %parametervalue.set('Value',0)
    end
    if ~isempty(vibratosPara)
        textList(1).set('String',vibratosPara(numViratoSelected,rateIndex));
        textList(2).set('String',vibratosPara(numViratoSelected,extentIndex));
        textList(3).set('String',vibratosPara(numViratoSelected,SSIndex));%对应的标号抽取
    else
        textList(1).set('String',[]);
        textList(2).set('String',[]);
        textList(3).set('String',[]);      
    end
end

