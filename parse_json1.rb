require 'rubygems'
require "json"
require "csv"
require 'date'

File_name = ['yelp_academic_dataset_business.json','yelp_academic_dataset_checkin.json','yelp_academic_dataset_review.json','yelp_academic_dataset_user.json']
# if File.exists?('business.csv')
# 	File.delete('business.csv')
# end

# if File.exists?('checkin.csv')
# 	File.delete('checkin.csv')
# end

# if File.exists?('review.csv')
# 	File.delete('review.csv')
# end

# if File.exists?('user.csv')
# 	File.delete('user.csv')
# end

# if File.exists?('user_location.csv')
# 	File.delete('user_location.csv')
# end

# if File.exists?('user_label.csv')
# 	File.delete('user_label.csv')
# end

if File.exists?('business_with_label.csv')
	File.delete('business_with_label.csv')
end

labels = [];
business_with_label = Hash.new(Array.new)
business_with_location = Hash.new(Array.new)
num_business = 0;
business_num = Hash.new


CSV.open('business_with_label.csv',"w") do |csv9|

	f = File.open(File_name[0])
	while ((s=f.gets)!=nil)
		business_label = Array.new(508){0}
		# label_num = []
		parsed_json = JSON.parse(s)
		category = parsed_json["categories"]
		arr = [];
		category.each { |e|
			if ((n = labels.index(e))==nil)
				labels<<e
				business_label[labels.index(e)]=1
			else
				business_label[n]=1
			end
		}
		# print arr
		# business_with_label[parsed_json["business_id"]] << label_num 
		# if ((b = business_num[parsed_json["business_id"]])==nil)
		# 	business_num[parsed_json["business_id"]] = num_business
		# 	num_business = num_business+1
		# end
		#business_with_label[business_num[parsed_json["business_id"]]] = arr
		#business_with_location[business_num[parsed_json["business_id"]]] = [parsed_json["longitude"].to_f,parsed_json["latitude"].to_f]
		csv9<<business_label
	end	
end

# puts ('business number is '+ (num_business).to_s)
# puts ('label number is ' + (labels).length.to_s)
# puts (business_with_label)

# labels = business_with_label.keys

# CSV.open('checkin.csv') do |csv1|

# end
# num_labels = labels.length


# user_num = Hash.new
# num_user = 0

# CSV.open('user.csv', "w") do |csv3|
# 	f = File.open(File_name[3])
# 	while ((s=f.gets)!=nil)
# 		parsed_json = JSON.parse(s)
# 		csv3 << [parsed_json["user_id"],parsed_json["average_stars"],parsed_json["review_count"],parsed_json["votes"]["funny"],parsed_json["votes"]["useful"],parsed_json["votes"]["cool"]]
# 		# user_interest[parsed_json["user_id"]] = Array.new(num_labels) {0}
# 		if ((u = user_num[parsed_json["user_id"]])==nil)
# 			user_num[parsed_json["user_id"]] = num_user
# 			num_user = num_user+1
# 		end
# 	end	
# end

# puts ('user number is '+ (num_user).to_s)

# cour = 0
# print(".")
# review = Array.new(num_user) { Array.new ((labels).length){0}}
# print(".")
# location = Array.new(num_user){[0,0,0]}  #count, longitude, latitude
# print(".")
# CSV.open('review.csv', "w") do |csv2|
# 	f = File.open(File_name[2])
# 	while ((s=f.gets)!=nil)
# 		parsed_json = JSON.parse(s)
# 		date_ = Date.parse(parsed_json["date"])
# 		date = date_.jd
# 		# interest = Array.new(num_labels) { 0 }
# 		# label_nums = business_with_label[parsed_json["business_id"]]
# 		# label_nums.each { |e| user_interest[parsed_json["user_id"]][e] += 1}
# 		csv2 << [user_num[parsed_json["user_id"]],business_num[parsed_json["business_id"]],date,parsed_json["stars"],parsed_json["votes"]["funny"],parsed_json["votes"]["useful"],parsed_json["votes"]["cool"]]		
# 		cur_business_num = business_num[parsed_json["business_id"]]
# 		cur_arr = business_with_label[cur_business_num]
# 		cur_user_num = user_num[parsed_json["user_id"]]
		
# 		# user_business_connection[cur_user_num][cur_business_num] += 1
# 		# cur_bus_num = business_num[parsed_json["business_id"]]
# 		if (cur_user_num)
# 			location[cur_user_num][0] += 1
# 			location[cur_user_num][1] += business_with_location[cur_business_num][0]
# 			location[cur_user_num][2] += business_with_location[cur_business_num][1]
# 			cur_arr.each { |cur_label| 
# 				review[cur_user_num][cur_label]  += 1
# 			}
# 		end
# 		# print(".")
# 		# cour += 1
# 	end		
# end

# print("*")

# # puts ("number of review is "+ cour.to_s)
# # interest = Array.new((labels).length, 0)

# CSV.open('user_label.csv', "w") do |csv4|
# 	for i in 0..num_user-1
# 		# user_interest[i].each { |l|
# 		# 	interest[l] = interest[l]+1
# 		# }
# 		csv4 << review[i]
# 		# print('-')
# 	end
# end
# labels.clear
# business_with_label.clear
# business_num.clear
# user_num.clear
# review.clear

# print("*")
# CSV.open('user_location.csv', "w") do |csv5|
# 	for i in 0..num_user-1
# 		# user_interest[i].each { |l|
# 		# 	interest[l] = interest[l]+1
# 		# }
# 		if location[i][0] != 0
# 			csv5 << [location[i][1]/location[i][0],location[i][2]/location[i][0]]
# 		else
# 			csv5 << [0,0]
# 		end
# 		# print('-')
# 	end
# end


