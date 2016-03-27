describe CsvModel::Iterable do
  before do
    stub_const 'Person', Class.new(CsvModel::Base)

    CsvModelRepository.destroy!

    Person.class_eval do
      define_id_field
      define_field :name
      define_field :age, type: :numeric, presence: false
    end

    Person.create(
      { id: 123, name: 'Rafael', age: 23 },
      { id: 234, name: 'Clotilde', age: 71 },
      { id: 345, name: 'Bob', age: 50 },
      { id: 456, name: 'Carlos', age: 34 }
    )
  end

  describe '.each' do
    it 'iterates over all saved models' do
      Person.each do |person|
      end
    end
  end

  describe '.each_with_index' do
  end

  describe '.count' do
  end
end
