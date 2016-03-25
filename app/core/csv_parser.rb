class CsvParser
  attr_accessor :file_path

  def initialize(model, file_path)
    return if file_path.nil? || file_path.strip.empty?

    file_path = file_path.strip
    file_path += '.csv' unless file_path.end_with? '.csv'

    @file_path = file_path.freeze
    @model = model
  end

  def valid?
    !file_path.nil?
  end

  def invalid?
    !valid?
  end
end
