function [dist_mat] = distance_mat(mat)
size1 = size(mat,1);
size2 = size(mat,2);
mat1 = mat*mat';
mat2 = diag(mat1)*ones(1,size1);
dist_mat = mat2+mat2'-2*mat1;