module CsvModel
  module Loader
    module ClassMethods
      def load(file_path)
        parser = CsvParser.new(self, file_path)
        models = parser.parse_csv

        CsvModelRepository.persist_all(models)
      end

      def find(id)
        CsvModelRepository.find(self, id)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
