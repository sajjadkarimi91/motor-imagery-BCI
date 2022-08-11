function [normalized_data , outlier_removed_data , Sig_2, Mn , index_valid] = sjk_outlier_clip( raw_eeg , outlier_percentage , times_std )
% RawEEG is matrix of features for all class with size NxT where T
% indicate number of samples and N indicate dimension or channels

% OutlierPercentage typically 0.05
% TimesVar typically 5

raw_eeg = double( raw_eeg );

[N,T]=size(raw_eeg);
index_valid = 1:N;



[N,T]=size(raw_eeg);

Mn=zeros(N,1);

Sig_2=zeros(N,1);

normalized_data = zeros (N,T);
outlier_removed_data = zeros (N,T);

% percentage= round(N*0.1);

for i=1:N

    %         if ( mod(i,percentage)==0)
    %             disp( round(100*i/N) );
    %         end
    temp_EEG = raw_eeg(i,:);
    temp_EEG(isnan(temp_EEG))=[];

    [ascend_Data ]= sort( temp_EEG , 'ascend' );% a is nember of  samples in all 50 bines & b is duration of bines in X axes

    % find a suitable treshold for upper & lower 0.05
    OutlierIndex = round(outlier_percentage * T);

    T1 = length(temp_EEG);
    if(T1 - OutlierIndex>5)
        % clean and removes the time course of bad or probably outlier data in order to estimate a better mean and variance
        ascend_Data([1: OutlierIndex , T1 - OutlierIndex : T1] ) = [] ;



        clean_features = ascend_Data;

        % Estimate mean and variance ofter removing outlier
        Mn( i ) = mean(clean_features);
        %check for valid Variance
        if sum(clean_features - Mn(i) )~=0
            Sig_2( i ) = var(clean_features) ;
        else
            Sig_2( i ) = 1 ;
        end

        x = ( raw_eeg( i , :) - Mn(i) ) / sqrt(Sig_2( i ));
        x ( isnan(x) ) = 0 ;

        % This part correct the outlieres according Outlier correction function
        andiss = find( abs(x)< times_std );

        normalized_data(i , andiss) = x (andiss);

        index_nan = ( abs(x)>= times_std ) ;
        normalized_data( i , index_nan ) =  times_std.*sign(x(index_nan));
        normalized_data( i , isnan(raw_eeg( i , :)) ) =  nan;
        outlier_removed_data( i ,: ) = normalized_data( i ,: ) * sqrt(Sig_2( i ))+ Mn(i);

    else
        normalized_data( i , : ) =  nan;
        outlier_removed_data( i , : ) =  nan;
    end

end

full_nan = find(sum(isnan(normalized_data),2)>=min(T-20,0.95*T));
normalized_data(full_nan,:)=[];
outlier_removed_data(full_nan,:)=[];
index_valid(full_nan)=[];
Sig_2(full_nan)=[];
Mn(full_nan)=[];
