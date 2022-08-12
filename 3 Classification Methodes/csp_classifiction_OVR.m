


for i = num_subjects_ML
    clc
    i
    load([save_dir,'/csp_features/csp_ovr_sub',num2str(i),'k',num2str(k_pairs_ML),'.mat'],'imagery_classes');


    clear predicted_labels
    class_labels = [];
    csp_features=[];
    predicted_labels(7).x=[];
    true_labels=[];

    for k = 1:max_class

        num_epochs = length(imagery_classes(k).feature(1).CSP);
        num_filters = length(imagery_classes(k).feature);
        kclass_sample = length(imagery_classes(k).feature(1).CSP());
        index = 1:max_class;
        index(k)=[];
        class_labels = zeros(num_epochs,1);
        csp_features = zeros(num_filters*2*k_pairs_ML,num_epochs);

        %7 is number of sliding windows
        for t=1:7
            test_features(t).x = csp_features;
        end

        for num_trail = 1:num_epochs
            class_labels(num_trail) = imagery_classes(k).feature(1).CSP(num_trail).lable;
            for f=1:num_filters
                csp_features((f-1)*2*k_pairs_ML+1:f*2*k_pairs_ML , num_trail) = imagery_classes(k).feature(f).CSP(num_trail).Train;

                for t=1:7
                    test_features(t).x((f-1)*2*k_pairs_ML+1:f*2*k_pairs_ML , num_trail) = imagery_classes(k).feature(f).CSP(num_trail).Test{t};
                end

            end
        end


        for t=1:7
            final_test(k,t).x =  test_features(t).x;
        end
        final_features(k).x= csp_features;

    end % k


    %10-fold Cross validation
    CVO = cvpartition(class_labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets

        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);

        %Now binary clssifier must be trained
        for k=1:3
            TrainData = final_features(k).x(:,trIdx);
            TrainLabel = class_labels(trIdx);
            %             TestData = FinalFeatures(k).x(:,teIdx);
            TestLabel = class_labels(teIdx);


            index = 1:3;
            index(k)=[];

            TempTrainLabel = TrainLabel;
            for t = 1:2
                TempTrainLabel( TempTrainLabel==index(t))=5;
            end
            %Feature Selection using mutual information (MIBIF)
            [IDX, Z] = rankfeatures(TrainData, TempTrainLabel, 'Criterion','entropy');

            Selected_Features = IDX(1:max_features);

            TrainData = TrainData(Selected_Features,:);

            for t=1:7
                test(k,t).x = final_test(k,t).x(Selected_Features,teIdx);
            end
            %             test(k).x = TestData(Selected_Features,:);

            %h_Kernel = (4/(3*250))^0.2*sqrt(var(TrainData'));

            SVMModel = fitcsvm(TrainData', TempTrainLabel,'Standardize',true,'KernelFunction','polynomial',...
                'PolynomialOrder',1,'OutlierFraction',0.02,'BoxConstraint',1);

            % [label_1,Score_1] = predict(SVMModel,VecForward') ;

            Model(k).x = SVMModel;

        end


        for t=1:7
            Finalpost=[];
            for k=1:3
                [label_1,post] = predict(Model(k).x, (test(k,t).x)') ;
                Finalpost(k,:) = post(:,1)';
            end

            [~,Temp]= max(Finalpost);
            predicted_labels(t).x = [predicted_labels(t).x,Temp];

            if(t==1)
                true_labels = [true_labels,TestLabel(:)'];
            end

        end

    end

    for t=1:7
        [kap,se,H,z,p0,SA,R]=kappa(predicted_labels(t).x(:),true_labels(:));
        kapp(i,t)=kap;
        HH(i , t)= sum(diag(H))/sum(H(:));
        ConfMatrix(t).H = H/72;
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




