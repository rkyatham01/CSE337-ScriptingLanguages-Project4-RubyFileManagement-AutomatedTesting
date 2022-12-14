#!/usr/bin/env ruby
args = ARGF.argv

def parseArgs(args)
  if args.length < 2
    return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
  end
  optionArr = Array.new() #For storing options
  fileArr = Array.new() #For storing files
  patternArr = Array.new() #For storing patterns
  contigPatternArr = Array.new() #For checking contigous patterns
  nonExistingFiles = Array.new() #For illegal files
  illegalPatterns = Array.new() #For illegal
  patternsForF = Array.new()

  validOptionsArr = [
    '-v', '--invert-match', #option (1)
    '-c', '--count', #option (2)
    '-l', '--files-with-matches', # option (3)
    '-L', '--files-without-match', # option (4)
    '-o', '--only-matching', #option (5)
    '-F', '--fixed-strings', #option (6)
  ]

  i = -1 #index
  for arg in args do
    i += 1
    if arg.start_with?('-')
      if arg.start_with?("-A_") or arg.start_with?("-B_") or arg.start_with?("-C_")
        splitArr = arg.split("_")
        if splitArr.length != 2 #No numbers errors
          return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
        else
          #check the 2nd arguement is a valid digit
          string = splitArr[1]
          if string.count("^0-9").zero? == false
            return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
          else
            optionArr.append(arg)
            next
          end
        end

      elsif arg.start_with?("--after-context=") or arg.start_with?("--before-context=") or arg.start_with?("--context=")
        splitArr = arg.split("=")
        if splitArr.length != 2 #No number errors
          return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
        else
          #check the 2nd arguement is a valid digit
          string = splitArr[1]
          if string.count("^0-9").zero? == false
          return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
          else
            optionArr.append(arg)
          end
        end
      #Checking invalid option names here
      elsif validOptionsArr.include?(arg) == false
        return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
      else
        optionArr.append(arg)
      end
   #######################################################################     
    elsif arg[0] == "\"" #special character
      #Check here b4 processing the valid pattern
      begin
        patternModified = arg[1..arg.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        patternsForF.append(arg)
        patternArr.append(arg)
        contigPatternArr.append(i)
      rescue RegexpError
        illegalPatterns.append("Error: cannot parse " + arg)
        patternsForF.append(arg)
      else
      end
   #######################################################################     
    else
      if File.exists?(arg) == false
        errorString = "Error: could not read file " + arg 
        nonExistingFiles.append(errorString)
        next
      end
      fileArr.append(arg)
    end
  end
  #  puts nonExistingFiles
  finalError = Array.new() #Final error array that I'm going to pass in
  for files in nonExistingFiles
    finalError.append(files)
  end

  if optionArr.include?("-F") or optionArr.include?("--fixed-strings")
    illegalPatterns = []
  end

  for patterns in illegalPatterns
    finalError.append(patterns)
  end

  errorString = ""
  for errors in finalError
    errorString += "#{errors}\n"
  end
  #Checks for any patterns available

  if not optionArr.include?("-F") and not optionArr.include?("--fixed-strings")
    if patternArr.length == 0 #checks  empty or not patterns
      return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
    end
  end
  #Could try fixing later for Contigous Patterns for -F
  #Checks for contigous patterns
  if not optionArr.include?("-F") and not optionArr.include?("--fixed-strings")
    minIndx = contigPatternArr.min()
    finalIndx = minIndx + (contigPatternArr.length-1)
  if ((minIndx..finalIndx).to_a) != contigPatternArr # pattern arrays aren't contigous
    return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"
  end
  end
  optionalArguementSearch(optionArr, fileArr, patternArr, errorString, patternsForF)
end

#still valid in this function, checked for invalid, After Errors except invalid option combinations
#Passing in 3 arrays, 1 for option Array, 1 for file array, 1 for pattern array
def optionalArguementSearch(optionArr, fileArr, patternArr, errorString, patternsForF)
  #Option (-V only) Checked
  if optionArr == ['-v'] or optionArr == ['--invert-match']
    textBlock = ""
    finalString = ""
    finalString2 = ""

    for file in fileArr
      theFile = File.open(file)
      arrStore = []
      arrManyStore = []
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        for line in theFile.readlines()
          if regexExpression.match(line) == nil
            if not arrStore.include?(line)
              arrStore.append(line)
            end
            if not arrManyStore.include?("#{file}: #{line}")
              arrManyStore.append("#{file}: #{line}")
            end
          end
        end
      end
        finalString += arrStore.join("")
        finalString2 += arrManyStore.join("")
        if file != fileArr[fileArr.length-1]
          finalString += "\n"
          finalString2 += "\n"
        end
    end

    if fileArr.length == 1
      theFinalString = errorString
      theFinalString += finalString
      return theFinalString
    else
      theFinalString = errorString
      theFinalString += finalString2
      return theFinalString
    end
  end
#############################################################
  #Option (-C only) Checked
  if optionArr == ['-c'] or optionArr == ['--count']
    finalCount = ""
    finalCountOne = ""
    for file in fileArr
      count = 0
      theFile = File.open(file)
      for line in theFile.readlines()          
        for pattern in patternArr
          patternModified = pattern[1..pattern.length-2]
          regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
          if regexExpression.match(line) != nil #target found
            count += 1
            break
          end
        end
      end
    fileConcat = "#{file}: #{(count).to_s}"
    finalCountOne = "#{(count).to_s}"
    if file != fileArr[fileArr.length - 1]
      fileConcat += "\n"
      finalCountOne += "\n"
    end
    finalCount += fileConcat
    finalCount2 = finalCountOne
    end

    if fileArr.length == 1
      realFinalString = errorString
      realFinalString += finalCount2
      return realFinalString
    else
      realFinalString = errorString
      realFinalString += finalCount
      return realFinalString
    end
  end

#############################################################
  #Option (-l Only) Checked
  if optionArr == ['-l'] or optionArr == ['--files-with-matches']
    fileNames = ""
    filesArr = []
    for file in fileArr
      boolean = false
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        theFile = File.open(file)
        for line in theFile.readlines()
          if regexExpression.match(line) != nil
            boolean = true
          end
        end
      end
      if boolean == true #theirs a match here
        filesArr.append(file)
      end
    end
    finalArr = []
    for file in filesArr
      if not finalArr.include?(file) #there is a match
        finalArr.append(file) #removes the copies
      end
    end
    finalString1 = finalArr.join("\n")
    finalString2 = errorString + finalString1
    print(finalString2)
    return finalString2
  end
#############################################################
  #Option (-L Only) Checked
  if optionArr == ['-L'] or optionArr == ['--files-without-match']
    fileNames = ""
    filesArr = []
    for file in fileArr
      boolean = false
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        theFile = File.open(file)
        for line in theFile.readlines()
          if regexExpression.match(line) != nil
            boolean = true
          end
        end
      end
      if boolean == false #theirs a match here
        filesArr.append(file)
      end
    end
    finalArr = []
    for file in filesArr
      if not finalArr.include?(file) #there is a match
        finalArr.append(file) #removes the copies
      end
    end
    finalString1 = finalArr.join("\n")
    finalString2 = errorString + finalString1
    return finalString2
  end
#################################################################
  #Option (-O Only) Checked
  if optionArr == ['-o'] or optionArr == ['--only-matching']
    matches = ""
    matchesWithOne = ""
    for file in fileArr
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        theFile = File.open(file)
        for line in theFile.readlines()
          if line.include?(patternModified) #there is a match
            for words in line.scan(patternModified) #scan makes an array of each occurence in the line of that word
              matches += "#{file}: #{words}\n"
              matchesWithOne += "#{words}\n"
            end
          end
        end
      end
    end

    if fileArr.length == 1
      finalString = ""
      finalString += errorString
      finalString += matchesWithOne
      return finalString
    else
      finalString = ""
      finalString += errorString
      finalString += matches
      return finalString
    end
  end
##################################################################
  #Option (-F Only) Checked

  if optionArr == ['-F'] or optionArr == ['--fixed-strings']
    fixedStringForOne = ""
    fixedStringStr = ""
    for file in fileArr
      theFile = File.open(file)
      for line in theFile.readlines()
        for pattern in patternsForF
          patternModified = pattern[1..pattern.length-2]
            if line.include?(patternModified)
              fixedStringStr += "#{file}: #{line}"
              fixedStringForOne += "#{line}"
              break
            end
          end
        end
    end

    if fileArr.length == 1
      finalString = ""
      finalString += errorString
      finalString += fixedStringForOne
      return finalString
    else
      finalString = ""
      finalString += errorString
      finalString += fixedStringStr
      return finalString
    end
  end
###################################################################
#Option (-A_NUM Only) #Checked
  regexPatternForA = "^-A_[0-9]+$"
  regexPatternForB = "^-B_[0-9]+$"
  regexPatternForC = "^-C_[0-9]+$"
  regexPatternWorkForA = Regexp.new(regexPatternForA)
  regexPatternWorkForB = Regexp.new(regexPatternForB)
  regexPatternWorkForC = Regexp.new(regexPatternForC)

  regexPatternForSecA = "--after-context=[0-9]+$"
  regexPatternForSecB ="--before-context=[0-9]+$"
  regexPatternForSecC = "--context=[0-9]+$"
  regexPatternForAfterContext = Regexp.new(regexPatternForSecA)
  regexPatternForBeforeContext = Regexp.new(regexPatternForSecB)
  regexPatternForAfterAndBeforeContext = Regexp.new(regexPatternForSecC)

  if (optionArr.length == 1 and regexPatternWorkForA.match(optionArr[0])) or (optionArr.length == 1 and regexPatternForAfterContext.match(optionArr[0]))
    
    if optionArr[0].start_with?("--after-context")
      arrSplited = optionArr[0].split("=")
    else
      arrSplited = optionArr[0].split("_")
    end

    count = (arrSplited[1]).to_i #The count of how many to go after
    finalArray = []
    finalArrayOne = []

    for file in fileArr #First Iteration to read the entire file
      theFile = File.open(file)
      readArray = theFile.readlines() #gets the stuff in a array
      tempString = ""
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        i = 0
        for line in readArray
          minimum = readArray.length-1
          if regexExpression.match(line) != nil #there is a match
            finalArray.append("#{file}: #{line}".delete("\n"))
            finalArrayOne.append("#{line}".delete("\n"))
            if minimum >= i + count #Gets the minimum of the 2
              minimum = i + count
            end
            (i+1..minimum).each do |indx| #Iterator in Ruby
              finalArray.append("#{file}: #{readArray[indx]}".delete("\n"))
              finalArrayOne.append("#{readArray[indx]}".delete("\n"))
            end
            finalArray.append("--")
            finalArrayOne.append("--")
          end
          i += 1
        end
     end
    end
    if fileArr.length == 1
      finalArrayOne.pop()
      matchesArray = finalArrayOne.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    else
      finalArray.pop()
      matchesArray = finalArray.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    end
  end
  ##############################################################
  #Option (-B_NUM Only) Checked
  if (optionArr.length == 1 and regexPatternWorkForB.match(optionArr[0])) or (optionArr.length == 1 and regexPatternForBeforeContext.match(optionArr[0]))

    if optionArr[0].start_with?("--before-context")
      arrSplited = optionArr[0].split("=")
    else
      arrSplited = optionArr[0].split("_")
    end

    count = (arrSplited[1]).to_i #The count of how many to go after
    finalArray = []
    finalArrayOne = []

    for file in fileArr #First Iteration to read the entire file
      theFile = File.open(file)
      readArray = theFile.readlines() #gets the stuff in a array
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        i = 0
        for line in readArray
          maximum = 0
          if regexExpression.match(line) != nil #there is a match
            finalArray.append("#{file}: #{line}".delete("\n"))
            finalArrayOne.append("#{line}".delete("\n"))
            if maximum <= i - count #Gets the minimum of the 2
              maximum = i - count
            end
            tempIndx = i
            while tempIndx > maximum
              tempIndx = tempIndx - 1
              finalArray.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
              finalArrayOne.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
              end
            finalArray.append("--")
            finalArrayOne.append("--")
          end
          i += 1
        end
      end
    end
    if fileArr.length == 1
      finalArrayOne.pop()
      matchesArray = finalArrayOne.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    else
      finalArray.pop()
      matchesString = finalArray.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesString
      return finalString
    end
  end
  ##############################################################
  #Option (-C_NUM Only) Checked
  if (optionArr.length == 1 and regexPatternWorkForC.match(optionArr[0])) or (optionArr.length == 1 and regexPatternForAfterAndBeforeContext.match(optionArr[0]))
    finalArray = []
    finalArrayOne = []
    if optionArr[0].start_with?("--context")
      arrSplited = optionArr[0].split("=")
    else
      arrSplited = optionArr[0].split("_")
    end

    count = (arrSplited[1]).to_i #The count of how many to go after

    for file in fileArr #First Iteration to read the entire file
      theFile = File.open(file)
      readArray = theFile.readlines() #gets the stuff in a array
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        i = 0
        for line in readArray
          maximum = 0
          minimum = readArray.length-1
          if regexExpression.match(line) != nil #there is a match
            finalArray.append("#{file}: #{line}".delete("\n"))
            finalArrayOne.append("#{line}".delete("\n"))
            if maximum <= i - count #Gets the minimum of the 2
              maximum = i - count
            end
            if minimum >= i + count #Gets the minimum of the 2
              minimum = i + count
            end
            tempIndx = i
            while tempIndx > maximum
              tempIndx = tempIndx - 1
              finalArray.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
              finalArrayOne.append("#{readArray[tempIndx]}".delete("\n"))
              end
            (i+1..minimum).each do |indx| #Iterator in Ruby
              finalArray.append("#{file}: #{readArray[indx]}".delete("\n"))
              finalArrayOne.append("#{readArray[indx]}".delete("\n"))
            end
            finalArray.append("--")
            finalArrayOne.append("--")
          end
          i += 1
        end
      end
    end
    if fileArr.length == 1
      finalArrayOne.pop()
      matchesArray = finalArrayOne.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    else
      finalArray.pop()
      matchesString = finalArray.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesString
      return finalString
    end
  end
  ####################################################################
  #Combination of -C and -V Checked
  if (optionArr.include?('-c') and optionArr.include?('-v') and optionArr.length == 2) or
    (optionArr.include?('-c') and optionArr.include?('--invert-match') and optionArr.length == 2) or
    (optionArr.include?('--count') and optionArr.include?('-v') and optionArr.length == 2) or
    (optionArr.include?('--count') and optionArr.include?('--invert-match') and optionArr.length == 2)
    finalCount = ""
    finalCountOne = ""
    for file in fileArr
      count = 0
      theFile = File.open(file)
      for line in theFile.readlines()          
        for pattern in patternArr
          patternModified = pattern[1..pattern.length-2]
          regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
          if regexExpression.match(line) == nil #target found
            count += 1
            break
          end
        end
      end
    fileConcat = "#{file} #{(count).to_s}\n"
    finalCountOne = "#{(count).to_s}\n"

    finalCount += fileConcat
    finalCount2 = finalCountOne
    end

    if fileArr.length == 1
      realFinalString = errorString
      realFinalString += finalCount2
      return realFinalString
    else
      realFinalString = errorString
      realFinalString += finalCount
      return realFinalString
    end
  end
#################################################################################################
  #Combination of -C and -o (Checked)
  if (optionArr.include?('-c') and optionArr.include?('-o') and optionArr.length == 2) or
    (optionArr.include?('-c') and optionArr.include?('--only-matching') and optionArr.length == 2) or
    (optionArr.include?('--count') and optionArr.include?('-o') and optionArr.length == 2) or
    (optionArr.include?('--count') and optionArr.include?('--only-matching') and optionArr.length == 2)
    finalCount = ""
    finalCountOne = ""
    for file in fileArr
      count = 0
      theFile = File.open(file)
      for line in theFile.readlines()          
        for pattern in patternArr
          patternModified = pattern[1..pattern.length-2]
          regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
          if regexExpression.match(line) != nil #target found
            count += 1
            break
          end
        end
      end
    fileConcat = "#{file}: #{(count).to_s}\n"
    finalCountOne = "#{(count).to_s}\n"

    finalCount += fileConcat
    finalCount2 = finalCountOne
    end

    if fileArr.length == 1
      realFinalString = errorString
      realFinalString += finalCount2
      return realFinalString
    else
      realFinalString = errorString
      realFinalString += finalCount
      return realFinalString
    end
  end
#################################################################################################
  #Combination of -F and -c (Checked)
  if (optionArr.include?('-F') and optionArr.include?('-c') and optionArr.length == 2) or
    (optionArr.include?('-F') and optionArr.include?('--count') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('-c') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('--count') and optionArr.length == 2)
    fixedStringForOne = ""
    fixedStringStr = ""
    for file in fileArr
      count = 0
      theFile = File.open(file)
      for line in theFile.readlines()
        for pattern in patternsForF
          patternModified = pattern[1..pattern.length-2]
            if line.include?(patternModified)
              count += 1
              break
            end
          end
        end
        fixedStringStr += "#{file}: #{(count).to_s}\n"
        fixedStringForOne += "#{(count).to_s}\n"
    end
    if fileArr.length == 1
      finalString = ""
      finalString += errorString
      finalString += fixedStringForOne
      return finalString
    else
      finalString = ""
      finalString += errorString
      finalString += fixedStringStr
      return finalString
    end
  end
#################################################################################################
  #Combination of -F and -o Corrected
  if (optionArr.include?('-F') and optionArr.include?('-o') and optionArr.length == 2) or
    (optionArr.include?('-F') and optionArr.include?('--only-matching') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('-o') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('--only-matching') and optionArr.length == 2)
    matches = ""
    filematches = ""
    for file in fileArr
      theFile = File.open(file)
      for line in theFile.readlines()
        for pattern in patternsForF
          patternModified = pattern[1..pattern.length-2]
          if line.include?(patternModified) #there is a match
            for words in line.scan(patternModified) #scan makes an array of each occurence in the line of that word
              matches += "#{words}\n"
              filematches += "#{file}: #{words}\n"
              end
            end
          end
        end
    end

    if fileArr.length == 1
      finalString = ""
      finalString += errorString
      finalString += matches
      return finalString
    else
      finalString = ""
      finalString += errorString
      finalString += filematches
      return finalString
    end
  end
#######################################################################################################
  #Combination of -F and -V 
  if (optionArr.include?('-F') and optionArr.include?('-v') and optionArr.length == 2) or
    (optionArr.include?('-F') and optionArr.include?('--invert-match') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('-v') and optionArr.length == 2) or
    (optionArr.include?('--fixed-strings') and optionArr.include?('--invert-match') and optionArr.length == 2)
    fixedStringsLines = ""
    fixedStringsLinesOne = ""
    for file in fileArr
      theFile = File.open(file)
      for line in theFile.readlines()
        boolean = false
        for pattern in patternsForF
          patternModified = pattern[1..pattern.length-2]
          if line.include?(patternModified) #there is a match
            boolean = true
          end
        end
        if boolean == false
          fixedStringsLinesOne += "#{line}"
          fixedStringsLines += "#{file}: #{line}"
        end
      end
      fixedStringsLinesOne += "\n"
      fixedStringsLines += "\n"
    end
    if fileArr.length == 1
      finalString = ""
      finalString += errorString
      finalString += fixedStringsLinesOne
      return finalString
    else
      finalString = ""
      finalString += errorString
      finalString += fixedStringsLines
      return finalString
    end
  end
  #########################################################################################################
  #Combination -F and -V and -C
  if optionArr.length == 3
    if ((optionArr.include?('-F') and optionArr.include?('-v') and optionArr.include?('-c'))) or
      ((optionArr.include?('-F')) and optionArr.include?('-v') and optionArr.include?('--count')) or
      ((optionArr.include?('-F')) and optionArr.include?('--invert-match') and optionArr.include?('-c')) or
      ((optionArr.include?('-F')) and optionArr.include?('--invert-match') and optionArr.include?('--count')) or
      ((optionArr.include?('--fixed-strings')) and optionArr.include?('-v') and optionArr.include?('-c')) or
      ((optionArr.include?('--fixed-strings')) and optionArr.include?('-v') and optionArr.include?('--count')) or
      ((optionArr.include?('--fixed-strings')) and optionArr.include?('--invert-match') and optionArr.include?('-c')) or
      ((optionArr.include?('--fixed-strings')) and optionArr.include?('--invert-match') and optionArr.include?('--count'))

      fixedStringsLines = ""
      fixedStringsLinesOne = ""
      for file in fileArr
        theFile = File.open(file)
        count = 0
        for line in theFile.readlines()
          boolean = false
          for pattern in patternsForF
            patternModified = pattern[1..pattern.length-2]
            if line.include?(patternModified) #there is a match
              boolean = true
            end
          end
          if boolean == false
            count += 1
          end
        end
        fixedStringsLinesOne += "#{count}\n"
        fixedStringsLines += "#{file}: #{count}\n"
      end
      if fileArr.length == 1
        finalString = ""
        finalString += errorString
        finalString += fixedStringsLinesOne
        return finalString
      else
        finalString = ""
        finalString += errorString
        finalString += fixedStringsLines
        return finalString
      end
    end
  end
  ############################################################################################################
  #Combination -A_NUM and -V
  if (optionArr.length == 2 and regexPatternWorkForA.match(optionArr[0]) and optionArr[1] == '-v') or 
     (optionArr.length == 2 and regexPatternWorkForA.match(optionArr[1]) and optionArr[0] == '-v') or 
    (optionArr.length == 2 and regexPatternForAfterContext.match(optionArr[0]) and optionArr[1] == '-v') or
    (optionArr.length == 2 and regexPatternForAfterContext.match(optionArr[1]) and optionArr[0] == '-v') or
    (optionArr.length == 2 and regexPatternWorkForA.match(optionArr[0]) and optionArr[1] == '--invert-match') or 
    (optionArr.length == 2 and regexPatternWorkForA.match(optionArr[1]) and optionArr[0] == '--invert-match') or 
    (optionArr.length == 2 and regexPatternForAfterContext.match(optionArr[0]) and optionArr[1] == '--invert-match') or
    (optionArr.length == 2 and regexPatternForAfterContext.match(optionArr[1]) and optionArr[0] == '--invert-match')
    if optionArr[0].start_with?("-A_")
      arrSplited = optionArr[0].split("_")
    end

    if optionArr[0].start_with?("--after-context")
      arrSplited = optionArr[0].split("=")
    end

    if optionArr[1].start_with?("-A_")
      arrSplited = optionArr[0].split("_")
    end

    if optionArr[1].start_with?("--after-context")
      arrSplited = optionArr[0].split("=")
    end

    count = (arrSplited[1]).to_i #The count of how many to go after
    matchesArray = ""
    if optionArr[0].start_with?("--after-context")
      arrSplited = optionArr[0].split("=")
    else
      arrSplited = optionArr[0].split("_")
    end

    count = (arrSplited[1]).to_i #The count of how many to go after
    finalArray = []
    finalArrayOne = []

    for file in fileArr #First Iteration to read the entire file
      theFile = File.open(file)
      readArray = theFile.readlines() #gets the stuff in a array
      tempString = ""
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        i = 0
        for line in readArray
          minimum = readArray.length-1
          if regexExpression.match(line) == nil #there is a match
            finalArray.append("#{file}: #{line}".delete("\n"))
            finalArrayOne.append("#{line}".delete("\n"))
            if minimum >= i + count #Gets the minimum of the 2
              minimum = i + count
            end
            (i+1..minimum).each do |indx| #Iterator in Ruby
              finalArray.append("#{file}: #{readArray[indx]}".delete("\n"))
              finalArrayOne.append("#{readArray[indx]}".delete("\n"))
            end
            finalArray.append("--")
            finalArrayOne.append("--")
          end
          i += 1
        end
     end
    end
    if fileArr.length == 1
      finalArrayOne.pop()
      matchesArray = finalArrayOne.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    else
      finalArray.pop()
      matchesArray = finalArray.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    end
  end
  ##################################################################################################
  #Combination of -B_NUM and -V
  if (optionArr.length == 2 and regexPatternWorkForB.match(optionArr[0]) and optionArr[1] == '-v') or 
    (optionArr.length == 2 and regexPatternWorkForB.match(optionArr[1]) and optionArr[0] == '-v') or 
   (optionArr.length == 2 and regexPatternForBeforeContext.match(optionArr[0]) and optionArr[1] == '-v') or
   (optionArr.length == 2 and regexPatternForBeforeContext.match(optionArr[1]) and optionArr[0] == '-v') or
   (optionArr.length == 2 and regexPatternWorkForB.match(optionArr[0]) and optionArr[1] == '--invert-match') or 
   (optionArr.length == 2 and regexPatternWorkForB.match(optionArr[1]) and optionArr[0] == '--invert-match') or 
   (optionArr.length == 2 and regexPatternForBeforeContext.match(optionArr[0]) and optionArr[1] == '--invert-match') or
   (optionArr.length == 2 and regexPatternForBeforeContext.match(optionArr[1]) and optionArr[0] == '--invert-match')
   if optionArr[0].start_with?("-B_")
    arrSplited = optionArr[0].split("_")
   end

   if optionArr[0].start_with?("--before-context")
    arrSplited = optionArr[0].split("=")
   end

   if optionArr[1].start_with?("-B_")
    arrSplited = optionArr[0].split("_")
   end

   if optionArr[1].start_with?("--before-context")
    arrSplited = optionArr[0].split("=")
   end

   matchesArray = ""

   count = (arrSplited[1]).to_i #The count of how many to go after
   finalArray = []
    finalArrayOne = []

    for file in fileArr #First Iteration to read the entire file
      theFile = File.open(file)
      readArray = theFile.readlines() #gets the stuff in a array
      for pattern in patternArr
        patternModified = pattern[1..pattern.length-2]
        regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
        i = 0
        for line in readArray
          maximum = 0
          if regexExpression.match(line) == nil #there is a match
            finalArray.append("#{file}: #{line}".delete("\n"))
            finalArrayOne.append("#{line}".delete("\n"))
            if maximum <= i - count #Gets the minimum of the 2
              maximum = i - count
            end
            tempIndx = i
            while tempIndx > maximum
              tempIndx = tempIndx - 1
              finalArray.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
              finalArrayOne.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
              end
            finalArray.append("--")
            finalArrayOne.append("--")
          end
          i += 1
        end
      end
    end
    if fileArr.length == 1
      finalArrayOne.pop()
      matchesArray = finalArrayOne.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesArray
      return finalString
    else
      finalArray.pop()
      matchesString = finalArray.join("\n")
      finalString = ""
      finalString += errorString
      finalString += matchesString
      return finalString
    end
  end

  if (optionArr.length == 2 and regexPatternWorkForC.match(optionArr[0]) and optionArr[1] == '-v') or 
    (optionArr.length == 2 and regexPatternWorkForC.match(optionArr[1]) and optionArr[0] == '-v') or 
   (optionArr.length == 2 and regexPatternForAfterAndBeforeContext.match(optionArr[0]) and optionArr[1] == '-v') or
   (optionArr.length == 2 and regexPatternForAfterAndBeforeContext.match(optionArr[1]) and optionArr[0] == '-v') or
   (optionArr.length == 2 and regexPatternWorkForC.match(optionArr[0]) and optionArr[1] == '--invert-match') or 
   (optionArr.length == 2 and regexPatternWorkForC.match(optionArr[1]) and optionArr[0] == '--invert-match') or 
   (optionArr.length == 2 and regexPatternForAfterAndBeforeContext.match(optionArr[0]) and optionArr[1] == '--invert-match') or
   (optionArr.length == 2 and regexPatternForAfterAndBeforeContext.match(optionArr[1]) and optionArr[0] == '--invert-match')
   if optionArr[0].start_with?("-C_")
    arrSplited = optionArr[0].split("_")
   end

   if optionArr[0].start_with?("--context=")
    arrSplited = optionArr[0].split("=")
   end

   if optionArr[1].start_with?("-C_")
    arrSplited = optionArr[0].split("_")
   end

   if optionArr[1].start_with?("--context=")
    arrSplited = optionArr[0].split("=")
   end
   finalArray = []
   finalArrayOne = []
   matchesArray = ""
   count = (arrSplited[1]).to_i #The count of how many to go after

   for file in fileArr #First Iteration to read the entire file
    theFile = File.open(file)
    readArray = theFile.readlines() #gets the stuff in a array
    for pattern in patternArr
      patternModified = pattern[1..pattern.length-2]
      regexExpression = Regexp.new(patternModified) #makes a new reg expression from a string
      i = 0
      for line in readArray
        maximum = 0
        minimum = readArray.length-1
        if regexExpression.match(line) == nil #there is a match
          finalArray.append("#{file}: #{line}".delete("\n"))
          finalArrayOne.append("#{line}".delete("\n"))
          if maximum <= i - count #Gets the minimum of the 2
            maximum = i - count
          end
          if minimum >= i + count #Gets the minimum of the 2
            minimum = i + count
          end
          tempIndx = i
          while tempIndx > maximum
            tempIndx = tempIndx - 1
            finalArray.append("#{file}: #{readArray[tempIndx]}".delete("\n"))
            finalArrayOne.append("#{readArray[tempIndx]}".delete("\n"))
            end
          (i+1..minimum).each do |indx| #Iterator in Ruby
            finalArray.append("#{file}: #{readArray[indx]}".delete("\n"))
            finalArrayOne.append("#{readArray[indx]}".delete("\n"))
          end
          finalArray.append("--")
          finalArrayOne.append("--")
        end
        i += 1
      end
    end
  end
  if fileArr.length == 1
    finalArrayOne.pop()
    matchesArray = finalArrayOne.join("\n")
    finalString = ""
    finalString += errorString
    finalString += matchesArray
    return finalString
  else
    finalArray.pop()
    matchesString = finalArray.join("\n")
    finalString = ""
    finalString += errorString
    finalString += matchesString
    return finalString
  end
end
  return "USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>"   
end

args = ['-A_2','"^two"','tests/test1.txt']#testing input
parseArgs(args) #To test