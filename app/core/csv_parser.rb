require_relative 'csv_file'

class CsvParser
  def initialize(model, file_path)
    @file = CsvFile.new(model, file_path)
  end

  def parse_csv
    return [] if @file.invalid?

    header = @file.csv_header

    return [] if header.blank? || !@file.csv_exists?

    models = []
    CSV.read(@file.file_path).each do |fields|
      models << @file.model.new(to_hash(header, fields))
    end

    models
  end

  private

  def to_hash(header, fields)
    Hash[*header.zip(fields).flatten]
  end
end
