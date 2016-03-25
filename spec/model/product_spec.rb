describe Product, :model do
  describe '.fields' do
    it 'returns the header used for parsing the csv' do
      fields = Product.fields
      expect(fields).to have(2).fields

      expect(fields[0].name).to eq(:id)
      expect(fields[1].name).to eq(:value)
    end
  end

  describe '.load' do
    before do
      csv_data = [
        '123,150.0',
        '234,225.0',
        '345,250.0',
        '456,175.0',
        '567,100.0',
        '678,80.0',
        '789,2400.0',
        '890,75.0',
        '987,100.0',
        '876,120.0',
        ',',
        '123,',
        ',',
        ',',
        ','
      ]
      file_path = 'products.csv'
      stub_csv_file file_path, csv_data.join("\n")
    end

    it 'loads all valid products' do
      products = Product.load 'products'

      expect(products).to have(10).products
    end
  end
end
