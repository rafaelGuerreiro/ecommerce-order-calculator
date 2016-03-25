module CsvFile
  module Helper
    def stub_csv_file(file_path, csv_data)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:open).and_call_original

      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(File).to receive(:open)
        .with(file_path, universal_newline: false)
        .and_return(StringIO.new(csv_data))
    end
  end
end
