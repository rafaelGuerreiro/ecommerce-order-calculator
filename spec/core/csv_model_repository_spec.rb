describe CsvModelRepository do
  before do
    stub_const 'Foo', Class.new(CsvModel::Base)
  end

  describe '.persist' do
    it "returns nil when there's nothing to persist" do
      expect(CsvModelRepository.persist).to be_nil
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

      expect(CsvModelRepository.persist(*models))
        .to contain_exactly(models[0], models[2])
    end
  end
end
