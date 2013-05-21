require 'csv'

if File.exists?('business_num.csv')
	File.delete('business_num.csv')
end

CSV.open('business_num.csv', "w") do |csv0|
	f = CSV.open('/Users/Xinghai/Documents/cmu_2013_spring/Yelp/business.csv', "r")
	while ((s=f.gets)!=nil)
		label_num = []
		parsed_json = JSON.parse(s)
		csv0<<[parsed_json["business_id"],parsed_json["open"],parsed_json["categories"],parsed_json["state"],parsed_json["city"],parsed_json["longitude"],parsed_json["latitude"],parsed_json["stars"],parsed_json["review_count"]]	
		category = parsed_json["categories"]
		category.each { |e|
			if ((n = labels.index(e))==nil)
				labels<<e
				label_num << labels.index(e)
			else
				label_num << n
			end
		}
		# business_with_label[parsed_json["business_id"]] = label_num 
	end	
end