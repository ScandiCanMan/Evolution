#!/usr/bin/ruby

#Our Blob class will be the living, mating, and dying creature of this
#simulation. Each blob has numerous traits, some of which can be passed
#onto its children. Although a blob does have a position on the World,
#the position is not recorded in this class, but in the World class.
class Blob
	def initialize(traits)
		######################################
		#Required parameters to be passed in
		######################################
		@instance = traits["instance"] #The unique "name" of the blob
		@maxAge = traits["maxAge"] #The age at which the blob will die of old age

                ######################################
		#Optional parameters to be passed
                ######################################

		#If the parent is not passed, set to 0
		if traits["parent"].to_i > 0 
			@parent = traits["parent"]
		else
			@parent = 0
		end

		#If the age is not passed, set to 0
		if traits["age"].to_i > 0
			@age = traits["age"]
		else
			@age = 0
		end

		#If a gender is passed, use it, else, choose one randomly
		if traits["gender"] == "male" or traits["gender"] == "female"
			@gender = traits["gender"]
		else
			case rand(2)
			when 0
				@gender = "male"
			when 1
				@gender = "female"
			end
		end

                ######################################
		#Assumed Parameters
                ######################################
		@status = "alive" #All blobs start alive
		@offspring = 0 #No blobs are born with offspring
		@pregnant = false #Blobs don't start pregnant
		@turnsPregnant = 0 #If a blob is pregnant, how many days has it been pregnant
	end

	#Returns the unique instance number of this blob
	def instance
		return @instance
	end

	#Returns the status (alive or dead) of the blob
	def status
		return @status
	end

	#Returns which blob instance was the parent to this blob (0 if no parent)
	def parent
		return @parent
	end

	#Returns a count of how many offspring the blob has
	def offspring
		return @offspring
	end

	#Returns the gender of the blob
	def gender
		return @gender
	end

	#Returns the current age of the blob
	def age
		return @age
	end

	#Returns the max age the blob can be before dying
	def maxAge
		return @maxAge
	end

	#Returns if the blob is pregnant
	def pregnant
		return @pregnant
	end

	#Returns how many turns the blob has been pregnant
	def turnsPregnant
		return @turnsPregnant
	end

	#Increase the blob's age by 1 tick
	def increaseAge
		@age = @age + 1
	end

	#Increase turns pregnant by 1
	def increaseTurnsPregnant
		@turnsPregnant = @turnsPregnant + 1
	end

	#Sets a female to pregnant
	def mate
		@pregnant = true
	end

	def noLongerPregnant
		@pregnant = false
		@turnsPregnant = 0
	end

	#Increase the blob's offspring counter by 1
	def newParent
		@offspring = @offspring + 1
	end

	#Set the blob's status to dead
	def kill
		@status = "dead"
	end
end

#Our World class will contain an array of coordinates, which are
#a subclass of World. Each coordinate will be occupiedBy 0 on
#initialization, and whenever a blob moves into a spot the
#occupiedBy property will be taken by that blob's instance
class World
	def initialize(length, width)
		@length = length #x
		@width = width #y
		@coordinates = Array.new

		iLength = 0
		iWidth = 0

		while @width > iWidth
			iWidth = iWidth + 1

			while @length > iLength
				iLength = iLength + 1
				@coordinates.push(Coordinate.new(iLength, iWidth))
			end
			iLength = 0
		end
	end

	#Holds three parameters: x, y, and who the coordinate is occupied by
	class Coordinate
		def initialize (x, y)
			@x = x #width
			@y = y #length
			@occupiedBy = 0
		end

		#Returns x
		def getX
			return @x
		end

		#Returns y
		def getY
			return @y
		end

		#Returns the instance of what blob occupies the coordinate
		def getOccupied
			return @occupiedBy
		end

		#Sets the occupancy of the coordinate
		def setOccupied(instance)
			@occupiedBy = instance
		end

		def status
			statusString = "Coordinate #{@x}:#{@y} occupied by blob #{@occupiedBy}"
		end
	end

	#Gets the length (x) of the world
	def getLength
		return @length
	end

	#Gets the width (y) of the world
	def getWidth
		return @width
	end

	#Returns the instance of what blob is occupying a coordinate
	def getCoordinate(x, y)
		instance = 0
		@coordinates.each do |coordinate|
                        if x == coordinate.getX and y == coordinate.getY
                                instance = coordinate.getOccupied
                        end
                end

		return instance
	end

	#Returns string of all coordinates with their status
	def getCoordinates
		returnText = ""

		@coordinates.each do |coordinate|
			returnText = returnText + coordinate.status + "\n"
		end

		return returnText
	end

	#Searches for a blob by its instance across all coordinates
	def findBlob(instance)
		result = ""

		@coordinates.each do |coordinate|
			if coordinate.getOccupied == instance
				result = {'x' => coordinate.getX, 'y' => coordinate.getY}
			end
		end

		return result
	end

	#Sets an x,y coordinate to the passed instance
	def moveBlob(instance, x, y)
		@coordinates.each do |coordinate|
			if x == coordinate.getX and y == coordinate.getY
				coordinate.setOccupied(instance)
			end
		end
	end

	#Looks around the x,y coordinate some number of cells, as determined by "distance"
	def lookAround(x, y, distance)
		#We need to know how long and wide the world is so we don't look beyond it
		length = self.getLength #x
		width = self.getWidth #y

		#We're essentially going to draw a box around our coordinate by subtracting
		#the distance from our coordinate's x and y values, and adding the distance
		#to the coordinate's x and y values. If after the math, the minimum distance
		#is less than 1, or the maximum distance is greater than the world's
		#length/width, set it to either 1, or to the world's max boundary.

		#Determine left-most x, and right-most x
		minX = x - distance
		maxX = x + distance

		if minX < 1
			minX = 1
		end

		if maxX > length
			maxX = length
		end

		#Determine upper-most y, and lower-most y
		minY = y - distance
		maxY = y + distance

		if minY < 1
			minY = 1
		end

		if maxY > width
			maxY = width
		end

		#Our first grid coordinate should be the upper left most within our view distance
		checkX = minX
		checkY = minY

		#Will hold array of hashmaps with three values: x, y, instance
		coordinateResults = Array.new

		#Scan left column first (ie, x1:y1, x1:y2, x1:y3)
		#the work inwards (x2:y1, x2:y2, x2:y3)
		while checkX <= maxX
			while checkY <= maxY
				#Don't look at the coordinate that was passed
				if checkX == x and checkY == y
				else
					instance = self.getCoordinate(checkX, checkY)
					coordinateResults.push({'x' => checkX, 'y' => checkY, 'instance' => instance})
				end
				checkY = checkY + 1
			end
			checkY = minY
			checkX = checkX + 1
		end

		return coordinateResults
	end

	#Takes two coordinates (x1:y1 and x2:y2) and checks if they are touching
	def isTouching(x1, y1, x2, y2)
		if (x1 == x2 or x1 == x2 - 1 or x1 == x2 + 1) and (y1 == y2 or y1 == y2 - 1 or y1 == y2 + 1)
			#puts "blobs are touching"
			return true
		else
			return false
		end
	end

	#Draw out an ASCII map showing the coordinates and blobs coloured by gender
	def showMap(blobs)

		length = self.getLength
		width = self.getWidth
		iLength = 0
		iWidth = 0
		asciiMap = ""

		#While the world's width (y) is greater than our width counter
		while width > iWidth
			iWidth = iWidth + 1

			#Start a new line, the start the top of our map by creating
			#a " -" pattern across the top by repeating as many times as
			#the world is wide
			asciiMap = asciiMap + "\n" + (" -" * length) + " \n|"

			#While the world's length (x) is greater than our length counter
			while length > iLength
				iLength = iLength + 1

				#Place holder for gender
		                blobGender = ""

				#Get the blob instance of this cell, 0 if no blob present
		                blobInstance = self.getCoordinate(iLength, iWidth)

				#If the blob instance is 0 give a blank space
		                if blobInstance == 0
		                        asciiMap = asciiMap + " |"
                		else
					#Find the matching blob and determine gender
		                        blobs.each do |blob|
		                                if blob.instance == blobInstance
                		                        blobGender = blob.gender
		                                end
		                        end

					#Colour the B icon appropriate to the gender
		                        if blobGender == "male"
		                                asciiMap = asciiMap + "B".c_male + "|"
		                        else
		                                asciiMap = asciiMap + "B".c_female + "|"
		                        end
		                end
		        end
			iLength = 0
		end

		asciiMap = asciiMap + "\n" + (" -" * length) + " \n\n"
		return asciiMap
	end
end

#Appending to the string class by creating terminal compliant colours
class String
# Colour reference:
#
#       Colour:         FG:             BG:
#       Black           30              40
#       Red                     31              41
#       Green           32              42
#       Yellow          33              43
#       Blue            34              44
#       Magenta         35              45
#       Cyan            36              46
#       White           37              47
#
# For bright colours, add ;1 after the escape code
# eg. \e[33;1m
        def c_male; "\e[36;1m#{self}\e[0m" end
        def c_female; "\e[35m#{self}\e[0m" end
end

#Setting up variables
lifeChance = 0	 		#Probability that a new creature spawns
deathChance = 0 #1			#Probability that a creature dies randomly
pregnancyPeriod = 3		#How many days a female must be pregnant before giving birth
reproductionChance = 0 #10		#Chance a blob will reproduce spontaneously
maxOffspring = 2		#Maximum number of offspring a parent may have
minimumReproductionAge = 1	#Minimum age a blob must be to reproduce
sleep = 1.75			#Sleep between runs
blobs = Array.new		#Storage for our blob creatures
i = 0				#How many iterations of the loop
ageTrait = 0			#The trait given to a new blob
liveCount = 0			#How many are alive at the end of a loop
deadCount = 0			#Hot many are dead at the end of a loop

#Initialize world
world = World.new(10,10)

#Create our Adam and Eve blobs
blobs.push(Blob.new({'instance' => 1, 'age' => 1, 'maxAge' => 15, 'gender' => 'male'}))
blobs.push(Blob.new({'instance' => 2, 'age' => 1, 'maxAge' => 15, 'gender' => 'female'}))

#Assign Adam and Eve blobs to cells
world.moveBlob(1, 1, 1)
world.moveBlob(2, 3, 3)

#Start the simulation!
loop do
	#On every iteration, clear the terminal
	system "clear"

	#Gather news from blobs into a string to display at end
	news = ""

	#Counting the iterations
	i = i + 1

	#Keeping track of how many blobs are alive and dead as the turn progresses
	liveCount = 0
	deadCount = 0

	#Creating the age trait to be used if a blob is born
	ageTrait = 0

	#For each blob, get its location, determine if it's alive or dead
	#If alive, determine if it dies, gives birth, and where it moves
	blobs.each do |blob|
		#Find the blob's location in the world
		blobLocation = world.findBlob(blob.instance)
		blobX = blobLocation['x']
		blobY = blobLocation['y']

		decidedMate = {'instance' => 0}

		#If the blob is alive, see if it dies
		if blob.status == "alive"
			#Does the blob die randomly?
			if rand(100) < deathChance
				news = news + "[*]Blob " + blob.instance.to_s + " randomly died!\n"
				blob.kill
				world.moveBlob(0, blobX, blobY) #Make sure to remove the instance of the blob in the world
			end

			#Does the blob die of old age?
			if blob.age == blob.maxAge
				news = news + "[*]Blob " + blob.instance.to_s + " just died of old age!\n"
				blob.kill
				world.moveBlob(0, blobX, blobY) #Make sure to remove the instance of the blob in the world
			end
		end

		#Determine if the blob is alive or dead, and add to counter
		#If blob is alive, see if it reproduced
		if blob.status == "alive"
			liveCount = liveCount + 1

			#If our blob is male, it will look for a mate
			if blob.gender == "male"
				if blob.age > minimumReproductionAge
					cells = world.lookAround(blobX, blobY, 3)
					eligibleFemales = Array.new

					cells.each do |cell|
						if cell['instance'] > 0
							#puts blob.instance.to_s + " found a blob"
							blobs.each do |potentialMate|
								if potentialMate.instance == cell['instance']
									if potentialMate.gender == 'female'
										#puts "Blob is female"
										if potentialMate.offspring < maxOffspring
											#puts "Blob " + cell['instance'].to_s + " is acceptable mate"
											decidedMate = {'instance' => cell['instance'], 'x' => cell['x'], 'y' => cell['y']}
										end
									end
								end
							end
						end
					end
				end
			end

			if decidedMate['instance'] > 0
				#puts "Blob " + blob.instance.to_s + " decided that blob " + decidedMate['instance'].to_s + " is a good mate"
				world.isTouching(blobX, blobY, decidedMate['x'], decidedMate['y'])

				#If the male is touching the female, mate
				if world.isTouching(blobX, blobY, decidedMate['x'], decidedMate['y'])
					blobs.each do |findMate|
						if findMate.instance == decidedMate['instance']
							if findMate.pregnant == false
								news = news + "Blob " + blob.instance.to_s + " mated with blob " + decidedMate['instance'].to_s + "\n"
								findMate.mate
							end
						end
					end
				end
			end

			if blob.gender == 'female' and blob.pregnant == true
				blob.increaseTurnsPregnant
				#news = news + "Blob " + blob.instance.to_s + " is " + blob.turnsPregnant.to_s + " turns pregnant!\n"

				if blob.turnsPregnant == pregnancyPeriod
					#Determine if max age goes down by 1, stays the same, or up by 1
                                        case rand(3)
                                        when 0
                                        	ageTrait = blob.maxAge - 1
                                       	when 1
                                        	ageTrait = blob.maxAge
                                       	when 2
                                                ageTrait = blob.maxAge + 1
                                        end

					#Create a new blob with a new unique instance, determined maxAge, and parent instance
					blobs.push(Blob.new({'instance' => blobs.count + 1, 'maxAge' => ageTrait, 'parent' => blob.instance}))

                                        #Now time to place the baby blob into the world
                                        babyPlaced = false
                                        distance = 0

                                        #Start in a 1 range grid around the parent and find a place to put the blob
                                        #If we don't find an empty spot immediately around the parent, expand out
                                        until babyPlaced do
                                        	distance = distance + 1

                                                #Shuffle the returned coordinates so we don't always spawn the blob
                                                #in the upper left first
                                                cells = world.lookAround(blobX, blobY, distance).shuffle

                                                cells.each do |cell|
                                                	if cell['instance'] == 0
                                                        	world.moveBlob(blobs.count, cell['x'], cell['y'])
                                                                babyPlaced = true
                                                                break
                                                        end
                                                end
					end

                                        #Increase the parent's offspring counter
                                        blob.newParent
					blob.noLongerPregnant

                                        news = news + "[*]Blob " + blob.instance.to_s + " had a baby! Total offspring: " + blob.offspring.to_s + "\n"
				end
			end

			#If the blob is able to reproduce, create a new blob
#			if rand(100) < reproductionChance
#				#Is the blob old enough to reproduce?
#				if blob.age > minimumReproductionAge
#					#Has the blob had as many offspring as possible?
#					if blob.offspring < maxOffspring
#						#Determine if max age goes down by 1, stays the same, or up by 1
#						case rand(3)
#						when 0
#							ageTrait = blob.maxAge - 1
#						when 1
#							ageTrait = blob.maxAge
#						when 2
#							ageTrait = blob.maxAge + 1
#						end
#
#						#Create a new blob with a new unique instance, determined maxAge, and parent instance
#						blobs.push(Blob.new({'instance' => blobs.count + 1, 'maxAge' => ageTrait, 'parent' => blob.instance}))
#
#						#Now time to place the baby blob into the world
#						babyPlaced = false
#						distance = 0
#
#						#Start in a 1 range grid around the parent and find a place to put the blob
#						#If we don't find an empty spot immediately around the parent, expand out
#						until babyPlaced do
#							distance = distance + 1
#
#							#Shuffle the returned coordinates so we don't always spawn the blob
#							#in the upper left first
#							cells = world.lookAround(blobX, blobY, distance).shuffle
#
#							cells.each do |cell|
#								if cell['instance'] == 0
#									world.moveBlob(blobs.count, cell['x'], cell['y'])
#									babyPlaced = true
#									break
#								end
#							end
#						end
#
#						#Increase the parent's offspring counter
#						blob.newParent
#
#						news = news + "[*]Blob " + blob.instance.to_s + " had a baby! Total offspring: " + blob.offspring.to_s + "\n"
#					end
#				end
#			end

			#If the blob can take a step somewhere, make them go
			#First, grab the cells 1 cell around the blob and shuffle the array
			#Then check each coordinate, and if there's no blob there (instance == 0) move the blob to it
			#When we move the blob, set their last position to 0, then set their new one to them
			#Make sure we change blobX and blobY to the new position
			cells = world.lookAround(blobX, blobY, 1).shuffle

			cells.each do |cell|
				if cell['instance'] == 0
					world.moveBlob(0, blobX, blobY)
					world.moveBlob(blob.instance, cell['x'], cell['y'])
					blobX = cell['x']
					blobY = cell['y']
					break
				end
			end

			blob.increaseAge
		else
			deadCount = deadCount + 1
			#puts "[*]Blob " + blob.instance.to_s + " is dead! deadCount: " + deadCount.to_s
		end
	end

	#Check if life spontaneously came into being
	if rand(100) < lifeChance
		puts "[*]Spontaneous life!"
		blobs.push(Blob.new(blobs.count + 1))
		liveCount = liveCount + 1
	end

	news = news + "Blobs Alive: " + liveCount.to_s + "\t\t Blobs Dead: " + deadCount.to_s + "\n\n"

	puts world.showMap(blobs)
	puts news

	#If not more blobs are alive, exit
	if liveCount == 0
		exit
	end
	sleep(sleep)

end