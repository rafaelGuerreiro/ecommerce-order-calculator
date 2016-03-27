describe Application, :integration do
  describe '#serialize_result' do
    it 'customizes the orders for the result' do
      paths = %w(coupons products orders order_items).map do |file|
        "spec/integration/csvs/#{file}"
      end
      paths << result_path = '/csvs/result.csv'

      app = Application.new paths
      app.load_models

      target = stub_csv_writing_target result_path

      app.serialize_result do |file_path|
        expect(file_path).to eq(result_path)
      end

      expect(target).to contain_exactly(
        [123, 2_250.0],
        [234, 216.75],
        [345, 314.5],
        [456, 427.5],
        [567, 525.0],
        [678, 2_227.5],
        [789, 12_460.0],
        [890, 300.0],
        [987, 150.0],
        [1000, 0.0],
        [1001, 0.0]
      )
    end
  end
end
