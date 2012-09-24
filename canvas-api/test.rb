require './canvas.rb'
def choose_from_list(list, prompt_text = 'Please choose one: ')
  input = -1
  while input < 1 || input > list.length do
    list.each_with_index do |l,i|
      puts "  #{i+1}. #{l}"
    end
    print prompt_text
    input = gets.to_i
  end
  return list[input - 1]
end

API_KEY = '<YOUR API KEY HERE>'
c = Canvas::Client.new(API_KEY)
onethirtyone = c.courses.first
assignments = onethirtyone.assignments

# Ask how many students' files to sample.
num = 0
while num <= 0
  puts "Sample How Many Students..."
  num = gets.to_i
end

continue = true
puts "Choose an Assignment to Verify..."
a = choose_from_list(assignments)

sections = onethirtyone.sections
sections.each do |section|
  puts "===================================================="
  puts "===================================================="
  puts "===================================================="
  puts "Section: #{section}"
  a.submissions(section: section, with: ['submission_comments']).sample(5).each do |s|
    puts "User ID: #{s.user_id}"
    puts "Grade: #{s.score}"
    s.attachments.each do |a|
      puts "| - Downloading... #{a.filename}"
      `wget "#{a.url}" -O outfile --quiet`
      `unzip -q outfile -d out`
      puts "| - Extracted file... #{a.filename}"
      puts "| - Comments:\n------------------"
      s.submission_comments.each do |c|
        puts "#{c.comment}\n-----"
      end
      gets
      `rm -rf out/*`
    end
    puts "------------------------------------------------"
  end
end

