describe CsvModel::FileDump do
  before do
    stub_const 'Person', Class.new(CsvModel::Base)

    Coupon.create(
      coupon_hash('1', '10', 'absolute', '2015/12/31', '2'),
      coupon_hash('2', '15', 'percent', '2020/12/31', '1'),
      coupon_hash('3', '100', 'absolute', '2020/06/09', '0'),
      coupon_hash('4', '30.5', 'percent', '2019/01/31', '3'),
      coupon_hash('5', '200', 'absolute', '2017/12/01', '5')
    )
  end

  describe '.dump_csv' do
    it 'does nothing when csv file is invalid' do
      target = stub_csv_writing_target nil

      Coupon.dump_csv nil
      expect(target).to be_empty
    end

    it 'defaults converting every field to string when no block is given' do
      target = stub_csv_writing_target 'tmp/result.csv'

      Coupon.dump_csv 'tmp/result.csv'

      expect(target).to contain_exactly(
        ['1', '10', 'absolute', '2015/12/31', '2'],
        ['2', '15', 'percent', '2020/12/31', '1'],
        ['3', '100', 'absolute', '2020/06/09', '0'],
        ['4', '30.5', 'percent', '2019/01/31', '3'],
        ['5', '200', 'absolute', '2017/12/01', '5']
      )
    end

    it 'considers the array returned in the block when a block is given' do
      target = stub_csv_writing_target 'tmp/result.csv'

      Coupon.dump_csv('tmp/result.csv') do |coupon|
        [coupon.id, "this coupon is #{coupon.discount_type}"]
      end

      expect(target).to contain_exactly(
        [1, 'this coupon is absolute'],
        [2, 'this coupon is percent'],
        [3, 'this coupon is absolute'],
        [4, 'this coupon is percent'],
        [5, 'this coupon is absolute']
      )
    end

    it 'automatically converts date to %Y/%m/%d pattern' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :birthday, type: :date
      end

      Person.create(id: 1,
                    name: 'Rafael Guerreiro',
                    birthday: Date.new(1992, 6, 9)
                   )

      target = stub_csv_writing_target 'tmp/result.csv'

      Person.dump_csv 'tmp/result.csv'

      expect(target).to contain_exactly(['1', 'Rafael Guerreiro', '1992/06/09'])
    end

    it 'automatically considers the id when field is a CsvModel::Base' do
      Person.class_eval do
        define_id_field
        define_field :name
        define_field :coupon, references: Coupon
      end

      person = Person.create(id: 1, name: 'Rafael Guerreiro', coupon: 2)

      expect(person.coupon).to_not be_nil
      expect(person.coupon.discount_type).to eq(:percent)

      target = stub_csv_writing_target 'tmp/result.csv'

      Person.dump_csv 'tmp/result.csv'

      expect(target).to contain_exactly(['1', 'Rafael Guerreiro', '2'])
    end
  end

  private

  def coupon_hash(id, value, discount_type, expiration, usage_limit)
    {
      id: id,
      value: value,
      discount_type: discount_type,
      expiration: expiration,
      usage_limit: usage_limit
    }
  end
end
