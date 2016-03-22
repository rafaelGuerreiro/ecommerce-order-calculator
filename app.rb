csvs = []
ARGV.each do |file_name|
  csvs << file_name
end

puts csvs.inspect
