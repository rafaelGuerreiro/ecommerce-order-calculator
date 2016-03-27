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
      { id: 456, name: 'Carlos', age: 34 },
      { id: 567, name: '', age: 1 },
      { id: 456, name: 'Already saved' },
      { id: 678, name: 'John' }
    )
  end

  it 'does not implement ::Enumerable' do
    expect(Person.is_a?(::Enumerable)).to be_falsy
  end

  describe '.each' do
    it 'responds to each method' do
      expect(Person.respond_to?(:each)).to be_truthy
    end

    it 'iterates over all valid models' do
      ids = [123, 234, 345, 456, 678]

      Person.each do |person|
        expect(person).to be_valid
        expect(ids.include?(person.id)).to be_truthy
      end
    end
  end

  describe '.each_with_index' do
  end

  describe '.count' do
  end
end
