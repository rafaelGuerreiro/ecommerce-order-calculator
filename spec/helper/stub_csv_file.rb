module CsvFileHelper
  def stub_csv_file(file_path, csv_data)
    allow_call_original

    allow(File).to receive(:exist?).with(file_path).and_return(true)
    stub = allow(CSV).to receive(:read).with(file_path)
      .and_return(csv_data.map { |row| row.split(',') })
  end

  private

  def allow_call_original
    allow(File).to receive(:exist?).and_call_original
    allow(CSV).to receive(:read).and_call_original
  end
end
