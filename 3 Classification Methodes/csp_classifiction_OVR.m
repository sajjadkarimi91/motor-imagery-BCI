


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
                csp_features((f-1)*2*k_pairs_ML+1:f*2*k_pairs_ML , num_trail) = imagery_classes(k).feature(f).CSP(num_trail).train;

                for t=1:7
                    test_features(t).x((f-1)*2*k_pairs_ML+1:f*2*k_pairs_ML , num_trail) = imagery_classes(k).feature(f).CSP(num_trail).test{t};
                end

            end
        end


        for t=1:7
            sets_test_features(k,t).x =  test_features(t).x;
        end
        set_train_features(k).x= csp_features;

    end % k


    %10-fold Cross validation
    CVO = cvpartition(class_labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets

        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);

        %Now binary clssifier must be trained
        for k=1:max_class
            train_features = set_train_features(k).x(:,trIdx);
            train_label = class_labels(trIdx);
            %             TestData = FinalFeatures(k).x(:,teIdx);
            test_label = class_labels(teIdx);


            index = 1:max_class;
            index(k)=[];

            binary_train_label = train_label;
            for t = 1:2
                binary_train_label( binary_train_label==index(t))= max_class+1;
            end
            %Feature Selection using mutual information (MIBIF)
            [IDX, Z] = rankfeatures(train_features, binary_train_label, 'Criterion','entropy');

            selected_features = IDX(1:max_features);

            train_features = train_features(selected_features,:);

            for t=1:7
                test_features_selected(k,t).x = sets_test_features(k,t).x(selected_features,teIdx);
            end

            %h_Kernel = (4/(3*250))^0.2*sqrt(var(TrainData'));
            if strcmp(classfier_type,'nb')
                trained_models(k).x = fitcnb(train_features', binary_train_label,'Distribution','kernel');
            else
                trained_models(k).x = fitcsvm(train_features', binary_train_label,'Standardize',true,'KernelFunction','polynomial',...
                    'PolynomialOrder',poly_order,'OutlierFraction',0.02,'BoxConstraint',1);
            end



        end


        for t=1:7
            all_post_prob=[];
            for k=1:3
                [~,post_prob] = predict(trained_models(k).x, (test_features_selected(k,t).x)') ;
                all_post_prob(k,:) = post_prob(:,1)';
            end

            [~,Temp]= max(all_post_prob);
            predicted_labels(t).x = [predicted_labels(t).x,Temp];

            if(t==1)
                true_labels = [true_labels,test_label(:)'];
            end

        end

    end

    for t=1:7
        [kap,se,H,z,p0,SA,R]=kappa(predicted_labels(t).x(:),true_labels(:));
        kapp(i,t)=kap;
        HH(i , t)= sum(diag(H))/sum(H(:));
        ConfMatrix(i,t).H = H./sum(H);
    end

end



time_plot = [-1:5];
for i= num_subjects_ML

    disp(['subject: ',num2str(i)])
    disp(ConfMatrix(i,6).H)
   
    figure
    plot(time_plot , HH(i,:),'o-','linewidth',2)
    xlim([0,max(time_plot)])
    ylim([0,1])
    grid on
    ylabel('ACC')
    xlabel('time (sec)')
    title(['Subject',num2str(i)])

end




