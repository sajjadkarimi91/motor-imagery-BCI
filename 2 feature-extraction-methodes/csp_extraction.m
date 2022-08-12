function csp_logfeatures = csp_extraction(eeg_epoched , fs, Wbp , lable)

for num_trail = 1 : size(eeg_epoched , 3)

    csp_logfeatures(num_trail).lable = lable(num_trail);

    temp_data = squeeze( eeg_epoched(:,round(4.5*fs)+1:round(6.5*fs),num_trail));
    csp_sources = Wbp'*temp_data;
    temp_energy = csp_sources * csp_sources';
    csp_logfeatures(num_trail).train = log( diag(temp_energy)/trace(temp_energy) );

    for t = 1:7 % considering 7 sliding window
        temp_data = squeeze( eeg_epoched (:,fs*(t-1)+1:fs*(t+1) ,num_trail));
        csp_sources = Wbp'*temp_data;
        temp_energy = csp_sources * csp_sources';
        csp_logfeatures(num_trail).test{t} = log( diag(temp_energy)/trace(temp_energy) );
    end

end