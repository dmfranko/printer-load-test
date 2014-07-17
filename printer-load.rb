require 'securerandom'
require 'fileutils'
require 'work_queue'
require 'byebug'

if ARGV.length < 3
  puts "You must supply 3 arguments [print_server][concurrent_printers][jobs_for_each]"
  # Can't go on without the proper args
  exit
end

print_server = ARGV[0]
puts "Starting with #{ARGV[1]} concurrent printers for #{ARGV[2]} jobs each and a total of #{ARGV[0].to_i * ARGV[1].to_i} jobs against '#{print_server}'"

files_path = File.join(File.expand_path File.dirname(__FILE__),"files")

# This controls the concurrency
wq = WorkQueue.new ARGV[1].to_i

# Setup the printers Mac/Linux only
# Need to figure out similar command for Windows

printers = []
ARGV[1].to_i.times do |x|
  printer = "TESTPRINTER#{x}"
  printers << printer
  `/usr/sbin/lpadmin -p "#{printer}" -E -v "lpd://#{print_server}" -P "/System/Library/Frameworks/ApplicationServices.framework/Frameworks/PrintCore.framework/Resources/Generic.ppd" -D "#{printer}"`
end

# Counter of total submitted jobs
@count = 0
start_time = Time.now

# How many times to go through printing
ARGV[2].to_i.times do
  printers.each do |p|
    sleep rand(1..2)
    wq.enqueue_b do
      
      # Pick a file at random from the directory
      file = Dir.entries(files_path).select {|f| !File.directory? f}.sample 
      
      # Loop until the printer is ready
      while ! `lpstat -p #{p}`.include?("idle")
	      puts "printer '#{p}' status is #{`lpstat -p #{p}`}"
	      sleep 0.5
      end
      `lpr "#{File.join(files_path,file)}" -P  #{p}`
	    
      # Increment the counter of submitted jobs
      @count+=1
      # Sleep randomly between 10 and 15 seconds
      sleep rand(10..15) 
    end
  end
  
  # Join the threads
  wq.join
end

puts "Total count: #{@count}" 

end_time = Time.now

puts "Start Time : #{start_time}"
puts "End Time : #{end_time}"

puts "Total Duration : #{end_time - start_time} seconds"
