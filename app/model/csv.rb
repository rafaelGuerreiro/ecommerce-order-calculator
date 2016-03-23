class Csv
  attr_accessor :file_path

  def initialize(file_path)
    if file_path.nil? || file_path.strip.empty?
      return
    end

    file_path = file_path.strip
    file_path += '.csv' unless file_path.end_with? '.csv'

    @file_path = file_path.freeze
  end

  def valid?
    !file_path.nil?
  end

  def invalid?
    !valid?
  end
end
