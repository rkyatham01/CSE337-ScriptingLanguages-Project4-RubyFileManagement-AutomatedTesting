#  gem install simplecov for coverage
# uncomment the following two lines to generate coverage report
require 'simplecov'
SimpleCov.start
require_relative File.join("..", "src", "rugrep")

# write rspec tests
describe 'parseArgs' do
    it 'Invalid Options Error, should return USAGE' do
        regexPatt = '"^code"'
        option = '-bcv'
        path1 = File.join('tests', 'test1.txt')

        File.open(path1, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, regexPatt, path1])
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Invalid Args Length Error, should return USAGE' do
        path = File.join('tests', 'test1.txt')
    
        File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([path])
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Invalid Length for -A-B-C_, should return USAGE' do

        regexPatt = '"^code"'
        option = '-A_2A'
        path = File.join('tests', 'test1.txt')

        File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, regexPatt, path])
       # File.delete(path)

        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Invalid Length 2 or not equal to for splitArr for -A_, should return USAGE' do

        regexPatt = '"^code"'
        option = '-A_2_3'
        path = File.join('tests', 'test1.txt')

        File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, regexPatt, path])
       # File.delete(path)

        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Invalid Length for --after-context=, should return USAGE' do
        regexPatt = '"^code"'
        option = '--after-context=22asd'
        path = File.join('tests', 'test1.txt')
    
         File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, regexPatt, path])
       # File.delete(path)
    
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Invalid Length for --after-context=, should return USAGE' do
        regexPatt = '"^code"'
        option = '--after-context=22=5'
        path = File.join('tests', 'test1.txt')
    
         File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, regexPatt, path])
       # File.delete(path)
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'No patterns passed, should return USAGE' do
        path = File.join('tests', 'test1.txt')
        option = '-v'
         File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([option, path])
      #  File.delete(path)
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    it 'Contigous Patterns check' do
        path = File.join('tests', 'test1.txt')
        option = '-v'
        pattern1 = '"^start"'
        pattern2 = '"wee"'
        pattern3 = '"what"'
         File.open(path, 'w') do |file|
            file.puts 'sgaaag 1sad gaas gag agawg'
            file.puts 'secondsagasg asgdsagda gaassdg'
        end
        output = parseArgs([pattern1,pattern2, option, path, pattern3])
      #  File.delete(path)
        expect(output).to eq('USAGE: ruby rugrep.rb <OPTIONS> <PATTERNS> <FILES>')
    end
    #################################################################################
    #Test Cases for -V 
      it '-v For a single file' do
        options = '-v'
        regex = '"pattern"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
          file.puts 'this is not a test'
          file.puts 'gonna use this for pattern in file'
          file.puts 'two files being used'
          file.puts 'pattern is here'
        end
        output = parseArgs([options,regex, path])
        correctOutput = []
        answerString = "this is not a test\n" 
        answerString += "two files being used\n"
        #File.delete(path)
        expect(output).to eq(answerString)
    end

    it '-v For multiple files' do
        options = '-v'
        regex = '"pattern"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
          file.puts 'this is not a test'
          file.puts 'gonna use this for pattern in file'
          file.puts 'two files being used'
          file.puts 'pattern is here'
        end

        path2 = File.join('tests', 'test2.txt')
        File.open(path2, 'w') do |file2|
          file2.puts "this pattern be the second file"
          file2.puts "the pattern is here"
          file2.puts "some random file is here"
          file2.puts "I don't want pattern know"
        end

        output = parseArgs([options,regex, path, path2])
        correctString = ""
        correctString += "tests/test1.txt: this is not a test\n"
        correctString += "tests/test1.txt: two files being used\n\n"
        correctString += "tests/test2.txt: some random file is here\n"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end
    #################################################################################
    #Test Cases for -C
    it '-c For a single file' do
        options = '-c'
        regex = '"pattern"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
          file.puts 'this is not a test'
          file.puts 'gonna use this for pattern in file'
          file.puts 'two files being used'
        end
        output = parseArgs([options,regex, path])
        count = "1"
        #File.delete(path)
        expect(output).to eq(count)
    end

     it '-c For multiple files' do
         options = '--count'
         regex = '"pattern"'
         path = File.join('tests', 'test1.txt')
         File.open(path, 'w') do |file|
            file.puts 'this is not a test'
            file.puts 'gonna use this for pattern in file'
            file.puts 'two files being used'
         end

        path2 = File.join('tests', 'test2.txt')
        File.open(path2, 'w') do |file2|
          file2.puts "this pattern be the second file"
          file2.puts "the pattern is here"
          file2.puts "some random file is here"
          file2.puts "I don't want pattern know"
        end

        output = parseArgs([options,regex, path, path2])
        correctString = ""
        correctString += "tests/test1.txt: 1\n"
        correctString += "tests/test2.txt: 3"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end

    #################################################################################
    #Test Cases for -l
    it '-l for files' do
         options = '-l'
         regex = '"pattern"'
         path = File.join('tests', 'test1.txt')
         File.open(path, 'w') do |file|
            file.puts 'this is not a test'
            file.puts 'gonna use this for pattern in file'
            file.puts 'two files being used'
         end

        path2 = File.join('tests', 'test2.txt')
        File.open(path2, 'w') do |file2|
          file2.puts "this pattern be the second file"
          file2.puts "the pattern is here"
          file2.puts "I don't want pattern know"
        end

        output = parseArgs([options,regex, path, path2])
        correctString = ""
        correctString += "tests/test1.txt\n"
        correctString += "tests/test2.txt"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end

    #################################################################################
    #Test Cases for -L
    it '-L for files' do
        options = '-L'
        regex = '"pattern"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
           file.puts 'this is not a test'
           file.puts 'gonna use this for pattern in file'
           file.puts 'two files being used'
        end

       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "this pattern be the second file"
         file2.puts "the pattern is here"
         file2.puts "I don't want pattern know"
       end

       output = parseArgs([options,regex, path, path2])
       correctString = "" 
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
   end

   it '-L for files again' do
    options = '--files-without-match'
    regex = '"pattern"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
       file.puts 'this is not a test'
       file.puts 'gonna use this for pattern in file'
       file.puts 'two files being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "this pattern be the second file"
     file2.puts "the pattern is here"
     file2.puts "I don't want pattern know"
   end

   output = parseArgs([options,regex, path, path2])
   correctString = "" 
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
end
    #################################################################################
    #Test Cases for -o
    it '-o for multiple files' do
        options = '-o'
        regex = '"^foundhere"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^pattern not a test'
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two ^foundhere being used'
        end
        output = parseArgs([options,regex, path])
        correctString = ""
        correctString += "^foundhere\n"
        correctString += "^foundhere\n"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end

    it '-o for multiple files' do
        options = '--only-matching'
        regex = '"^foundhere"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
           file.puts 'this ^pattern not a test'
           file.puts 'gonna use this for ^foundhere file'
           file.puts 'two ^foundhere being used'
        end

       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "this pattern be the second file"
         file2.puts "the ^foundhere is here"
         file2.puts "I don't want pattern know"
       end

       output = parseArgs([options,regex, path, path2])
       correctString = ""
       correctString += "tests/test1.txt: ^foundhere\n"
       correctString += "tests/test1.txt: ^foundhere\n"
       correctString += "tests/test2.txt: ^foundhere\n"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
   end
    #################################################################################
    #Test Cases for -F
    it '-F for a single file' do
        options = '-F'
        regex = '"^foundhere"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
        end
        output = parseArgs([options,regex, path])
        correctString = ""
        correctString += "this ^foundhere not a ^foundhere\n"
        correctString += "gonna use this for ^foundhere file\n"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end

    it '-F for multiple files' do
        options = '--fixed-strings'
        regex = '"^foundhere"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
        end

       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "this pattern be the second file"
         file2.puts "the ^foundhere is here"
         file2.puts "I don't want pattern know"
       end

       output = parseArgs([options,regex, path, path2])
       correctString = ""
       correctString += "tests/test1.txt: this ^foundhere not a ^foundhere\n"
       correctString += "tests/test1.txt: gonna use this for ^foundhere file\n"
       correctString += "tests/test2.txt: the ^foundhere is here\n"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
   end
   #################################################################################
    #A NUM TESTS
    it '-A_NUM for a single file' do
        options = '-A_2'
        regex = '"^two"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'two not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([options,regex, path])
        correctString = "two not here being used\ntwo not here thematch being used\nthis is random file\n--\ntwo not here thematch being used\nthis is random file"
        #File.delete(path)
        #File.delete(path2)
        expect(output).to eq(correctString)
    end

it '-A_NUM for multiple files' do
    options = '--after-context=2'
    regex = '"^two"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts 'gonna use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "this pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "I don't want pattern know"
   end

   output = parseArgs([options,regex, path, path2])
   correctString = "tests/test1.txt: two not here being used"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
end
    #################################################################################
    #B NUM TESTS
      it '-B_NUM for a single file' do
        options = '-B_2'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([options,regex, path])
        correctString = "abrev not here thematch being used\ntests/test1.txt: two not here being used\ntests/test1.txt: gonna use this for ^foundhere file"
        expect(output).to eq(correctString)
    end

  it '-B_NUM for multiple files' do
    options = '-B_2'
    regex = '"^abrev"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts 'abrev use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "abrev pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "two don't want pattern know"
   end

   output = parseArgs([options,regex, path, path2])
   correctString = "tests/test1.txt: abrev use this for ^foundhere file\ntests/test1.txt: this ^foundhere not a ^foundhere\n--\ntests/test2.txt: abrev pattern be the second file"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
  end

    #################################################################################
    #C NUM TESTS
    it '-C_NUM for a single file' do
        options = '-C_2'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([options,regex, path])
        correctString = "abrev not here thematch being used\ntwo not here being used\ngonna use this for ^foundhere file\nthis is random file"
        expect(output).to eq(correctString)
    end

  it '-C_NUM for multiple files' do
    options = '-C_2'
    regex = '"^this"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts 'abrev use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "abrev pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "two don't want pattern know"
   end

   output = parseArgs([options,regex, path, path2])
   correctString = "tests/test1.txt: this ^foundhere not a ^foundhere\ntests/test1.txt: abrev use this for ^foundhere file\ntests/test1.txt: two not here being used"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
  end

    #################################################################################
    #-C and -V Tests
    it '-C and -V tests for a single file' do
        option1 = '-c'
        option2 = '-v'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,regex, path])
        correctString = "3\n"
        expect(output).to eq(correctString)
    end

  it '-C and -V tests for multiple files' do
    option1 = '-c'
    option2 = '-v'
    regex = '"^abrev"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts 'abrev use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "abrev pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "two don't want pattern know"
   end

   output = parseArgs([option1, option2,regex, path, path2])
   correctString = "tests/test1.txt 2\ntests/test2.txt 2\n"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
  end

    #################################################################################
    #-C and -O Tests
    it '-C and -O tests for a single file' do
        option1 = '-c'
        option2 = '-o'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,regex, path])
        correctString = "1\n"
        expect(output).to eq(correctString)
    end

  it '-C and -O tests for multiple files' do
    option1 = '-c'
    option2 = '-o'
    regex = '"^abrev"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts 'abrev use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "abrev pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "two don't want pattern know"
   end

   output = parseArgs([option1, option2,regex, path, path2])
   correctString = "tests/test1.txt: 1\ntests/test2.txt: 1\n"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
  end
    #################################################################################
    #-F and -c Tests
    it '-F and -c tests for a single file' do
        option1 = '-F'
        option2 = '-c'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,regex, path])
        correctString = "0\n"
        expect(output).to eq(correctString)
    end

  it '-F and -c tests for multiple files' do
    option1 = '-F'
    option2 = '-c'
    regex = '"^abrev"'
    path = File.join('tests', 'test1.txt')
    File.open(path, 'w') do |file|
        file.puts 'this ^foundhere not a ^foundhere'
        file.puts '^abrev use this for ^foundhere file'
        file.puts 'two not here being used'
    end

   path2 = File.join('tests', 'test2.txt')
   File.open(path2, 'w') do |file2|
     file2.puts "abrev pattern be the second file"
     file2.puts "the ^foundhere is here"
     file2.puts "two don't want pattern know"
   end

   output = parseArgs([option1, option2,regex, path, path2])
   correctString = "tests/test1.txt: 1\ntests/test2.txt: 0\n"
   #File.delete(path)
   #File.delete(path2)
   expect(output).to eq(correctString)
  end

    #################################################################################
    #-F and -o Tests
    it '-F and -o tests for a single file' do
        option1 = '-F'
        option2 = '-o'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,regex, path])
        correctString = "abrev\n"
        expect(output).to eq(correctString)
    end

    it '-F and -o tests for multiple files' do
        option1 = '-F'
        option2 = '-o'
        regex = '"^abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
            file.puts 'two not here being used'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
         file2.puts "two don't want pattern know"
       end
    
       output = parseArgs([option1, option2,regex, path, path2])
       correctString = "tests/test1.txt: ^abrev\n"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end
    #################################################################################
    #-F and -v Tests
    it '-F and -v tests for a single file' do
        option1 = '-F'
        option2 = '-v'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,regex, path])
        correctString = "gonna use this for ^foundhere file\ntwo not here being used\nthis is random file\n\n"
        expect(output).to eq(correctString)
    end

    it '-F and -v tests for multiple files' do
        option1 = '-F'
        option2 = '-v'
        regex = '"use"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
       end
    
       output = parseArgs([option1, option2,regex, path, path2])
       correctString = "tests/test1.txt: this ^foundhere not a ^foundhere\n\ntests/test2.txt: abrev pattern be the second file\ntests/test2.txt: the ^foundhere is here\n\n"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end

    #################################################################################
    #-F and -c and -v Tests
    it '-F and -c and -v tests for a single file' do
        option1 = '-F'
        option2 = '-v'
        option3 = '-c'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'abrev not here thematch being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2,option3, regex, path])
        correctString = "3\n"
        expect(output).to eq(correctString)
    end

    it '-F and -c and -v tests for multiple files' do
        option1 = '-F'
        option2 = '-v'
        option3 = '-c'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
       end
    
       output = parseArgs([option1, option2,option3, regex, path, path2])
       correctString = "tests/test1.txt: 1\ntests/test2.txt: 1\n"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end
    ##################################################################
    # A_NUM and -V tests F
    it '-A_NUM and -V tests for a single file' do
        option1 = '-A_2'
        option2 = '-v'
        regex = '"^two"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2, regex, path])
        correctString = "gonna use this for ^foundhere file\ntwo not here being used\nthis is random file\n--\nthis is random file"
        expect(output).to eq(correctString)
    end

    it '-A_NUM and -V tests for multiple files' do
        option1 = '-A_2'
        option2 = '-v'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
       end
    
       output = parseArgs([option1, option2, regex, path, path2])
       correctString = "tests/test1.txt: this ^foundhere not a ^foundhere\ntests/test1.txt: ^abrev use this for ^foundhere file\n--\ntests/test2.txt: the ^foundhere is here"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end
    ##################################################################
    # B_NUM and -V tests F
    it '-B_NUM and -V tests for a single file' do
        option1 = '-B_2'
        option2 = '-v'
        regex = '"^two"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2, regex, path])
        correctString = "gonna use this for ^foundhere file\n--\nthis is random file\ntests/test1.txt: two not here being used\ntests/test1.txt: gonna use this for ^foundhere file"
        expect(output).to eq(correctString)
    end

    it '-B_NUM and -V tests for multiple files' do
        option1 = '-B_2'
        option2 = '-v'
        regex = '"abrev"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
       end
    
       output = parseArgs([option1, option2, regex, path, path2])
       correctString = "tests/test1.txt: this ^foundhere not a ^foundhere\n--\ntests/test2.txt: the ^foundhere is here\ntests/test2.txt: abrev pattern be the second file"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end
    ##################################################################
    # B_NUM and -V tests F
    it '-C_NUM and -V tests for a single file' do
        option1 = '-C_2'
        option2 = '-v'
        regex = '"^two"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'gonna use this for ^foundhere file'
            file.puts 'two not here being used'
            file.puts 'this is random file'
        end
        output = parseArgs([option1, option2, regex, path])
        correctString ="gonna use this for ^foundhere file\ntwo not here being used\nthis is random file\n--\nthis is random file\ntwo not here being used\ngonna use this for ^foundhere file"
        expect(output).to eq(correctString)
    end

    it '-C_NUM and -V tests for multiple files' do
        option1 = '-C_2'
        option2 = '-v'
        regex = '"this"'
        path = File.join('tests', 'test1.txt')
        File.open(path, 'w') do |file|
            file.puts 'this ^foundhere not a ^foundhere'
            file.puts '^abrev use this for ^foundhere file'
        end
    
       path2 = File.join('tests', 'test2.txt')
       File.open(path2, 'w') do |file2|
         file2.puts "abrev pattern be the second file"
         file2.puts "the ^foundhere is here"
       end
    
       output = parseArgs([option1, option2, regex, path, path2])
       correctString = "tests/test2.txt: abrev pattern be the second file\ntests/test2.txt: the ^foundhere is here\n--\ntests/test2.txt: the ^foundhere is here\ntests/test2.txt: abrev pattern be the second file"
       #File.delete(path)
       #File.delete(path2)
       expect(output).to eq(correctString)
    end
end
    
