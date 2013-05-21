clear;
clc;
load('user_label.mat');
load('rel_location.mat');
label = label(1:size(label,1)/5,:);
rel_location = rel_location(1:size(rel_location,1)/5,:);
k = 20;
label = [label,rel_location];
mean_label = mean(label,1);
cov_mat = label - ones(size(label,1),1)*mean_label;
cov_mat = cov_mat'*cov_mat;
[V,D] = eig(cov_mat);
d = diag(D);
d= sort(d,'descend');
num_pc = length(find(d>(d(2)/100)));

pc = V(:,end-num_pc+1:end);
proj_label = label*pc;

[IDX,C] = kmeans(proj_label,k);

for i = 1:k
    group(i).users = find(IDX==i);
end