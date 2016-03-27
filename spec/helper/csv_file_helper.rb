module CsvFileHelper
  def stub_csv_file(*configurations)
    allow_call_original(CSV => :read, File => :exist?)

    configurations.each do |config|
      stub_csv_reading_file config
    end
  end

  def stub_csv_writing_target(file_path, target = [])
    allow_call_original(CSV => :open, FileUtils => :makedirs)

    allow(CSV).to receive(:open).with(file_path, 'w').and_yield(target)
    allow(FileUtils).to receive(:makedirs)
      .with(CsvFile.enclosing_folder_for(file_path)).and_return(nil)

    target
  end

  private

  def allow_call_original(hash)
    hash.each do |clazz, method|
      allow(clazz).to receive(method).and_call_original
    end
  end

  def stub_csv_reading_file(config)
    allow(File).to receive(:exist?).with(config[:file_path]).and_return(true)
    allow(CSV).to receive(:read).with(config[:file_path])
      .and_return(config[:csv_data].map { |row| row.split(',') })
  end
end
