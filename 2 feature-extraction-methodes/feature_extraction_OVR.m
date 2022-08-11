


try
    load([save_dir,'\chanlocs.mat'], 'chanlocs')
catch
    load('chanlocs.mat', 'chanlocs')
end

for k_pair = k_pairs
    for i = 1:num_subjects

        disp(['OVR, extracting csp features for subject: #',num2str(i)])
        load([save_dir,'/A0',num2str(i),'T.mat']);

        fs = EEG_ALL(1).EEG.srate;

        clear imagery_classes
        imagery_classes(4).feature = [];

        ferq_bandpass_filters = 4:4:40;

        %%  OVR CSP
        for k = 1:max_class

            all_labels = 1:max_class;
            all_labels(k)=[];

            for freq = 1:length(ferq_bandpass_filters)-1

                eeg_bandpass = sjk_eeg_filter( EEG_ALL(k).EEG.data(eeg_channels ,: ,:), fs, ferq_bandpass_filters(freq),ferq_bandpass_filters(freq+1) ); % bandpass filtering
                temp_data = eeg_bandpass(: ,round(5*fs):round(7*fs) ,:);

                temp_train_one = eeg_bandpass; % one selected class
                temp_concat_one = [];
                for num_trail = 1 : size( temp_data , 3)
                    temp_for = squeeze( temp_data (:,:,num_trail));
                    temp_for = temp_for - repmat( mean(temp_for,2),1 , size(temp_for,2) ); %baseline removing
                    temp_concat_one = [temp_concat_one ,temp_for ];
                end

                temp_data = [];
                temp_concat_rest = [];
                for kk=1:2
                    eeg_bandpass = sjk_eeg_filter( EEG_ALL(all_labels(kk)).EEG.data(eeg_channels ,: ,:), fs, ferq_bandpass_filters(freq),ferq_bandpass_filters(freq+1) ); % bandpass filtering
                    temp_data = cat(3 , temp_data , eeg_bandpass(: ,round(4.5*fs):round(6.5*fs) ,:) );
                    temp_concat_rest = cat(3 , temp_concat_rest , eeg_bandpass );
                end

                temp_train_rest = temp_concat_rest;
                temp_concat_rest = [];
                for num_trail = 1 : size(temp_data , 3)
                    temp_for = squeeze( temp_data (:,:,num_trail));
                    temp_for = temp_for - repmat( mean(temp_for,2),1 , size(temp_for,2) );
                    temp_concat_rest = [temp_concat_rest ,temp_for ];
                end

                sigma_1 = cov ( temp_concat_one' ) ;
                sigma_2 = cov ( temp_concat_rest' ) ;

                [Wb,D] = eig(sigma_1 , sigma_1 + sigma_2);% generalized eigenvalues

                Wbp = Wb(: , [1:k_pair , end-k_pair+1:end]);

                if(k==1 && freq>=2 && freq<=4)
                    figure(1)
                    subplot(3,2,2*(freq-2)+1)
                    hold off
                    topoplot(abs(Wbp(:,1)), chanlocs);
                    title(['CSP 1: Freq ',num2str( ferq_bandpass_filters(freq)) , '-',num2str( ferq_bandpass_filters(freq+1)) , ' Hz' ])
                    subplot(3,2,2*(freq-2)+2)
                    hold off
                    topoplot(abs(Wbp(:,end)), chanlocs);
                    title(['CSP 2: Freq ',num2str( ferq_bandpass_filters(freq)) , '-',num2str( ferq_bandpass_filters(freq+1)) , ' Hz' ])
                    saveas(gcf , ['results\sub_',num2str(i),'_k_',num2str(k),'.fig'])
                    saveas(gcf , ['results\sub_',num2str(i),'_k_',num2str(k),'.png'])
                elseif(k==2&& freq>=2 && freq<=4)
                    figure(2)
                    subplot(3,2,2*(freq-2)+1)
                    hold off
                    topoplot(abs(Wbp(:,1)), chanlocs);
                    title(['CSP 1: Freq ',num2str( ferq_bandpass_filters(freq)) , '-',num2str( ferq_bandpass_filters(freq+1)) , ' Hz' ])
                    subplot(3,2,2*(freq-2)+2)
                    hold off
                    topoplot(abs(Wbp(:,end)), chanlocs);
                    title(['CSP 2: Freq ',num2str( ferq_bandpass_filters(freq)) , '-',num2str( ferq_bandpass_filters(freq+1)) , ' Hz' ])
                    saveas(gcf , ['results\sub_',num2str(i),'_k_',num2str(k),'.fig'])
                    saveas(gcf , ['results\sub_',num2str(i),'_k_',num2str(k),'.png'])
                else
                    close all
                end

                %Extracting Features
                class_lable =1;
                VTemp = csp_extraction(temp_train_one , fs, Wbp , class_lable);
                imagery_classes(k).feature(freq).CSP1 = VTemp;

                class_lable =2;
                VTemp = csp_extraction(temp_train_rest , fs, Wbp , class_lable);
                imagery_classes(k).feature(freq).CSP2 = VTemp;

            end
        end

        save([save_dir,'/csp_ovr_sub',num2str(i),'k',num2str(k_pair),'.mat'],'imagery_classes');

    end

end
