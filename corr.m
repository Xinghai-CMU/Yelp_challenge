function [k,mat] = corr(mat)
num_ele = size(mat,1);

for i = 1:num_ele
    mod = norm(mat(i,:));
    if (mod~=0)
        mat(i,:) = mat(i,:)/mod;
    end
end

k = mat*mat';