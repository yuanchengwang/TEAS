function strumPara=strumParaDetection(strums,strumsDetail)
%STRUMPARADETECTION get strumming using preset rules
global data;
%Parameters: Types(Strum/Arppegio/Simultaneous multiple plucks),Rate,Start/End strings,Direction,Dynamic;
%data.strumTypes={'Up Strum','Up-tremble Strum','Up-bass Strum','Down Strum','Down-tremble Strum','Down-bass Strum','Up Arpeggio','Up-tremble Arpeggio','Up-bass Arpeggio','Down Arpeggio','Down-tremble Arpeggio','Down-bass Arpeggio','Multiple plucks'};
strumPara=cell(length(strums),4);
for i=1:length(strums)
strumPara{i,1}=strums{i}(end)-strums{i}(1);%Total time interval;
strumPara{i,2}=[strumsDetail{i}(1),strumsDetail{i}(end)];
% if length(strums{i})>=3
order=length(unique(sign(diff(strumsDetail{i}))));%monotonic, all the same sign or not?
if order==2
    strumPara{i,3}=0;
    strumPara{i,4}=length(data.strumTypes);%multiple plucks or bad for detected onset.
else%same order
    flag1=strumsDetail{i}(1:end-1)>=strumsDetail{i}(2:end);
    flag2=strumsDetail{i}(1:end-1)<=strumsDetail{i}(2:end);
    if sum(flag1)==length(strumsDetail{i})-1%all 1
        strumPara{i,3}=1;%down, right-to-left from pipa performer's view
        if length(strums{i})==4
            if strumPara{i,1}<data.criteria_strumRate%0.1 by default,strum
                strumPara{i,4}=4;
            else%arppegio
                strumPara{i,4}=10;
            end
        else%3
            if strumPara{i,1}<data.criteria_strumRate%0.1 by default,strum
                if strumsDetail{i}(1)==3
                    strumPara{i,4}=5;
                else
                    strumPara{i,4}=6;
                end
            else%arppegio
                if strumsDetail{i}(1)==3
                    strumPara{i,4}=11;
                else
                    strumPara{i,4}=12;
                end
            end
        end
    elseif sum(flag2)==length(strumsDetail{i})-1
        strumPara{i,3}=2;%left-to-right
        if length(strums{i})==4
            if strumPara{i,1}<data.criteria_strumRate%0.1 by default,strum
                strumPara{i,4}=1;
            else%arppegio
                strumPara{i,4}=7;
            end
        else%3
            if strumPara{i,1}<data.criteria_strumRate%0.1 by default,strum
                if strumsDetail{i}(1)==2
                    strumPara{i,4}=3;
                else
                    strumPara{i,4}=2;
                end
            else%arppegio
                if strumsDetail{i}(1)==2
                    strumPara{i,4}=9;
                else
                    strumPara{i,4}=8;
                end
            end
        end
    else%Rasgueado
        strumPara{i,3}=0;%left-to-right
        strumPara{i,4}=13;
    end
    
% end
% else
% %strums{i}(1)~=strums{i}(2) for sure
%     if strumsDetail{i}(1)>strumsDetail{i}(2)
%         strumPara{i,3}='Down';%right-to-left
%     else
%         strumPara{i,3}='Up';%left-to-right
%     end
%     strumPara{i,4}=length(data.strumTypes);%multiple plucks
% end
end
end