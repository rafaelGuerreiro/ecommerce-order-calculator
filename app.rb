#!/usr/bin/ruby

require_relative 'app/application'

begin
  app = Application.new(ARGV)

  app.load_models do |clazz, file_path|
    puts "Loaded #{clazz} from #{file_path}"
  end

  app.serialize_result do |file_path|
    puts "Finished dumping orders into #{file_path}"
  end
rescue ArgumentError => e
  puts "FATAL ERROR => #{e.message}"
end
