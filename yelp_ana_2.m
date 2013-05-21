clear
clc
load('user_bus_conn.mat');
load('user_location.mat');
load('user_label.mat');
load('bus_with_label.mat');
load('business_location.mat');
%load('group2.mat');
%load('proj_label.mat');
load('bus_ave_rate.mat');
load('bus_rev_cnt.mat');
load('review_time.mat');

%% adjustable parameters
para1 = 1;
C = 2;%for one-class svm
C1 = 0.90;%for one-class svm, weight for error term
C2 = 1;%weight of score between distance and business rating count
next_round_ratio = 0.1;
sample_rate = 0.90;

%% parameters
first_day = min(review_time);
last_day = max(review_time);
length_day = last_day-first_day+1;
num_bus = size(bus_with_label,1);

%% training and testing samples
sample_num = size(user_bus_conn,1);
train_s = randsample(sample_num,floor(sample_num*sample_rate));
test_s = 1:sample_num;
test_s(train_s) = [];
train_num = length(train_s);
test_num = length(test_s);

user_bus_conn_train = user_bus_conn(train_s,:);
user_bus_conn_test = user_bus_conn(test_s,:);

review_time_train = review_time(train_s,:);
review_time_test = review_time(test_s,:);

[~,train_order] = sort(user_bus_conn_train(:,1));
[~,test_order] = sort(user_bus_conn_test(:,1));
user_bus_conn_train = user_bus_conn_train(train_order,:);
user_bus_conn_test = user_bus_conn_test(test_order,:);
review_time_train_sort = review_time_train(train_order,:);
review_time_test_sort = review_time_test(test_order,:);
%% more dataset and preparation
time_map = time_series_pred(review_time_train_sort,user_bus_conn_train(:,2),num_bus,length_day,first_day);
user_bus_conn_test = [user_bus_conn_test,review_time_test_sort];

user_num = size(location,1);
%test_user_list = ones(1,user_num);
%bus_num = size(bus_ave_rate,1);

clear user_bus_conn;
clear review_time_train_sort;
clear review_time_test_sort;

%% testing
correct = 0;
total = 0;
i_test = 1;   %indicating the next user's position
i_train = 1;
test_bus_num1 = 0;
hit_bus_num1 = 0;
min_train_num = 6;
rank1 = [];
rank2 = [];
rank3 = [];
rank4 = [];
rank5 = [];
rank6 = [];
rank = [];
    
while i_test < test_num
    %% determine which user to test and find all samples related to it in training and testing set
    user = user_bus_conn_test(i_test,1);  %starting from 0
    %if (test_user_list(user+1) == 0)  %it has not been tested
    %all_test_samples = user_bus_conn_test(user_bus_conn_test(:,1)==user,:);
    %all_train_samples = user_bus_conn_train(user_bus_conn_test(:,1)==user,:);
    idx1 = 0;
    while user_bus_conn_test(i_test+idx1+10,1)==user
        idx1 = idx1+10;
    end
    idx1 = idx1+length(find(user_bus_conn_test((i_test+idx1+1):(i_test+idx1+10),1)==user));
    all_test_samples = user_bus_conn_test(i_test:i_test+idx1,:);
    i_test = i_test+idx1+1;
    
    if user == 0
        continue;
    end
    
    idx2 = 0;
    while user_bus_conn_train(i_train+idx2,1)<=user
        if user_bus_conn_train(i_train+idx2,1)<user
            i_train = i_train+1;
        else
            idx2 = idx2+1;
        end
    end
    if user_bus_conn_train(i_train,1)>user
        continue;
    end
    all_train_samples = user_bus_conn_train(i_train:i_train+idx2-1,:);
    i_train = i_train+idx2;
    
    %% delete business out of interest
    %user_label_set = find(label(user+1,:)~=0);
    score3 = label(user+1,:)*bus_with_label';
%     score3 = (score3~=0)+zeros(size(score3));
%     sele_bus = bus_with_label(:,user_label_set);
%     sele_bus = sele_bus*ones(size(sele_bus,2),1);
%    cand_bus = find(score3~=0);   %starting from 1
    cand_bus = 1:length(score3);
    cand_bus_loc = business_location(cand_bus,:);
    cand_bus_time_map = time_map(cand_bus,:);
    
%% location scores for all candidate business   
    train_bus = all_train_samples(:,2);
    train_bus = unique(train_bus);
    train_bus_loc = business_location(train_bus+ones(size(train_bus)),:);
    num_train_bus_loc = size(train_bus_loc,1);
    
    if length(train_bus)>min_train_num
        %construct kernel
        dist_mat = distance_mat(train_bus_loc);
        para2 = mean(mean(dist_mat));
        if (para2~=0)
            k1 = exp(-para1*dist_mat/para2)+0.001*diag(ones(1,size(dist_mat,1)));
        else
            k1 = exp(-para1*dist_mat)+0.001*diag(ones(1,size(dist_mat,1)));
        end

        cons_one = ones(num_train_bus_loc,1);
        cons_zero = zeros(num_train_bus_loc,1);

        cvx_begin
            variable alpha(num_train_bus_loc)
            minimize( alpha'*k1*alpha/2 );
            subject to
                alpha <= cons_one;
                alpha >= cons_zero;
                cons_one'*alpha == num_train_bus_loc*C1;
        cvx_end

        dist_mat2 = distance_mat2(cand_bus_loc, train_bus_loc);
        if para2~=0
            k2 = exp(-para1*dist_mat2/para2);
        else
            k2 = exp(-para1*dist_mat2);
        end
        score1 = k2*alpha;
    end
    
    
 %% assigning score for business popularity according to their accumulative review counts   
    score2 = bus_rev_cnt(cand_bus);%average rate for the business
    if length(train_bus)>min_train_num
        C2 = std(score2)/std(score1)*1;
    end
    C3 = mean(score2)*1.0;
    C4 = mean(score2)*30;
   % C4 = 10;
    %end

    %test accuracy
    test_bus = all_test_samples(:,2);   %test_bus starts from 0
    for idx4 = 1:length(test_bus)
        test_time = all_test_samples(idx4,4)-first_day+1;
        %assign score4 and final score
        score4 = cand_bus_time_map(:,test_time);
        if length(train_bus)>min_train_num
            score = score1*C2+score2+score4*C4;%+score3'*C3;%+score4*C4;
        else
            score = score2+score4*C4;%+score3'*C3;%+score4*C4;
        end
        
        
        %find the top 10% candidate
        [~,bus_rank] = sort(score,'descend');
        bus_num = length(bus_rank);
        next_round_bus = cand_bus(bus_rank(1:round(next_round_ratio*bus_num)));
        % delete and then add all training business to the head of the list
        for idx3 = 1:length(train_bus)
            next_round_bus(next_round_bus==train_bus(idx3)) = [];
        end
        next_round_bus = [train_bus;next_round_bus'];

        test_bus_num1 = test_bus_num1+1;
        temp = find(next_round_bus==(test_bus(idx4)+1));
        if ~isempty(temp)
            hit_bus_num1 = hit_bus_num1+1;
            rank = [rank,temp];
        else
            rank = [rank,0];
        end
        
        
%         %find the top 10% candidate
%         [~,bus_rank] = sort(score1,'descend');
%         bus_num = length(bus_rank);
%         next_round_bus = cand_bus(bus_rank(1:round(next_round_ratio*bus_num)));
%         % delete and then add all training business to the head of the list
%         for idx3 = 1:length(train_bus)
%             next_round_bus(next_round_bus==train_bus(idx3)) = [];
%         end
%         next_round_bus = [train_bus;next_round_bus'];
%         temp = find(next_round_bus==(test_bus(idx4)+1));
%         if ~isempty(temp)
%             rank1 = [rank1,temp];
%         else
%             rank1 = [rank1,0];
%         end
%         
         %find the top 10% candidate
         [~,bus_rank] = sort(score2,'descend');
         bus_num = length(bus_rank);
         next_round_bus = cand_bus(bus_rank(1:round(next_round_ratio*bus_num)));
         % delete and then add all training business to the head of the list
         for idx3 = 1:length(train_bus)
             next_round_bus(next_round_bus==train_bus(idx3)) = [];
         end
         next_round_bus = [train_bus;next_round_bus'];
         temp = find(next_round_bus==(test_bus(idx4)+1));
         if ~isempty(temp)
             rank2 = [rank2,temp];
             %label_prop(cand_user,cand_kernel,num_user,init_score)
         else
             rank2 = [rank2,0];
         end
%         
         %find the top 10% candidate
         [~,bus_rank] = sort(score3,'descend');
         bus_num = length(bus_rank);
         next_round_bus = cand_bus(bus_rank(1:round(next_round_ratio*bus_num)));
         % delete and then add all training business to the head of the list
         for idx3 = 1:length(train_bus)
             next_round_bus(next_round_bus==train_bus(idx3)) = [];
         end
         next_round_bus = [train_bus;next_round_bus'];
         temp = find(next_round_bus==(test_bus(idx4)+1));
         if ~isempty(temp)
             rank3 = [rank3,temp];
         else
             rank3 = [rank3,0];
         end
         
         %find the top 10% candidate
         [~,bus_rank] = sort(score4,'descend');
         bus_num = length(bus_rank);
         next_round_bus = cand_bus(bus_rank(1:round(next_round_ratio*bus_num)));
         % delete and then add all training business to the head of the list
         for idx3 = 1:length(train_bus)
             next_round_bus(next_round_bus==train_bus(idx3)) = [];
         end
         next_round_bus = [train_bus;next_round_bus'];
         temp = find(next_round_bus==(test_bus(idx4)+1));
         if ~isempty(temp)
             rank4 = [rank4,temp];
         else
             rank4 = [rank4,0];
         end
         
         cand2 = find(score3~=0);
         temp = find(cand2==(test_bus(idx4)+1));
         if ~isempty(temp)
             rank6 = [rank6,1];
         else
             rank6 = [rank6,0];
         end
       
    end
end

