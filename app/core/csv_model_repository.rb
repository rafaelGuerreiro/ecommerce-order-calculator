class CsvModelRepository
  class << self
    def persist(*models)
      return unless models.present?

      persist_all models
    end

    def persist_all(models)
      @repository ||= {}

      saved = []
      models.each do |model|
        next if !model.is_a?(CsvModel::Base) || model.invalid?

        persist_index model.id, model, saved
      end

      saved
    end

    def find(clazz, id)
      return unless clazz < CsvModel::Base && id.present?

      hash = @repository[clazz]
      hash[id] if hash
    end

    private

    def persist_index(id, model, saved)
      @repository[model.class] ||= {}
      saved << (@repository[model.class][id] ||= model)
    end
  end
end
