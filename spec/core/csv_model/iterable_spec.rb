describe CsvModel::Iterable do
  before do
    stub_const 'Person', Class.new(CsvModel::Base)

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

    it "does nothing when there's no record" do
      CsvModelRepository.destroy!

      expect do
        Person.each do |person|
          raise "Error, this shouldn't be reached. Model => #{person}."
        end
      end.to_not raise_error
    end
  end

  describe '.each_with_index' do
    it 'responds to each_with_index method' do
      expect(Person.respond_to?(:each_with_index)).to be_truthy
    end

    it 'iterates over all valid models in the same order they were saved' do
      ids = [123, 234, 345, 456, 678]

      Person.each_with_index do |person, index|
        expect(person).to be_valid
        expect(person.id).to eq(ids[index])
      end
    end

    it "does nothing when there's no record" do
      CsvModelRepository.destroy!

      expect do
        Person.each_with_index do |person, index|
          raise "Error, this shouldn't be reached. " \
            "Model => #{person} at index #{index}."
        end
      end.to_not raise_error
    end
  end

  describe '.count' do
    it 'responds to count method' do
      expect(Person.respond_to?(:count)).to be_truthy
    end

    it 'counts only valid models' do
      expect(Person.count).to eq(5)
    end

    it 'accepts a block to filter counting' do
      expect(Person.count do |person|
        person.name.include?('o')
      end).to eq(4)
    end

    it 'accepts a model to count' do
      clotilde = Person.find(234)
      expect(Person.count(clotilde)).to eq(1)

      expect(Person.count(nil)).to eq(0)
    end

    it "returns zero when there's no record" do
      CsvModelRepository.destroy!

      expect(Person.count).to eq(0)
    end
  end
end
