function time_map = time_series_pred(review_time_train_sort,bus,num_bus,length_day,first_day)
time_map = zeros(num_bus,length_day);
review_time_train_sort = review_time_train_sort - (first_day-1)*ones(size(review_time_train_sort));
for i = 1:length(review_time_train_sort)
    time_map(bus(i)+1,review_time_train_sort(i)) = time_map(bus(i)+1,review_time_train_sort(i))+1;
end
time_gap =45;
filter = [-time_gap:time_gap];
filter = exp(-abs(filter)/15);
for i = 1:bus
    temp = conv(time_map(i,:),filter);
    time_map(i,:) = temp([time_gap+1:end-time_gap]);
end
%normalization
total = sum(time_map,1);
time_map = time_map./(ones(num_bus,1)*total);

