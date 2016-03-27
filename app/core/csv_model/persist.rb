module CsvModel
  module Persist
    def save
      CsvModelRepository.persist(self)
    end

    module ClassMethods
      def create(*options)
        saved = options.map do |opt|
          CsvModelRepository.persist(new(opt))
        end

        return if saved.blank?
        return saved[0] if saved.size == 1

        saved
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
