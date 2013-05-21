function [dist_mat] = distance_mat2(mat1, mat2)
m1 = mat1*mat2';
v1 = sum(mat1.*mat1,2);
v2 = sum(mat2.*mat2,2);
m2 = v1*ones(1,length(v2))+ones(length(v1),1)*v2';
dist_mat = m2-2*m1;