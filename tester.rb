names=['a','b','c','d','e','f']
temp=['m','f']
N=50
MAXTIMES = 5
LATEST_TIME = 9
SECTION_LEADERS = 5
for i in 0...N
	str = ""
	isLeader = rand(10)
	if i >= 0 and i < SECTION_LEADERS
		str += "*"
	end
	str += names[rand(names.size)]+"#{i},"

	gender = rand(2)
	str += temp[gender]+","

	times = []
	numTimes = 3+rand(MAXTIMES)
	for j in 0...numTimes

		num = (8+rand(LATEST_TIME))
		while times.include? num
			num = (8+rand(LATEST_TIME))
		end
		times.push(num)


		str += (num).to_s+","
		if j == numTimes/2-1
			str += ";"
		end
	end
	# str += ";"
	print "#{str}\n"
end

#8am - 19:00