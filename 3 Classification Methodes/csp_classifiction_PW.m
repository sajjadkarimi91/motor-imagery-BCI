

for i = num_subjects_ML
    clc
    i
    load([save_dir,'/csp_features/csp_pw_sub',num2str(i),'k',num2str(k_pairs_ML),'.mat'],'imagery_classes');

    clear predicted_labels
    csp_features=[];
    predicted_labels(7).x=[];
    true_labels=[];

    for k = 1:(max_class*(max_class-1)/2)

        num_epochs = length(imagery_classes(k).feature(1).CSP);
        num_filters = length(imagery_classes(k).feature);
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


    end % k=1:6



    ind_classes = [];
    for k1 = 1:max_class
        for k2 = k1+1:max_class
            ind_classes =[ind_classes,[k1;k2]];
        end
    end

    %10-fold Cross validation
    CVO = cvpartition(class_labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets

        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);


        %Now binary clssifier must be trained
        for k=1:(max_class*(max_class-1)/2)
            train_features = set_train_features(k).x(:,trIdx);
            train_label = class_labels(trIdx);
            %             TestData = FinalFeatures(k).x(:,teIdx);
            test_label = class_labels(teIdx);

            trIdx1 = train_label == ind_classes(1,k);
            trIdx2 = train_label == ind_classes(2,k);

            binary_train_label = train_label(trIdx1|trIdx2);
            train_features = train_features(:,trIdx1|trIdx2);

            %Feature Selection using mutual information (MIBIF)
            [IDX, Z] = rankfeatures(train_features, binary_train_label, 'Criterion','entropy');

            selected_features = IDX(1:max_features);
            train_features = train_features(selected_features,:);

            for t=1:7
                test_features_selected(k,t).x = sets_test_features(k,t).x(selected_features,teIdx);
            end


            if strcmp(classfier_type,'nb')
                trained_models(k).x = fitcnb(train_features', binary_train_label,'Distribution','kernel');
            else
                trained_models(k).x = fitcsvm(train_features', binary_train_label,'Standardize',true,'KernelFunction','polynomial',...
                    'PolynomialOrder',poly_order,'OutlierFraction',0.02,'BoxConstraint',1);
            end


        end


        for t=1:7

            all_post_prob = zeros(max_class,sum(teIdx));
            for k=1:(max_class*(max_class-1)/2)
                [~,post_prob] = predict(trained_models(k).x, (test_features_selected(k,t).x)') ;
                k1 = ind_classes(1,k);
                k2 = ind_classes(2,k);
                all_post_prob(k1,:) =  all_post_prob(k1,:) + post_prob(:,1)';
                all_post_prob(k2,:) =  all_post_prob(k2,:) + post_prob(:,2)';
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
        accuracy(i , t)= sum(diag(H))/sum(H(:));
        conf_matrix(i,t).H = H./sum(H);
    end


end


time_plot = -3:3;
for i= num_subjects_ML

    disp(['subject: ',num2str(i)])
    disp(conf_matrix(i,6).H)

    figure
    plot(time_plot , accuracy(i,:),'o-','linewidth',2)
    %xlim([0,max(time_plot)])
    ylim([0,1])
    grid on
    ylabel('ACC')
    xlabel('time (sec)')
    title(['Subject',num2str(i)])

end

figure
plot(time_plot , mean(accuracy,1),'o-','linewidth',2)
%xlim([0,max(time_plot)])
ylim([0,1])
grid on
ylabel('ACC')
xlabel('time (sec)')
title('Avg')

