function pitch_tmp=pitch_dilate(pitch,pitchTime,notes)
pitch_tmp=pitch;
pitch_flag=zeros(size(pitch));
for i=1:size(notes,1)%note1=onset,onset2=duration
    [~,a]=min(abs(notes(i,1)-pitchTime));
    [~,b]=min(abs(notes(i,1)+notes(i,2)-pitchTime));
    pitch_flag(a:b)=1;
    %disp([a,b]);
    if prod(pitch(a:b))==0 & sum(pitch(a:b))~=0%0 pitch exist in note,but not all 0
        %find the edge
        edge1=find(diff(pitch(a:b)>0)==1)+a;
        edge2=find(diff(pitch(a:b)>0)==-1)+a-1;
        %disp(edge1);
        %disp(edge2);
        for k=a:b%find the closest value to fill the zero
            if pitch(k)==0
                %disp(k);
                [c1,c_1]=min(abs(k-edge1));
                [c2,c_2]=min(abs(k-edge2));
                %disp([c1,c2,c_1,c_2]);
                if isempty(c1)
                    pitch_tmp(k)=pitch(edge2(c_2));
                elseif isempty(c2)
                    pitch_tmp(k)=pitch(edge1(c_1));
                else
                    if c2>c1
                        pitch_tmp(k)=pitch(edge1(c_1));
                    elseif c2<c1
                        pitch_tmp(k)=pitch(edge2(c_2));
                    else%c1=c2
                        pitch_tmp(k)=(pitch(edge1(c_1))+pitch(edge2(c_2)))/2;
                    end
                end
            end
        end
    end  
end
pitch_tmp(~pitch_flag)=0;
end