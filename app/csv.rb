class Csv
  attr_accessor :file_path

  def initialize(file_path)
    file_path += '.csv' unless /\A.*?\.csv\z/ =~ file_name

    @file_path = file_path
  end
end
