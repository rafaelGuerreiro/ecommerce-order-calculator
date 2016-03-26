class CsvModelRepository
  class << self
    def persist(model)
      return unless model.present?

      response = persist_all([model])
      response[0] if response.present?
    end

    def persist_all(models)
      return [] unless models.present?
      @repository ||= {}

      models.select { |model| model.is_a?(CsvModel::Base) && model.valid? }
            .select { |model| !exist?(model) }
            .map { |model| persist_index model.id, model }
            .compact
    end

    def find(clazz, id)
      return unless clazz < CsvModel::Base && id.present?

      hash = @repository[clazz]
      hash[id] if hash
    end

    def exist?(model)
      if model.is_a?(Class)
        return model < CsvModel::Base && @repository.key?(model)
      end

      return false unless model.is_a?(CsvModel::Base)

      exist?(model.class) && @repository[model.class].key?(model.id)
    end

    def find_by(clazz, **criteria)
      return [] unless exist?(clazz)

      @repository[clazz].select { |_, model| model.matches criteria }
                        .values
    end

    def destroy!
      @repository = {}
    end

    def all(clazz)
      return [] unless exist?(clazz)

      @repository[clazz].values
    end

    private

    def persist_index(id, model)
      @repository[model.class] ||= {}

      @repository[model.class][id] = model unless exist?(model)
    end
  end
end
