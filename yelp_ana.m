clear
clc
load('user_bus_conn.mat');
load('user_location.mat');
load('user_label.mat');
load('group2.mat');
load('proj_label.mat');

interesting_business = 0:11536;
num_interesting_business = length(interesting_business);
num_all_user = size(proj_label,1);

rio = 0.4;  %weight for position factor, and (1-rio) is for label correlation
C = 5;
threshold = 0;
lamda = 1;

user_bus_conn_2 = user_bus_conn(1:200000,:);
load('inv_cov.mat'); % saves the inverse of covariance matrix between each labels

stre = zeros(1,size(proj_label,1));
for eee = 1:size(proj_label,1)
    proj_label(eee,:) = proj_label(eee,:)/norm(proj_label(eee,:));
end
clear stre;
% str = diag(stre);
% proj_label = str*proj_label;

for i = 1:num_interesting_business
    index = find(user_bus_conn_2(:,2)==interesting_business(i));
    if (length(index)>5)
        user = user_bus_conn_2(index,1);
        user = unique(user);
        user_index = user+ones(size(user));  %For these users, their index starts from 1.

        set_label = proj_label(user_index,:);
        %set_location = location(user_index,:);
        [k, set_label] = corr(set_label);
        %k1 = mahalanobis_dist(set_label);
        %k2 = dist(set_location);
        %k = k1*(1-rio)+rio*k2;  %need cross validation to learn optimal rio
        
        
        num_user = length(user);
        b = ones(1,num_user);
        c = zeros(1,num_user);
        score = user_bus_conn_2(index,[1,3]);
        init_score = zeros(1,length(user));
        for q = 1:length(user)
            all_u_scores = score(score(:,1)==user(q),2);
            init_score(q) = mean(all_u_scores);
        end
    %     init_score = score((score(:,1)==user),2);

        cvx_begin
            variable alpha(num_user)
            minimize( alpha'*k*alpha/2-b*alpha )
            subject to
                alpha>=c';
                alpha<=C*b';
        cvx_end
        
        cand_user = user_index;
        cand_kernel = k;
        cand_label = set_label;
        %cand_location = set_location;
    
        potent = [];
        for ii = 1:length(cand_user)
            g = zeros(1,20);
            u = cand_user(ii);
            jj = 1;
            while(jj<=20)
                if(~isempty(find(group(jj).users==u)))
                    if(g(jj)==0)
                        g(jj)=1;
                        potent = [potent;group(jj).users];
                    end
                    break;
                end
                jj = jj+1;
            end
        end
        
        for jjj = 1:length(potent)
            j = potent(jjj);
            s_label = proj_label(j,:);
            k_j = s_label*set_label';
%             s_label = label(j,:);
%             s_location = location(j,:);
%             m_d = zeros(1,num_user);
%             for w = 1:num_user/5
%                 m_d(w) = sqrt((s_label-cand_label(w,:))*inv_cov*(s_label-cand_label(w,:))');
%             end
%             
%             k_v1 = exp(-m_d);
%             k_v2 = zeros(1,num_user);
%             for w = 1:num_user
%                 k_v2(w) = norm(cand_location(w,:)-s_location);
%             end
%             k_v2 = exp(-k_v2);
%             k_j = k_v1*(1-rio)+rio*k_v2;

            f = k_j*alpha;
            if (f>threshold)               
                %m_d = zeros(1,length(cand_user)-num_user);
                %other_rel_lab = proj_label((num_user+1):(length(cand_user)),:);
                %k_j_o = s_label*other_rel_lab';
%                 for q = (num_user+1):(length(cand_user))
%                     %m_d(q-num_user) = sqrt((s_label-cand_label(q,:))*inv_cov*(s_label-cand_label(q,:))');
%                 end
%                 k_v1 = exp(-m_d);
%                 k_v2 = zeros(1,length(cand_user)-num_user);
%                 for w = (num_user+1):(length(cand_user))
%                     k_v2(w-num_user) = norm(cand_location(w,:)-s_location);
%                 end
%                 k_v2 = exp(-k_v2);
%                 k_j_o = k_v1*(1-rio)+rio*k_v2;
                 %k_j = [k_j,k_j_o];
                
                %cand_kernel = [cand_kernel;k_j];
                %cand_kernel = [cand_kernel,[k_j,1]'];
                
                cand_user = [cand_user;j];
                %cand_label = [cand_label;s_label];
                %cand_location = [cand_location;s_location];
            end
        end
        target(i).business = interesting_business(i);
%         if (length(cand_user)>100)
%             sele_users = label_prop(cand_user,cand_kernel,num_user,init_score);
%             target(i).users = sele_users - ones(size(sele_users));
%         else
            target(i).users = cand_user - ones(size(cand_user));
        end
        
%     end
end

total = 0;
correct = 0;
test_conn = user_bus_conn(200001:end,:);
%testing
disp('testing...../n');
for e = 1:size(test_conn,1)
    if((test_conn(e,3)))
        test_bus_num = test_conn(e,2);
        index = find(test_conn(:,2)==test_bus_num);
        if (index>5)
            total = total+1;
            search_index = 1;
            while(search_index<(num_interesting_business))
                if(target(search_index).business == test_bus_num)
                    if(~isempty(find(target(search_index).users==test_conn(e,1))))
                        correct = correct+1;
                    end
                    break;
                end
            end
        end
    end
end