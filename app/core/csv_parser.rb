require 'csv'

class CsvParser
  attr_accessor :file_path

  def initialize(model, file_path)
    return if file_path.blank?

    file_path = file_path.strip
    file_path += '.csv' unless file_path.end_with? '.csv'

    @file_path = file_path.freeze
    @model = model if model.respond_to?(:<) && model < CsvModel::Base
  end

  def valid?
    file_path.present? && @model.present?
  end

  def invalid?
    !valid?
  end

  def csv_exists?
    File.exist?(@file_path)
  end

  def parse_csv
    return [] if invalid?

    header = csv_header

    return [] if header.blank? || !csv_exists?

    models = []
    CSV.read(@file_path).each do |fields|
      models << @model.new(to_hash(header, fields))
    end

    models
  end

  private

  def csv_header
    return [] if @model.fields.blank?

    @model.fields.map(&:name)
  end

  def to_hash(header, fields)
    Hash[*header.zip(fields).flatten]
  end
end
