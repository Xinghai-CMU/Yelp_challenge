function k2 = dist(mat)
num_ele = size(mat,1);
k2 = zeros(num_ele);

for i = 1:num_ele
    for j = (i+1):num_ele
        k2(i,j) = norm(mat(i,:)-mat(j,:));
        k2(j,i) = k2(i,j);
    end
end

k2 = exp(-k2);