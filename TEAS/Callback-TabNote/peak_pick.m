function peaks=peak_pick(x,pre_max,post_max,pre_avg,post_avg,delta,wait)
% PEAKPICK for onset and offset detection
assert(nargin==7,'7 augments are required.');
assert(round(pre_max)==pre_max&&round(post_max)==post_max&&round(pre_avg)==pre_avg&&round(post_avg)==post_avg&&round(wait)==wait...
&&wait>=0 &&pre_max>=0&&post_max>=0&&pre_avg>=0&&post_avg>=0,'The paremeters(pre_max,pre_avg,wait) must be non-negative integers.');
assert(round(post_max)==post_max&&round(post_avg)==post_avg&&round(wait)==wait&&wait>=0 &&pre_max>=0&&post_max>=0&&pre_avg>=0&&post_avg>=0,...
    'The paremeters(post_max,post_avg) must be positive integers.');
assert(length(size(x))==2&&min(size(x))==1,'Input must be 1D.');
assert(delta>=0,'Delta must be non-negative');
if size(x,2)==1
    x=x';
end
max_length = pre_max + post_max;
%max_origin = ceil(0.5 * (pre_max - post_max));
%avg_length = pre_avg + post_avg;
%avg_origin = ceil(0.5 * (pre_avg - post_avg));
mov_max=zeros(size(x));
mov_avg=zeros(size(x));
x_min=min(x);
x_padded_mean=[x,x(end)*ones(1,post_avg)];% the nearest at the end
x_padded_max=[x_min*ones(1,pre_max),x,x_min*ones(1,post_max)];%constant,good
for i=1:length(x)
    mov_avg(i)=mean(x_padded_mean(max(i-pre_avg,1):i+post_avg));%not equal to the 0_padded x at the begining,
    mov_max(i)=max(x_padded_max(i:i+max_length));
end    
%first masks
detections = x .* (x == mov_max);
detections = detections .* (detections >= (mov_avg + delta));
last_onset = -inf;
peaks=[];
for i=1:length(x)
    % Only report an onset if the "wait" samples was reported
    if i > last_onset + wait && detections(i)~=0
        peaks=[peaks,i];
        % Save last reported onset
        last_onset = i;
    end
end
peaks=peaks-1;
end