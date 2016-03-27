module CsvFileHelper
  def stub_csv_file(file_path, csv_data)
    allow_call_original(CSV => :read, File => :exist?)

    allow(File).to receive(:exist?).with(file_path).and_return(true)
    allow(CSV).to receive(:read).with(file_path)
      .and_return(csv_data.map { |row| row.split(',') })
  end

  def stub_csv_writing_target(target = [])
    allow_call_original(CSV => :open, FileUtils => :makedirs)

    allow(CSV).to receive(:open).with('tmp/result.csv', 'w').and_yield(target)
    allow(FileUtils).to receive(:makedirs).with('tmp').and_return(nil)

    target
  end

  private

  def allow_call_original(hash)
    hash.each do |clazz, method|
      allow(clazz).to receive(method).and_call_original
    end
  end
end
