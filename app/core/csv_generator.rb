require 'fileutils'
require_relative 'csv_file'

class CsvGenerator
  def initialize(model, file_path)
    @model = model
    @file = CsvFile.new(model, file_path)
  end

  def dump_csv(&block)
    return if @file.invalid?

    FileUtils.makedirs @file.path

    CSV.open(@file.file_path, 'w') do |csv|
      populate_csv(csv, &block)
    end
  end

  private

  def populate_csv(csv)
    @model.each do |model|
      csv << if block_given?
               yield(model)
             else
               to_array(model)
             end
    end
  end

  def to_array(model)
    @file.csv_header.map do |attribute|
      value = model.__send__(attribute)

      value = value.strftime '%Y/%m/%d' if value.is_a?(Date)
      value = value.id if value.is_a?(CsvModel::Base)

      value.to_s
    end
  end
end
