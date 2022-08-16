
clear all
clc

fs = 125;

EEG_Channel = 1:22;

for i = 1:9
    
    i
    
    load([pwd,'\epoched_Data\A0',num2str(i),'T.mat']);
    
    clear Class
    Class(4).Feature = [];
    
    FerqBandpassFilter = 4:4:40;
    
    
    %%     PW CSP
    k=0;
    for k1 = 1:4
        
        for k2 = k1+1:4
            
            k=k+1;
            
            for Freq = 1:9
                
                
                EEG_Filtered = EEG_Filter( EEG_ALL(k1).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain = EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                
                TempTrainOne = EEG_Filtered;
                TempConcat1 = [];
                
                for num_trail = 1 : size( TempTrain , 3)
                    
                    Temp = squeeze( TempTrain (:,:,num_trail));
                    
                    Temp = Temp - repmat( mean(Temp,2),1 , size(Temp,2) );
                    
                    TempConcat1 = [TempConcat1 ,Temp ];
                    
                end
                
                
                
                EEG_Filtered = EEG_Filter( EEG_ALL( k2 ).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain =  EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                
                
                TempTrainAll = EEG_Filtered;
                
                TempConcat2 = [];
                for num_trail = 1 : size(TempTrain , 3)
                    
                    Temp = squeeze( TempTrain (:,:,num_trail));
                    
                    Temp = Temp - repmat( mean(Temp,2),1 , size(Temp,2) );
                    
                    TempConcat2 = [TempConcat2 ,Temp ];
                    
                end
                
                Sigma1 = cov ( TempConcat1' ) ;
                
                Sigma2 = cov ( TempConcat2' ) ;
                
                [Wb,D] = eig(Sigma1 , Sigma1 + Sigma2);
                
                k_pair=2;
                Wbp = Wb(: , [1:k_pair , end-k_pair+1:end]);
                
                %Extracting Features
                
                EEG_Filtered = EEG_Filter( EEG_ALL( 1 ).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain =  EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                TempTrainOne = EEG_Filtered;
                Lable =1;
                VTemp = CSPFeatureExtraction(TempTrainOne , fs, Wbp , Lable);
                Class(k).Feature(Freq).CSP1 = VTemp;
                
                EEG_Filtered = EEG_Filter( EEG_ALL(2 ).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain =  EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                TempTrainOne = EEG_Filtered;
                Lable =2;
                VTemp = CSPFeatureExtraction(TempTrainOne , fs, Wbp , Lable);
                Class(k).Feature(Freq).CSP2 = VTemp;
                
                EEG_Filtered = EEG_Filter( EEG_ALL( 3 ).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain =  EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                TempTrainOne = EEG_Filtered;
                Lable =3;
                VTemp = CSPFeatureExtraction(TempTrainOne , fs, Wbp , Lable);
                Class(k).Feature(Freq).CSP3 = VTemp;
                
                EEG_Filtered = EEG_Filter( EEG_ALL( 4 ).EEG.data(EEG_Channel ,: ,:), fs, FerqBandpassFilter(Freq),FerqBandpassFilter(Freq+1) );
                TempTrain =  EEG_Filtered(: ,round(5*fs):round(7*fs) ,:);
                TempTrainOne = EEG_Filtered;
                Lable =4;
                VTemp = CSPFeatureExtraction(TempTrainOne , fs, Wbp , Lable);
                Class(k).Feature(Freq).CSP4 = VTemp;
                
                
            end
        end
    end
    
    save([pwd,'\epoched_Data\CSP_PPW',num2str(i),'.mat'],'Class');
    
    
    
end
