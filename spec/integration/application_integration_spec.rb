describe Application, :integration do
  describe '#serialize_result' do
    it 'customizes the order for the result' do
      paths = %w(coupons products orders order_items).map do |file|
        "spec/integration/csvs/#{file}"
      end
      paths << 'spec/integration/csvs/result.csv'

      app = Application.new paths
      app.load_models

      # app.serialize_result
    end
  end
end
