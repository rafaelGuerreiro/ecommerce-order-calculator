require_relative '../../app/csv.rb'

describe Csv, :model do
  describe '.new' do
    it 'allows file path without extension' do
      csv = Csv.new('file_name')
      expect(csv.file_path).to eq('file_name.csv')
    end

    it 'allows file path with csv extension' do
      csv = Csv.new('other file.csv')
      expect(csv.file_path).to eq('other file.csv')
    end

    it 'allows relative file path no matter the extension' do
      csv = Csv.new('../folder/a.file.csv')
      expect(csv.file_path).to eq('../folder/a.file.csv')
    end
  end
end
