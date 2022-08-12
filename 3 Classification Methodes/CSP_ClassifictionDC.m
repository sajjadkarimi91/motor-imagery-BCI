
clc
clear all
close all

NumFeatures = 25;

for i = 1:9
    clc
    i
    load([pwd,'\Features\CSP_DC',num2str(i),'.mat']);
    
    clear Predicted
    Labels = [1*ones(72,1);2*ones(72,1);3*ones(72,1);4*ones(72,1)];
    
    Features=[];
    Predicted(7).x=[];
    TrueLabel=[];
    
    for k = 1:3
        
        Features1 = zeros(36,288);
        
        %7 is number of sliding windows
        for kk=1:7
            TestFeatures(kk).x = Features1;
        end
        
        if((k==1))
            PWLabels1 = [1*ones(72,1);2*ones(3*72,1)];
            Features = zeros(36,4*72);
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 2*72+num_trail) = Class(k).Feature(Freq).CSP3(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 3*72+num_trail) = Class(k).Feature(Freq).CSP4(num_trail).Train;
                end
            end
        end
        
        if((k==2))
            PWLabels2 = [1*ones(72,1);2*ones(2*72,1)];
            Features = zeros(36,3*72);
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP3(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 2*72+num_trail) = Class(k).Feature(Freq).CSP4(num_trail).Train;
                end
            end
        end
        
        if((k==3))
            PWLabels3 = [1*ones(72,1);2*ones(72,1)];
            Features = zeros(36,2*72);
            for num_trail = 1:72
                for Freq=1:9
                    Features((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Train;
                    Features((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP4(num_trail).Train;
                end
            end
        end
        
        
        for num_trail = 1:72
            for Freq=1:9
                
                for kk=1:7
                    TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , num_trail) = Class(k).Feature(Freq).CSP1(num_trail).Test(kk).x;
                end
                
            end
        end
        
        for num_trail = 1:72
            for Freq=1:9
                
                for kk=1:7
                    TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 72+num_trail) = Class(k).Feature(Freq).CSP2(num_trail).Test(kk).x;
                end
                
            end
        end
        
        for num_trail = 1:72
            for Freq=1:9
                
                for kk=1:7
                    TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 2*72+num_trail) = Class(k).Feature(Freq).CSP3(num_trail).Test(kk).x;
                end
                
            end
        end
        
        for num_trail = 1:72
            for Freq=1:9
                
                for kk=1:7
                    TestFeatures(kk).x((Freq-1)*4+1:Freq*4 , 3*72+num_trail) = Class(k).Feature(Freq).CSP4(num_trail).Test(kk).x;
                end
                
            end
        end
        
        for kk=1:7
            FinalTest(k,kk).x =  TestFeatures(kk).x;
        end
        
        FinalFeatures(k).x= Features;
    end % k=1:6
    
    
    %10-fold Cross validation
    
    CVO = cvpartition(Labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets
        Log2Index = 1:length(Labels);
        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);
        Log2Index = Log2Index(trIdx);
        %Now 6 binary clssifier must be trained
        for k=1:3
            if((k==1))
                trIdx1 = Log2Index;
                TrainLabel = PWLabels1(trIdx1);
            end
            if((k==2))
                
                trIdx1 = Log2Index((Log2Index>1*72))-1*72;
                TrainLabel = PWLabels2(trIdx1 );
            end
            if((k==3))
                
                trIdx1 = Log2Index((Log2Index>2*72))-2*72;
                TrainLabel = PWLabels3(trIdx1 );
            end
            
            
            TrainData = FinalFeatures(k).x(:,[trIdx1 ]);
            
            
            TestLabel = Labels(teIdx);
            
            
            
            TempTrainLabel = TrainLabel;
            
            %Feature Selection using mutual information (MIBIF)
            [IDX, Z] = rankfeatures(TrainData, TempTrainLabel, 'Criterion','entropy');
            
            Selected_Features = IDX(1:NumFeatures);
            
            TrainData = TrainData(Selected_Features,:);
            
            for kk=1:7
                test(k,kk).x = FinalTest(k,kk).x(Selected_Features,teIdx);
            end
            %             test(k).x = TestData(Selected_Features,:);
            
            %h_Kernel = (4/(3*250))^0.2*sqrt(var(TrainData'));
            NBModel = fitNaiveBayes(TrainData', TempTrainLabel ...
                ,'Distribution','kernel');%,'KSWidth',h_Kernel);
            Model(k).x = NBModel;
            
        end
        
        
        for kk=1:7
            Finalpost=[];
     
             Temp = zeros( 1 , size(test(k,kk).x,2) );
             
            for k=1:3
                
                post = posterior(Model(k).x, (test(k,kk).x)');
                Finalpost(k,:) = post(:,1)';
                
               
                if(k==1)
                    Temp( Finalpost(k,:) > 0.5 )=1;
                    
                elseif(k==2)
                    
                    Temp( (Temp==0)&(Finalpost(k,:) > 0.5) )=2;
                    
                elseif(k==3)
                    
                    Temp( (Temp==0)&(Finalpost(k,:) > 0.5) )=3;
                    Temp( (Temp==0)&(Finalpost(k,:) <= 0.5) )=4;
                    
                end
                
            end
            

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

Time = [-3:3];
for i=1:9
    
    figure(1)
    subplot(3,3,i)
    plot(Time , kapp(i,:),'linewidth',2)
    xlim([-3,3])
    ylim([0,1])
    grid on
    title(['Subject',num2str(i)])
    
    figure(2)
    subplot(3,3,i)
    plot(Time , HH(i,:),'linewidth',2)
    xlim([-3,3])
    ylim([0,1])
    grid on
    title(['Subject',num2str(i)])
    
end


