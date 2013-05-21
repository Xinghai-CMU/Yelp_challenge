function sele_user = label_prop(cand_user,cand_kernel,num_user,init_score)
num_cand_users = length(cand_user);
dist = [ones(1,num_user),zeros(1,num_cand_users-num_user)];
threshold = 0.8;
init_score = (init_score-ones(size(init_score)))/4;

for i = 1:size(cand_kernel,1)
    cand_kernel(:,i) = cand_kernel(:,i)/sum(cand_kernel(:,i));
end

N = 500;
max_user_num = 30;
i = 1;
while (i<=N)
    dist = dist*cand_kernel;
    dist(1,1:num_user) = init_score';
    sele_user = cand_user(dist>threshold);
    if (length(sele_user)>max_user_num)
        i = N+1;
    end
end
