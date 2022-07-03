function sn = LEQ(Y,range_ff)
    % estimate equivalent sound level with a power spectral density method
    % for noise
    L=length(Y);
%         if ~isempty(which('pmtm'))
%             [psd_Y,ff] = pmtm(Y,5/2,1000,1);
%         end
    if ~isempty(which('pwelch'))
        [psd_Y,ff]=pwelch(Y,round(L/8),[],1000,1);
    else
        xdft = fft(Y);
        xdft = xdft(:,1:round(L/2)+1);
        psd_Y = (1/L) * abs(xdft).^2;
        ff = 0:1/L:1/2;
        psd_Y(2:end-1) = 2*psd_Y(2:end-1);
    end
    ind=ff>range_ff(1);
    ind(ff>range_ff(2))=0;
    sn=sqrt(mean(psd_Y(ind)/2));%No sqrt
end