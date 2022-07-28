function [ind_EOG, ind_WEOG, eeg_power] = eog_detection_intervals(eeg_signals,fs,eog_ch_index)
%EEG is matrix of pure data that must be EOG corrected
%EEG is N*T (N is # of channels && T is # of time samples)
% fs is sampling frequency
%EEGpower is average power of EEG signal without EOG

N=size(eeg_signals,1);
L1 = round(fs/4);
vv=[zeros(N,L1) double(eeg_signals) zeros(N,L1)];
clear eeg_signals
eeg_signals=vv;
clear vv
T=size(eeg_signals,2);


%Esitmation power of EEG by sliding window that has length 2L1+1
% u=[];
ind_EOG=[];
ind_WEOG=[];
counter1=L1;
k_1=L1+1;
%Estimation of EEG average power
eeg_power = mean (var (eeg_signals(eog_ch_index , : ) ,[], 2) );
clear a b f V
while counter1<T-L1
    counter1=counter1+1;
    %At first divide time to two part 1- time with EOG 2- time without EOG
    %Power estimation

    sigma = max ( var(eeg_signals(eog_ch_index,counter1-L1:counter1+L1),[],2) ) ;

    k1 = counter1;
    while((counter1<(T-L1)) && (sigma > eeg_power))
        counter1=counter1+1;
        sigma = max ( var(eeg_signals(eog_ch_index,counter1-L1:counter1+L1),[] ,2) ) ;
    end
    k2=counter1;

    if (k2-k1 > fs/10)
        ind_EOG = [ind_EOG k1-L1:k2- L1];
        ind_WEOG = [ind_WEOG  k_1- L1+1:k1-L1-1];
        k_1=k2;
    end

end

