a=Time.now
i=0
for i in 0...10000000
	i+=1
end
print Time.now-a>0.5