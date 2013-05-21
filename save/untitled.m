load('user_business.mat');
alpha = 0.5;
A = user_business;
B = A*A'*alpha;
inner_user = funm(B, @exp);
A = A';
B = A*A';
inner_business = funm(B, @exp);