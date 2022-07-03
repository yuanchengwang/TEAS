%-----------------------------------------------------
% KAMIR
% 
% Kernel Additive Models for Interference Reduction 

% for the overdetermined case, 
% with frequency-dependant interference matrix
%
%-----------------------------------------------------
%    Antoine Liutkus, Inria, 2014
%clear all;

%addpath('includes');

%input dir: each wav file in that directory is a mono file for one of the
%microphones. All files ought to be synchronized and of same length
function KAMIR(hObject,eventData)
global data;
%Check the 4 tracks of optical chennels 
if ~isfield(data,'denoisedWaveTrack')
    msgbox('Tracks are not imported. Please import all denoisedwave tracks.');
    return
end
if length(data.denoisedWaveTrack)~=data.track_nb
    msgbox('Tracks are not imported. Please import all denoisedwave tracks.');
    return
end
for i=1:data.track_nb
if isempty(data.denoisedWaveTrack{i})
   msgbox(['The',num2str(i),'track is not imported. Please import all denoisedwave tracks.']);
   return
end
end

datadir='temp_multichannel';
%output dir where results will be written as wave files
outdir = 'output';

audiofile=dir(datadir);
suffix=split(audiofile(3).name,'-');
suffix=[suffix{1},'_bleeded'];
%parameters
nfft = 8192; %length of windows
overlap=0.9; %overlap of adjacent windows
Lmax=500;     %truncated if larger than Lmax seconds

%minimum amount of leakage, between 0 and 1
minleakage = 0.05;

%sources parameters
selection_threshold = 0.8;  %threshold on L to select channel for fitting
alpha=2;    %alpha parameter (2=gaussian)

% use logistic approximation  ?
approx = 0;
    %if yes
    slope = 20; 
    thresh = 0.6;
    
    %if no
    niter = 5; %number of iterations

% interference matrix parameters 
good_init = 0; %user defined initialization
if ~good_init
    J = data.track_nb;%21->11, ours 4->4
    niter_L = 3;
else
    niter_L = 1;
end

learn_L = 1; %learn L
beta=0;     %beta divergence for fitting L. 
            %2=squared error,1=KL, 0=Itakura Saito, nan=use Lalpha

%Kernel for median filtering at init & each iteration
% proximityKernel = [0,0,0,0,0,0,0;...
%                    0,0,1,1,1,0,0;...
%                    0,1,1,1,1,1,0;...
%                    0,0,1,1,1,0,0;...
%                    0,0,0,0,0,0,0];
%proximityKernel  = ones(10,4);
proximityKernel = 1;
%1) listing files
%----------------
f = dir(fullfile(datadir, '*.wav'));
filenames=sort({f(:).name});
I=data.track_nb;
sig = {};
% if I==0
%     disp('No file found, check your directory. Aborting');
%     return;
% end


% Specification of the configuration L is IxJ
if good_init
    % Specification of the configuration L is IxJ
    % Specification of the configuration L is IxJ
    sources_names = {'Vl1','Vc','Vla','Vl2','Kb','Fl','Kl','Fg','Hrn','Solo1','Solo3'};
    %    Vl1  Vl1h Vl1+ Vcv  Vch Vc+ Vlav Vlah Vla+ Vl2v Vl2h Vl2+ Kbku KbNi Fl  Kl  Fg  Hrn Hrnh Solo1 solo2
    L0 = [1,   1,   1,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  0,  0,  0,   0,    0;... %Vl1
         0,   0,   0,   1,   1,  1,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  0,  0,  0,   0,    0;... %Vlc
         0,   0,   0,   0,   0,  0,  1,   1,   1,   0,   0,   0,   0,   0,   0,  0,  0,  0,  0,   0,    0;... %Vla
         0,   0,   0,   0,   0,  0,  0,   0,   0,   1,   1,   1,   0,   0,   0,  0,  0,  0,  0,   0,    0;... %Vl2
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   1,   1,   0,  0,  0,  0,  0,   0,    0;... %Kb
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   1,  0,  0,  0,  0,   0,    0;... %Fl
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  1,  0,  0,  0,   0,    0;... %Kl
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  1,  0,  0,   0,    0;... %Fg
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  0,  1,  1,   0,    0;... %Hrn
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  0,  0,  0,   1,    0;... %Solo1
         0,   0,   0,   0,   0,  0,  0,   0,   0,   0,   0,   0,   0,   0,   0,  0,  0,  0,  0,   0,    1]';   %Solo2
    
    %put some leakage everywhere
    L = max(L0,selection_threshold);
    J = size(L,2);
else
    L = zeros(I,J);
    pos=1;
    step=I/J;
    pos = [round((0:(J-1))*step+1),I+1];
    for j=1:J
        %L(max(1,pos(j)-1):min(I,pos(j+1)),j) = 1;
        L(j,j) = 1;
    end
    L = max(selection_threshold,L(1:I,1:J));
end

%2) building data
%----------------
%clear sig;clear X;

str = [];
for i=1:I
    fprintf(repmat('\b',1,length(str)));
    str=sprintf('loading %d/%d',i,I);
    fprintf('%s', str);        

    sig{i}=Signal(fullfile(datadir, filenames{i}));
    
    % mix down to 1 channel (it should be only one channel)
    if size(sig{i}.s,2) > 1, sig{i}.s = sig{i}.s(:,1); end
    
    %cut signal to max size
    truncated=sig{i}.s(1:min(sig{i}.sLength,Lmax*sig{i}.fs));
    sig{i}.s=truncated(:);
    
    %compute STFT
    sig{i}.nfft=nfft;
    sig{i}.overlapRatio=overlap;
    sig{i}.STFT;
    
    X(:,:,i) = sig{i}.S(1:sig{i}.nfftUtil,:);
end
X=single(X);
fprintf ('   done.\n')

[F,T,I] = size(X);

%Frequency dependent interference matrix. 
%Initially just duplicate across F
%L = repmat(permute(L,[3,1,2]),F,[1,1,1]);
L = repmat(permute(L,[3,1,2]),[F,1,1]);

%%

% 3) Automatic handling of equalization: we want all background noise to be at the
% same level so that no channel is artificially much higher than others and contains 
% all the energy at any frequency
%--------------------------------------------------------------------
disp ('Identifying channel gains....')
gains = zeros(F,I);
for i = 1:I
    V = abs(X(:,:,i)).^alpha;
    gains(:,i) = quantile(V,0.05,2).^(1/alpha);
end

disp('Compensating gains:')
X = bsxfun(@times,X,permute(1./gains,[1,3,2]));

figure(9);clf;loglog(linspace(0,sig{1}.fs/2,size(X,1)),gains);drawnow;
xlabel('frequency (Hz)');ylabel('noise floor');grid on;
title('Noise floor for all channels');drawnow


%% 
%4) Initializing Kernel BackFitting
%------------------------------
tic

% to select the median during ordfilt2
midposKernel = round(length(find(proximityKernel))/2);

% Initialize the sources as the observation
disp('Initializing PSD with selected mixtures')
P = zeros(F,T,J);
V = abs(X).^alpha;
for j = 1:J
    if ~good_init
        P(:,:,j) = mean(V(:,:,squeeze(median(L(:,:,j),1))>selection_threshold),3);
    else
        P(:,:,j) = mean(V(:,:,find(L0(:,j))),3);
    end

    %median filter if needed
    if numel(proximityKernel) > 1
        P(:,:,j) = ordfilt2(P(:,:,j),midposKernel,proximityKernel);
    end    
end

if approx
    if learn_L
        niter = 1;
    else
        niter=0;
    end
end

%% 
%5) Kernel Back Fitting
%------------------------------

str = [];
for it = 1:niter+1
    %for each iter (niter+1 is for rendering and wavwrite)
    
    for j = 1:J
        %for each source
        
        %a bit of display
        %fprintf(repmat('\b',1,length(str)));
        str=sprintf('KAMIR, iteration %d/%d : source %d/%d\n', it, niter,j,J);
        fprintf('%s', str);        
        
        %get the channels linked to this source
        MaxInterference = max(squeeze(median(L(:,:,j),1)));
        if ~good_init %|| it<=niter
            closemics = find(squeeze(median(L(:,:,j),1))>selection_threshold*MaxInterference);
            %closemics = find(L(:,j)>selection_threshold*MaxInterference);
        else
            closemics = find(L0(:,j));
        end
        
        %get the image of this source in these channels
        Y = zeros(F,T,length(closemics));
        for n = 1:length(closemics)
            %compute model for this channel
            model = zeros(F,T)+eps;
            for j2 = 1:J
                model = model + bsxfun(@times,L(:,closemics(n),j2),P(:,:,j2));
            end
            
            %compute wiener filters to separate image of j in this chann
            W = bsxfun(@times,L(:,closemics(n),j),P(:,:,j))./model;

            %if we do the approx, do the logit stuff
            if approx && (it==1)
                W=1-1./(1+exp(slope.*(W-thresh)));            
            end
            
            %apply the Wiener gain
            Y(:,:,n) = W.*X(:,:,closemics(n));
        end
        
        %Y is the image of the source in its channels of importance
        
        %if we are finished, just render Y and wavwrite it
        if it==niter+1
            %allocate memory for the waveform
            separated = zeros(sig{1}.sLength,length(closemics));
            
            %for each channel, make a istft
            for n = 1:length(closemics)
                %build back the negative frequency part
                Y(:,:,n) = bsxfun(@times,Y(:,:,n),gains(:,closemics(n)));
                sig{closemics(n)}.S = sig{closemics(n)}.buildComplete(Y(:,:,n));
                
                %istft
                separated(:,n) = sig{closemics(n)}.iSTFT();
            end
            
            %write result
            if exist('sources_names','var')
                audiowrite(fullfile(outdir,[suffix '_' sources_names{j},'.wav']),separated,sig{1}.fs);
            else
                audiowrite(fullfile(outdir,[sprintf('%s_source_%d',suffix,j),'.wav']),separated,sig{1}.fs);
            end
            %go to the next source
            continue
        end
        
        %compute average spectrogram on the selected channels
        P(:,:,j) = mean(bsxfun(@times,abs(Y).^alpha,permute(1./L(:,closemics,j),[1,3,2])),3);

        %median filter if needed
        if numel(proximityKernel) > 1
            P(:,:,j) = ordfilt2(P(:,:,j),midposKernel,proximityKernel);
        end
    end
    
    if learn_L &&  (it <= niter)
        %now learn gains
        for it_l = 1:niter_L
            if niter_L > 1
                fprintf('    updating gains : %d/%d\n',it_l,niter_L);
            else
                disp('    updating gains');
            end
            parfor_progress(I*J);
            oldL = L;        
            for i=1:I
                model = ones(F,T)*eps;
                for j2 = 1:J
                    model = model + bsxfun(@times,L(:,i,j2),P(:,:,j2));
                end

                for j = 1:J
                    parfor_progress;


                    if ~isnan(beta)
                        %classical beta-divergence
                        num   = eps+sum(model.^(beta-2).*V(:,:,i).*P(:,:,j),2);
                        denum = eps+sum(model.^(beta-1).*max(P(:,:,j),eps),2);
                    else
                        %with L_alpha distorsion
                        distortion = abs(eps+model-V(:,:,i)).^(alpha-2);
                        num   = eps+sum(V(:,:,i).*distortion.*P(:,:,j),2);
                        denum = eps+sum(model.*distortion.*P(:,:,j),2);
                    end
                    L(:,i,j) = L(:,i,j).*num./denum;
                end

            end
            
            parfor_progress(0);
%                         LmaxF = max(L,[],3);
%                         L = bsxfun(@times,L,1./LmaxF);
            LsumF = sum(L,3);
            L = bsxfun(@times,L,1./LsumF);
            L = max(L,minleakage);
        end
        
        
        figure(10)
        clf;
        imagesc(squeeze(mean(L,1)));
        xlabel('sources j')
        ylabel('channels i')
        colorbar
        title('Average Interference matrix $\lambda_{ij}$','Interpreter','latex')
        drawnow;
        disp('    done')    
    end
end
fprintf ('   done.\n')
toc
