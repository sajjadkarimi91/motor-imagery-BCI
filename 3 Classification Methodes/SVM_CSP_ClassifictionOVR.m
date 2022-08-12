
clc
clear 
close all

NumFeatures = 30;

for i = 1:9
    clc
    i
    load([pwd,'\Features\CSP_OVR',num2str(i),'.mat']);
    
    clear Predicted
    Labels = [];
    Features=[];
    Predicted(7).x=[];
    TrueLabel=[];
    
    for k = 1:3
        
        index = 1:3;
        index(k)=[];
        Labels = [Labels;k*ones(72,1)];
        Features = zeros(36,3*72);
        
        %7 is number of sliding windows
        for kk=1:7
            TestFeatures(kk).x = Features;
        end
        
        if(k==1)
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
            for num_trail = 1:2*72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
        elseif(k==2)
            
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
            for num_trail = 73:2*72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
        elseif(k==3)
            
            for num_trail = 1:144
                for Freq=1:9
                    
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , 144+num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Train;
                    
                    for kk=1:7
                        TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 144+num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Test(kk).x;
                    end
                    
                end
            end
            
                        
        end                
        
        
        for kk=1:7
            FinalTest(k,kk).x =  TestFeatures(kk).x;
        end
        
        FinalFeatures(k).x= Features;
    end % k=1:4
    
    
    %10-fold Cross validation
    CVO = cvpartition(Labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets
        
        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);
        
        %Now 4 binary clssifier must be trained
        for k=1:3
            TrainData = FinalFeatures(k).x(:,trIdx);
            TrainLabel = Labels(trIdx);
            %             TestData = FinalFeatures(k).x(:,teIdx);
            TestLabel = Labels(teIdx);
            
            
            index = 1:3;
            index(k)=[];
            
            TempTrainLabel = TrainLabel;
            for kk = 1:2
                TempTrainLabel( TempTrainLabel==index(kk))=5;
            end
            %Feature Selection using mutual information (MIBIF)
            [IDX, Z] = rankfeatures(TrainData, TempTrainLabel, 'Criterion','entropy');
            
            Selected_Features = IDX(1:NumFeatures);
            
            TrainData = TrainData(Selected_Features,:);
            
            for kk=1:7
                test(k,kk).x = FinalTest(k,kk).x(Selected_Features,teIdx);
            end
            %             test(k).x = TestData(Selected_Features,:);
            
            %h_Kernel = (4/(3*250))^0.2*sqrt(var(TrainData'));
            
            SVMModel = fitcsvm(TrainData', TempTrainLabel,'Standardize',true,'KernelFunction','polynomial',...
    'PolynomialOrder',1,'OutlierFraction',0.02,'BoxConstraint',1);

% [label_1,Score_1] = predict(SVMModel,VecForward') ;

            Model(k).x = SVMModel;
            
        end
        
        
        for kk=1:7
            Finalpost=[];
            for k=1:3
                   
                [label_1,post] = predict(Model(k).x, (test(k,kk).x)') ;
                
                Finalpost(k,:) = post(:,1)';
                
            end
            
            [~,Temp]= max(Finalpost);
            
            Predicted(kk).x = [Predicted(kk).x,Temp];
            
            if(kk==1)
                TrueLabel = [TrueLabel,TestLabel(:)'];
            end
            
        end
        
    end
    
    for kk=1:7
        [kap,se,H,z,p0,SA,R]=kappa(Predicted(kk).x(:),TrueLabel(:));
        
        kapp(i,kk)=kap;
        HH(i , kk)= sum(diag(H))/sum(H(:));
        ConfMatrix(kk).H = H/72;
        
    end
    
end


mean(max(kapp'))
mean(max(HH'))

figure(1)
figure(2)

Time = [0:6];
for i=1:9
    
    figure(1)
    subplot(3,3,i)
    plot(Time , kapp(i,:),'linewidth',2)
    xlim([0,6])
    ylim([0,1])
    grid on
    title(['Subject',num2str(i)])
    
    figure(2)
    subplot(3,3,i)
    plot(Time , HH(i,:),'linewidth',2)
    xlim([0,6])
    ylim([0,1])
    grid on
    title(['Subject',num2str(i)])
    
end




