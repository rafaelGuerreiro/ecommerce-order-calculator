describe Coupon, :model do
  describe '.fields' do
    it 'returns the header used for parsing the csv' do
      fields = Coupon.fields

      expect(fields).to have(5).fields
    end
  end
end
