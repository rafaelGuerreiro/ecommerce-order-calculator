require 'byebug'

describe Coupon, :model do
  describe '.fields' do
    it 'returns the header used for parsing the csv' do
      fields = Coupon.fields
      expect(fields).to have(5).fields

      expect(fields[0].name).to eq(:id)
      expect(fields[1].name).to eq(:value)
      expect(fields[2].name).to eq(:discount_type)
      expect(fields[3].name).to eq(:expiration)
      expect(fields[4].name).to eq(:usage_limit)
    end
  end

  describe '.load' do
    before do
      csv_data = [
        '123,25,absolute,2020/12/25,1',
        '234,15,percent,2020/01/01,2',
        '345,50,absolute,2015/12/25,1',
        '456,25,percent,2020/01/31,2',
        '567,100,absolute,2020/12/25,1',
        '568,100,absolut,2020/12/25,1',
        '123,30,percent,2020/12/25,1'
      ]
      file_path = 'coupons.csv'
      stub_csv_file file_path, csv_data.join("\n")
    end

    it 'loads all valid coupons' do
      coupons = Coupon.load 'coupons'

      expect(coupons).to have(5).coupons
    end
  end

  describe 'discount_type check' do
    it 'returns true for absolute? when this Coupon has an absolute discount' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :absolute,
                          expiration: Date.new + 1,
                          usage_limit: 2

      expect(coupon.absolute?).to be_truthy
      expect(coupon.percent?).to be_falsy
    end

    it 'returns true for percent? when this Coupon has an percent discount' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 2

      expect(coupon.absolute?).to be_falsy
      expect(coupon.percent?).to be_truthy
    end

    it 'returns false for both when this Coupon has an invalid discount_type' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :abs,
                          expiration: Date.new + 1,
                          usage_limit: 2

      expect(coupon.absolute?).to be_falsy
      expect(coupon.percent?).to be_falsy
    end
  end
end
