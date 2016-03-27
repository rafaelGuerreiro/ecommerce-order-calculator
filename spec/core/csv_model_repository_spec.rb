describe CsvModelRepository do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.persist' do
    it 'returns nil when model is not present' do
      expect(CsvModelRepository.persist(nil)).to be_nil
    end

    it 'persists only valid CsvModel::Base' do
      Foo.class_eval do
        define_id_field
        define_field :name
        define_field :birthday, type: :date, presence: false
      end

      model = Foo.new(id: 1, name: 'Rafael Guerreiro', birthday: '1992/06/09')
      expect(CsvModelRepository.persist(model)).to be(model)
    end
  end

  describe '.persist_all' do
    it "returns [] when there's nothing to persist" do
      expect(CsvModelRepository.persist_all([])).to eq([])
    end

    it 'persists only valid CsvModel::Base' do
      Foo.class_eval do
        define_id_field
        define_field :name
        define_field :birthday, type: :date, presence: false
      end

      OtherClass = Struct.new('OtherClass', :id, :name, :birthday)

      models = [
        Foo.new(id: 1, name: 'Rafael Guerreiro', birthday: '1992/06/09'),
        Foo.new(id: 'a', name: 'Bob', birthday: '1990/03/29'), # invalid id
        Foo.new(id: 2, name: 'Anna', birthday: '1982/02/31'), # invalid birthday
        Foo.new(id: 4, name: ' ', birthday: '2000/01/01'), # invalid name
        OtherClass.new(5, 'Alice', '1970/01/01') # invalid object
      ]

      expect(CsvModelRepository.persist_all(models))
        .to contain_exactly(models[0], models[2])
    end
  end

  describe '.find' do
    before do
      Foo.class_eval do
        define_id_field
        define_field :name
      end

      models = [
        Foo.new(id: 1, name: 'Rafael'),
        Foo.new(id: 3, name: 'Bob'),
        Foo.new(id: 2, name: 'Anna'),
        Foo.new(id: 12, name: 'Alice')
      ]

      CsvModelRepository.persist_all(models)
    end

    it 'fetches the model by id' do
      anna = CsvModelRepository.find(Foo, 2)

      expect(anna).not_to be_nil
      expect(anna.id).to eq(2)
      expect(anna.name).to eq('Anna')
    end

    it 'returns nil when record is not found' do
      obj = CsvModelRepository.find(Foo, 5)
      expect(obj).to be_nil
    end

    it 'returns nil when the class is not a CsvModel::Base' do
      obj = CsvModelRepository.find(String, 5)
      expect(obj).to be_nil
    end

    it 'returns nil when id is not present' do
      obj = CsvModelRepository.find(Foo, nil)
      expect(obj).to be_nil
    end

    it "returns nil when the model wasn't persisted yet" do
      stub_const 'Bar', Class.new(CsvModel::Base)
      Bar.class_eval do
        define_id_field
        define_field :name
      end

      obj = CsvModelRepository.find(Bar, 1)
      expect(obj).to be_nil
    end
  end

  describe '.all' do
    before do
      Foo.class_eval do
        define_id_field
        define_field :name
      end

      models = [
        Foo.new(id: 1, name: 'Rafael'),
        Foo.new(id: 3, name: 'Bob'),
        Foo.new(id: 12, name: 'Alice'),
        Foo.new(id: 2, name: 'Anna')
      ]

      CsvModelRepository.persist_all(models)
    end

    it 'returns all models from a class' do
      foos = CsvModelRepository.all(Foo)

      expect(foos).to have(4).elements
    end

    it 'must be returned in the same order that it was inserted' do
      foos = CsvModelRepository.all(Foo)

      expect(foos[0].id).to eq(1)
      expect(foos[1].id).to eq(3)
      expect(foos[2].id).to eq(12)
      expect(foos[3].id).to eq(2)
    end
  end
end
