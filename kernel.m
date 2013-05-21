lamda = 1;
load('proj_label.mat');
d1 = label*label';
d2 = ones(length(user),1)*diag(d1)';
d = d2+d2'-2*d1;
k = exp(-lamda*d);