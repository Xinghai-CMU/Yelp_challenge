function [k] = mahalanobis_dist(set_label)
load('inv_cov.mat');
num_item = size(set_label,1);
m_dist = zeros(num_item);
for i = 1:num_item
    for j = (i+1):num_item
        m_dist(i,j) = sqrt((set_label(i,:)-set_label(j,:))*inv_cov*(set_label(i,:)-set_label(j,:))');
        m_dist(j,i) = m_dist(i,j);
    end
    m_dist(i,i) = 0;
end
k = exp(-m_dist);
