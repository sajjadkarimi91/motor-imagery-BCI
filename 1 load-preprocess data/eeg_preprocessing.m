%This code is dependent on eeglab functions, and eeglab must insatll and
%add biosig plugin

times_var = 5;
outlier_percentage = 0.025;

mkdir(save_dir);


for i = 1:num_subjects
    %% EEGLAB functions
    EEG = pop_biosig([dataset_dir,'/A0',num2str(i),'T.gdf']);
    % eegplot(EEG.data, 'srate', EEG.srate);
    clc
    [~ , EEG.data] = sjk_outlier_clip( EEG.data , outlier_percentage , times_var );

    EEG = pop_resample( EEG, 125);

    %% EOG Correction Sameni method
    EOG_channels = 23:25 ;
    fs = 125 ;
    eeg_signals = double ( EEG.data  );
    [ andis_EOG, andis_WEOG,EEGDatapower] = eog_detection_intervals( eeg_signals ,fs, EOG_channels ) ;

    Ax = cov ( (eeg_signals(: , andis_EOG) )' );
    Cx = cov ( ( eeg_signals(: , andis_WEOG) )' ) ;

    %[U, D] = eig (Ax ,Cx ,'qz' ) ;
    %A*V  =  C*V*D
    [U , D] = gevd(Cx , Ax);
    [~ , SS] = sort ( diag( D ) , 'descend') ;
    source_space = U(:,SS)' * eeg_signals ;
    source_space (1:2 , : ) = 0 ;

    EEG_clean = ( U(:,SS)' )\ source_space ;
    EEG.data = EEG_clean;

    %eegplot(EEG.data, 'srate', EEG.srate);

    %% epoches extractions

    %ERP extraction for component (769 Left hand) (770 Right hand) (771 foot) (772 tongue)
    %EEG_ALL(1).EEG = pop_epoch( EEG , {  '769'  }, [ -4.5   4.5], 'newname', ' resampled resampled epochs epochs', 'epochinfo', 'yes'); % old command

    EEG_ALL(1).EEG = pop_epoch( EEG , { 'class1, Left hand	- cue onset (BCI experiment)'  }, [ -4.5   4.5], 'newname', ' resampled resampled epochs epochs', 'epochinfo', 'yes');

    EEG_ALL(2).EEG = pop_epoch( EEG , { 'class2, Right hand	- cue onset (BCI experiment)'  }, [ -4.5   4.5], 'newname', ' resampled resampled epochs epochs', 'epochinfo', 'yes');

    EEG_ALL(3).EEG = pop_epoch( EEG , { 'class3, Foot, towards Right - cue onset (BCI experiment)'  }, [ -4.5   4.5], 'newname', ' resampled resampled epochs epochs', 'epochinfo', 'yes');

    EEG_ALL(4).EEG = pop_epoch( EEG , { 'class4, Tongue		- cue onset (BCI experiment)'  }, [ -4.5   4.5], 'newname', ' resampled resampled epochs epochs', 'epochinfo', 'yes');

    save([save_dir,'/A0',num2str(i),'T.mat'],'EEG_ALL');

end

make_channel_location; % create channel loaction file for future plotting EEG sensors on the scalp
