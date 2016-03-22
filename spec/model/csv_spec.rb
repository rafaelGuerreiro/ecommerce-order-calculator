require_relative '../../app/model/csv.rb'

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

    it 'allows relative file path no matter if there is extension or not' do
      csv = Csv.new('../folder/a.file.csv')
      expect(csv.file_path).to eq('../folder/a.file.csv')

      csv = Csv.new('../folder/another.file')
      expect(csv.file_path).to eq('../folder/another.file.csv')
    end

    it 'allows trailing spaces in the file path no matter ' \
    'if there is extension or not' do
      csv = Csv.new(' ../folder/a.file.csv   ')
      expect(csv.file_path).to eq('../folder/a.file.csv')

      csv = Csv.new(' ../folder/another.file   ')
      expect(csv.file_path).to eq('../folder/another.file.csv')
    end

    it 'cannot modify the original string' do
      file_path = 'the_file'
      csv = Csv.new file_path

      expect(file_path).to eq('the_file')
      expect(csv.file_path).to eq('the_file.csv')
    end

    it 'cannot have an empty or nil file path' do
      expect { Csv.new nil }
        .to raise_error(StandardError, 'File path is required')

      expect { Csv.new '' }
        .to raise_error(StandardError, 'File path is required')

      expect { Csv.new '  ' }
        .to raise_error(StandardError, 'File path is required')
    end
  end

  describe '#file_path' do
    it 'must be immutable' do
      csv = Csv.new('../folder/a.file.csv')

      expect { csv.file_path << 'teste' }
        .to raise_error(RuntimeError, "can't modify frozen String")
    end
  end
end
