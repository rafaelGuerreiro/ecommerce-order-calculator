module CsvModel
  module Persist
    def save
      CsvModelRepository.persist(self)
    end

    module ClassMethods
      def create(**options)
        CsvModelRepository.persist(new(options))
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
