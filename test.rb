
class Constraints
	@@GOOD_RATIO = true
	@@FILLED_SECTIONS = true
	@@GENDER = true
	attr_accessor :constraints
	@@constraints = Hash.new()

	def hasKey(a)
		return @@constraints.has_key?(a)
	end

	def set(gender_on,goodratio_on)
		@@GENDER =  gender_on ? true : false;
		@@GOOD_RATIO =  goodratio_on ? true : false;
		print "#{gender_on},#{goodratio_on}\n"
		print "#{@@GENDER},#{@@GOOD_RATIO}\n"
	end

	def includes(a,b)
		return @@constraints[a].include?(b)
	end

	def printConstraints
		print @@constraints
	end

	def put(key,value)
		@@constraints[key]=value
	end

	def involves(var)
		keys = []
		@@constraints.each do |key,value|
			data = key.split(",")
			if data[0].to_i == var or data[1].to_i == var
				keys.push(key)
			end
		end
		return keys
	end

	def conflictingVar(assignment)
		@@constraints.each do |key,value|
			d1 = key.split(",")
			d2 = [d1[0].to_i,d1[1].to_i]
			if not @@constraints[key].include?("#{assignment[d2[0]]},#{assignment[d2[1]]}")
				return rand(2) == 0 ? d2[0] : d2[1]; 
			end
		end
		return -1
	end

	def isSatisfied(assignment,sectionLeaders,students,ratio,min,max)
		# print "#{assignment}\n"
		# print @@constraints
		# @@constraints.each {|key, value| }
		@@constraints.each do |key,value|  
			data = key.split(",")
			# print "#{data}\n"
			str = "#{assignment[data[0].to_i]},#{assignment[data[1].to_i]}"
			if assignment[data[0].to_i] != -1 and assignment[data[1].to_i] != -1
				if not @@constraints[key].include? str
					return false
				end
			end
		end
		# print @@constraints
		b2 = @@GOOD_RATIO == true ? isGoodRatio(assignment,sectionLeaders,students,ratio,min,max) : true;
		b3 = @@FILLED_SECTIONS == true ? isFilledSections(assignment,sectionLeaders,students) : true;
		b4 = @@GENDER == true ? isGenderBalanced(assignment,sectionLeaders,students,ratio) : true;
		# puts "#{b2} #{b3} #{b4}"
		return (b2 and b3 and b4)
	end

	def isGoodRatio(assignment,sectionLeaders,students,ratio,min,max)
		n = students.size
		k = sectionLeaders.size
		badRatio = false;
		# print "RATIO\n"
		for timeSlot in ratio
			# print "#{timeSlot}\n"
			if timeSlot[1] == 1 and (timeSlot[0] > max) or (timeSlot[0] < min)
				badRatio = true
				break
			end
		end
		if badRatio and complete(assignment)
			# print "-------------\n"
			return false
		end
		# print "-------------\n"
		return true
	end

	def complete(assignment)
		for i in assignment
			if i == -1
				return false
			end
		end
		return true
	end

	def isGenderBalanced(assignment,sectionLeaders,students,ratio)
		# if(timeSlot[2] == 0 && timeSlot[3] > 0 || timeSlot[2] > 0 && timeSlot[3] == 0 || 
		# 		   (timeSlot[2] >= (n/(2*k))-1 && timeSlot[3] >= (n/(2*k))-1) || 
		# 		   !complete(assignment))


		for timeSlot in ratio
			# print "#{timeSlot}\n"
			n = timeSlot[0]
			k = timeSlot[1]
			badRatio = true
			if (2*k) > 0
				if (timeSlot[2] == 0 and timeSlot[3] > 0) or 
				   (timeSlot[2] > 0 and timeSlot[3] == 0) or 
				   (timeSlot[2] >= (n/(2*k))-1 and timeSlot[3] >= (n/(2*k))-1) or 
				   not complete(assignment)
					badRatio = false
				end
				if badRatio
					# print "---------\n"
					return false
				end
			end
		end
		# print "---------\n"
		return true
	end

	def isFilledSections(assignment,sectionLeaders,students)
		# print "#{students}\n#{sectionLeaders}\n"
		for i in students
			misplacedStudent = true
			for j in sectionLeaders
				# print "#{i},#{j}\n"
				if assignment[j] == assignment[i] || assignment[i] == -1
					misplacedStudent = false
				end
			end
			if misplacedStudent
				return false
			end
		end
		return true;
	end
end
class Setup
	def parse(filename,filename2,gender_on,good_ratio_on,min,max)
		customRestrictions = nil
		# print filename2
		if filename2
			customRestrictions = []
			temp = File.open("uploads/#{filename2}","r").read.split()
			# print temp
			for i in temp
				customRestrictions.push(i.split(","))
			end
			# print "#{customRestrictions}\n"
		end

		lines = File.open("uploads/#{filename}","r").read.split()
		maybeTimes = []
		sureTimes = []
		vars = []
		genders = []
		for i in lines
			dataSplit = i.split(";")
			# print "#{dataSplit}\n"
			if dataSplit.size == 2
				maybes = dataSplit[1].split(",")
			else
				maybes = []
			end
			# print "#{maybes}\n"
			temp = []
			for j in 0...maybes.size
				temp.push(maybes[j].to_i)
			end
			# print "#{temp}\n"
			maybeTimes.push(temp)
			data = dataSplit[0].split(",")
			vars.push(data[0])
			genders.push(data[1])
			temp = []
			for j in 2...data.size
				temp.push(data[j].to_i)
			end
			sureTimes.push(temp)
			# print "#{temp}\n"
		end
		
		convert(maybeTimes,sureTimes,vars,genders,customRestrictions,gender_on,good_ratio_on,min,max)
	end

	def convert(maybeTimes,sureTimes,vars,genders,customRestrictions,gender_on,good_ratio_on,min,max)
		print "#{maybeTimes}\n#{sureTimes}\n"
		convertedVars = []
		sectionLeaders = []
		students = []
		# print vars
		for i in 0...vars.size
			convertedVars.push(i)
			if vars[i][0] == '*'
				sectionLeaders.push(i)
			else
				students.push(i)
			end
		end

		n = sectionLeaders.size
		k = students.size
		useMax = (n/k)+1
		useMin = (n/k)-1
		if min.to_i > 0 and min.to_i < vars.size
			useMin = min.to_i
		end
		if max.to_i > 0 and max.to_i < var.size
			useMax = max.to_i
		end

		intToTime = []
		timeToInt = {}
		index = 0
		for i in maybeTimes
			for j in i
				if not intToTime.include? j
					intToTime.push(j)
					timeToInt[j] = index
					index += 1
				end
			end
		end
		for i in sureTimes
			for j in i
				if not intToTime.include? j
					intToTime.push(j)
					timeToInt[j] = index
					index += 1
				end
			end
		end

		# print "#{vars}\n#{timeToInt}\n"
		convertedMaybeTimes = []
		convertedSureTimes = []
		convertedTotalDomains = []

		for i in maybeTimes
			temp = []
			temp2 = []
			for j in i
				temp.push(timeToInt[j])
				temp2.push(timeToInt[j])
			end
			convertedMaybeTimes.push(temp)
			convertedTotalDomains.push(temp2)
		end
		totalIndex = 0
		for i in sureTimes
			temp = []
			for j in i
				temp.push(timeToInt[j])
				convertedTotalDomains[totalIndex].push(timeToInt[j])
			end
			totalIndex+=1
			convertedSureTimes.push(temp)
		end

		# print "#{convertedMaybeTimes}\n"
		# print "#{convertedSureTimes}\n"
		
		index = 0
		# print "#{convertedTotalDomains}\n"
		constraints = Constraints.new
		constraints.set(gender_on,good_ratio_on)

		for i in 0...sectionLeaders.size
			for j in i+1...sectionLeaders.size
				# print "BOOP #{convertedTotalDomains[i]},#{convertedTotalDomains[j]}\n"
				nonMatchingDomains = []
				for k in 0...convertedTotalDomains[i].size
					for l in 0...convertedTotalDomains[j].size
						if convertedTotalDomains[i][k] != convertedTotalDomains[j][l] and not nonMatchingDomains.include? "#{convertedTotalDomains[i][k]},#{convertedTotalDomains[j][l]}"
							nonMatchingDomains.push("#{convertedTotalDomains[i][k]},#{convertedTotalDomains[j][l]}")
						end
					end
				end

				# print "#{nonMatchingDomains}\n"
				# for sl1 in 0...sectionLeaders.size
				# 	for sl2 in sl1+1...sectionLeaders.size
						constraints.put("#{sectionLeaders[i]},#{sectionLeaders[j]}", nonMatchingDomains)
						# print "pushing #{sectionLeaders[i]},#{sectionLeaders[j]}\n#{nonMatchingDomains}\n"
				# 	end
				# end

			end
		end
		
		# print "#{vars}\n"
		# print "CONSTRAINTS\n"
		if customRestrictions
			for i in customRestrictions.size-1..0 
				for name in customRestrictions[i]
					if not vars.include?(name)
						customRestrictions.delete_at(i)
						break
					end
				end
			end

			for additionalConstraint in customRestrictions
				index = 0
				for i in index...additionalConstraint.size
					for j in i+1...additionalConstraint.size
						nonConflictingTimes = []
						i1 = vars.index(additionalConstraint[i])
						i2 = vars.index(additionalConstraint[j])
						# print "#{i1},additionalConstraint#{i2}\n"
						for k in convertedTotalDomains[i1]
							for l in convertedTotalDomains[i2]
								if k != l
									nonConflictingTimes.push("#{k},#{l}")
								end
							end
						end
						constraints.put("#{i1},#{i2}",nonConflictingTimes)
						# print "#{i1},#{i2},#{nonConflictingTimes}\n"
					end 
				end
				index += 1
			end
		end

		finishedAssignments=[]
		finishedAssignments = backtrackingSearch(convertedVars,convertedTotalDomains,constraints,sectionLeaders,students,genders,intToTime,maybeTimes,min,max)
		
		# print "hi\n"
		# print "#{finishedAssignments}\n"
		# finishedAssignments = minConflicts(1000,nil,vars,constraints,sectionLeaders,students,intToTime,convertedTotalDomains)
		stuffs = []
		if not finishedAssignments[0]
			print "no solutions\n"
		else
			for assignment in finishedAssignments
				stuff = []
				for i in 0...intToTime.size
					stuff.push([])
					stuff[i] = []
				end
				for i in 0...assignment.size
					time = intToTime[assignment[i]]
					if not stuff[assignment[i]].include? time 
						stuff[assignment[i]].push(time)
					end
				end
				for i in 0...assignment.size
					time = intToTime[assignment[i]]
					stuff[assignment[i]].push(vars[i])
				end
				for i in (stuff.size-1).downto(0)
					if stuff[i].size == 0
						stuff.delete_at(i)
					end
				end	
				stuffs.push(stuff)
			end
		end

		print "SOLUTION\n"
		# print stuffs
		# print finishedAssignments
		for stuff in stuffs
			print "#{stuff}\n"
		end
		# assignment = [1,2,4,7,3,3]
		# print "#{sectionLeaders}\n"
		# print "#{students}\n"

		# constraints.isSatisfied(assignment,sectionLeaders,students,[])
		if stuffs.size == 0
			return nil
		end
		return stuffs
	end

	def backtrackingSearch(vars,domains,constraints,sectionLeaders,students,genders,intToTime,maybeTimes,min,max)
		assignment = []
		for i in 0...vars.size
			assignment.push(-1)
		end
		finishedAssignments = []
		ratio = []
		for i in 0...intToTime.size
			ratio.push([0,0,0,0])
		end
		recursiveBacktrackingSearch(vars,assignment,finishedAssignments,domains,constraints,sectionLeaders,students,ratio,genders,Time.now,min,max)

		maxScore = 0;
		maxAssignment = 0;
		for i in 0...finishedAssignments.size
			index = 0
			tempScore = 0
			for j in finishedAssignments[i]
				if maybeTimes[index].include? intToTime[j]
					tempScore += 1
				else
					tempScore += 2
				end
				index += 1
			end
			if tempScore > maxScore
				maxScore = tempScore
				maxAssignment = i
			end
		end
		# puts "final"
		# print "#{intToTime}\n"
		# print "#{finishedAssignments}\n"
		# print "#{finishedAssignments[maxAssignment]}\n"
		temp=finishedAssignments[maxAssignment]
		finishedAssignments = []
		finishedAssignments.push(temp)
		# return finishedAssignments
		return [finishedAssignments[maxAssignment]]
	end

	def recursiveBacktrackingSearch(vars,assignment,finishedAssignments,domains,constraints,sectionLeaders,students,ratio,genders,time,min,max)
		# print "#{Time.now},#{time}\n"
		if Time.now-time > 10
			return nil
		end
		if(goalTest(assignment))
			# print "GOAL #{assignment}\n"
			finishedAssignments.push(assignment.clone)
			return finishedAssignments
		else
			var = unassignedVariable(vars,assignment)
			# print "#{orderDomainValues(var,domains)}\n"
			for value in orderDomainValues(var,domains)
				assignment[var] = value
				# print "#{assignment}\n"
				if students.include? var
					ratio[value][0] += 1
				else
					ratio[value][1] += 1
				end
				if genders[var] == 'm'
					ratio[value][2] += 1
				else
					ratio[value][3] += 1
				end
				if constraints.isSatisfied(assignment,sectionLeaders,students,ratio,min,max)
					# print "satisfied\n"
					result = recursiveBacktrackingSearch(vars,assignment,finishedAssignments,domains,constraints,sectionLeaders,students,ratio,genders,time,min,max)
					# print result
					if result
						return result
					end
				end
				assignment[var] = -1
				if students.include? var
					ratio[value][0] -= 1
				else
					ratio[value][1] -= 1
				end
				if genders[var] == 'm'
					ratio[value][2] -= 1
				else
					ratio[value][3] -= 1
				end
			end
		end
		# puts "nil"
		return nil
	end

	def goalTest(assignment)
		for i in 0...assignment.size
			if assignment[i] == -1
				return false
			end
		end
		return true
	end

	def unassignedVariable(vars,assignment)
		for i in 0...assignment.size
			if assignment[i] == -1
				return vars[i]
			end
		end
	end

	def orderDomainValues(var,domains)
		return domains[var];
	end

	def minConflicts(maxSteps,newAssignment,vars,constraints,sectionLeaders,students,intToTime,domains)
		# print 'hi'
		ratio = []
		for i in 0...intToTime.size
			ratio.push([0,0,0,0])
		end
		assignment = newAssignment
		if not assignment
			assignment = []
			for i in 0...vars.size
				assignment.push(0)
			end
		end
		print "#{vars}\n"
		print "#{intToTime}\n"
		for i in 0...maxSteps
			# puts i
			if goalTest(assignment) and constraints.isSatisfied(assignment,sectionLeaders,students,ratio)
				return [assignment]
			end
			var = constraints.conflictingVar(assignment)
			minValue = 99999
			minDomain = 99999
			for j in domains[var]
				value = conflicts(var,j,assignment,constraints)
				if value < minValue
					minValue = value
					minDomain = j
				end
			end	
			if assignment[var] == -1
				if students.include?(var)
				ratio[value][0] += 1
				else
					ratio[value][1] += 1
				end
				if genders[temp] == 'm'
					ratio[value][2] += 1
				else
					ratio[value][3] += 1
				end
			end
			assignment[var] = minDomain
		end
	end


	def conflicts(var,value,assignment,constraints)
		numConflicts = 0
		involved = constraints.involves(var)
		for s in involved
			data = s.split(",")
			other = data[1].to_i == var ? data[0].to_i : data[1].to_i
			if constraints.hasKey("#{var},#{other}")
				if not constraints.includes("#{var},#{other}","#{value},#{assignment[other]}")
					numConflicts += 1
				end
			elsif constraints.hasKey("#{other},#{var}")
				if not constraints.includes("#{other},#{var}","#{assignment[other]},#{other}")
					numConflicts += 1
				end
			end
		end
		return numConflicts
	end
	# Setup.new.parse("case2.txt",nil,false,false,0,0)
end