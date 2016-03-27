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
      stub_csv_file file_path, csv_data
    end

    it 'loads all valid coupons' do
      coupons = Coupon.load 'coupons'

      expect(coupons).to have(5).coupons
    end
  end

  describe '#expired?' do
    it 'returns true when expiration date is before today' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :absolute,
                          expiration: Date.new - 1,
                          usage_limit: 2

      expect(coupon.expired?).to be_truthy
      expect(coupon.active?).to be_falsy
    end

    it "returns true when there's no more usage left" do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :absolute,
                          expiration: Date.new + 1,
                          usage_limit: 0

      expect(coupon.expired?).to be_truthy
      expect(coupon.active?).to be_falsy
    end

    it "returns false when there's plenty usage and the expiration " \
      'date is future' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :absolute,
                          expiration: '2020/10/21',
                          usage_limit: 1

      expect(coupon.expired?).to be_falsy
      expect(coupon.active?).to be_truthy
    end

    it 'returns false coupon is invalid' do
      coupon = Coupon.new id: 'a',
                          value: 15,
                          discount_type: :absolute,
                          expiration: '2020/10/21',
                          usage_limit: 1

      expect(coupon.expired?).to be_falsy
      expect(coupon.active?).to be_falsy
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

  describe '#calculate_discount' do
    it 'returns 0 when coupon is invalid' do
      coupon = Coupon.new id: 'aa',
                          value: 15,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 2

      expect(coupon.calculate_discount(10)).to eq(0)
      expect(coupon).to be_invalid
    end

    it 'returns 0 when coupon is expired' do
      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :percent,
                          expiration: Date.new - 1,
                          usage_limit: 2

      expect(coupon.calculate_discount(10)).to eq(0)
      expect(coupon).to be_valid
      expect(coupon.expired?).to be_truthy

      coupon = Coupon.new id: 12,
                          value: 15,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 0

      expect(coupon.calculate_discount(10)).to eq(0)
      expect(coupon).to be_valid
      expect(coupon.expired?).to be_truthy
    end

    it 'returns value % off when discount_type is :percent' do
      coupon = Coupon.new id: 12,
                          value: 20,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon.calculate_discount(60)).to eq(12)
    end

    it 'substracts value when discount_type is :absolute' do
      coupon = Coupon.new id: 12,
                          value: 50,
                          discount_type: :absolute,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon.calculate_discount(90)).to eq(50)
    end

    it 'never surpasses the given total' do
      coupon = Coupon.new id: 12,
                          value: 100,
                          discount_type: :absolute,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon.calculate_discount(90)).to eq(90)

      coupon = Coupon.new id: 12,
                          value: 200,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon.calculate_discount(900)).to eq(900)
    end
  end

  describe '#discount!' do
    it 'subtracts 1 from the usage_limit' do
      coupon = Coupon.new id: 12,
                          value: 200,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon.expired?).to be_falsy

      expect { coupon.discount! }.to change { coupon.usage_limit }.by(-1)

      expect(coupon.expired?).to be_truthy
    end

    it 'does nothing when coupon is invalid' do
      coupon = Coupon.new id: 12,
                          value: 200,
                          discount_type: :percentage,
                          expiration: Date.new + 1,
                          usage_limit: 1

      expect(coupon).to_not be_valid
      expect(coupon.expired?).to be_falsy

      expect { coupon.discount! }.to change { coupon.usage_limit }.by 0
    end

    it 'does nothing when coupon is expired' do
      coupon = Coupon.new id: 12,
                          value: 200,
                          discount_type: :percent,
                          expiration: Date.new + 1,
                          usage_limit: 0

      expect(coupon).to be_valid
      expect(coupon.expired?).to be_truthy

      expect { coupon.discount! }.to change { coupon.usage_limit }.by 0
    end
  end
end
