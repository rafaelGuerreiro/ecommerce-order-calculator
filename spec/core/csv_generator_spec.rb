describe CsvGenerator do
  describe '#dump_csv' do
    it 'does nothing when csv file is invalid' do
      target = csv_writing_target

      generator = CsvGenerator.new(Order, nil)
      expect(generator.dump_csv).to be_nil
      expect(target).to be_empty

      generator = CsvGenerator.new(String, '/result.csv')
      expect(generator.dump_csv).to be_nil
      expect(target).to be_empty
    end
  end

  private

  def csv_writing_target(target = [])
    allow(CSV).to receive(:open).with('/result.csv', 'w').and_yield(target)
    allow(FileUtils).to receive(:makedirs).with('/', 'w').and_return(nil)

    target
  end

  def stub_call_original
    allow(CSV).to receive(:open).and_call_original
    allow(FileUtils).to receive(:makedirs).and_call_original
  end
end
