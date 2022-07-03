function [offset,e,time]=energy_RMC(audio)
win=2048;
hop=0.005*44100;
thre=0.00001;%-50db
L=floor((length(audio)-win)/hop);
e=zeros(L,1);
offset=L*hop;
time(1)=0;
for i=2:L
    m=mean(audio((i-1)*hop+1:(i-1)*hop+win));
    e(i)=sum((audio((i-1)*hop+1:(i-1)*hop+win)-m).^2);
end
[e_max,n]=max(e);
for j=n:L
    if e(j)<=e_max*thre
        offset=(j-1)*hop;
    break
    end
end
end