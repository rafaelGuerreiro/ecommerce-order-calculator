require 'csv'

class CsvFile
  attr_reader :model, :file_path

  def initialize(model, file_path)
    return if file_path.blank?

    file_path = file_path.strip
    file_path += '.csv' unless file_path.end_with? '.csv'

    @file_path = file_path.freeze
    @model = model if model.is_a?(Class) && model < CsvModel::Base
  end

  def self.enclosing_folder_for(file)
    file.tr('\\', '/').gsub(%r{/[^/]*\.csv\z}, '') if file.present?
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

  def csv_header
    return [] if @model.fields.blank?

    @model.fields.map(&:name)
  end

  def enclosing_folder
    return if invalid?

    self.class.enclosing_folder_for(@file_path)
  end
end
