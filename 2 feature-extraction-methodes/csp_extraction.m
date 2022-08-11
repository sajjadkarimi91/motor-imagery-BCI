function csp_logfeatures = csp_extraction(eeg_epoched , fs, Wbp , Lable)

for num_trail = 1 : size(eeg_epoched , 3)
    
    temp_data = squeeze( eeg_epoched(:,round(4.5*fs)+1:round(6.5*fs),num_trail));
    
    csp_sources = Wbp'*temp_data;
    
    temp_energy = csp_sources * csp_sources';
    csp_logfeatures(num_trail).Train = log( diag(temp_energy)/trace(temp_energy) );    
    csp_logfeatures(num_trail).Lable = Lable;
    
    for s = 1:7 % considering 7 sliding window
        temp_data = squeeze( eeg_epoched (:,fs*(s-1)+1:fs*(s+1) ,num_trail));        
        csp_sources = Wbp'*temp_data;        
        temp_energy = csp_sources * csp_sources';
        csp_logfeatures(num_trail).Test(s).x = log( diag(temp_energy)/trace(temp_energy) );        
    end
    
end