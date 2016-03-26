require 'active_support/core_ext/hash/keys'

module CsvModel
  module Loader
    def matches(**criteria)
      matches = true

      criteria.each do |method, value|
        break unless matches
        matches = false unless respond_to?(method)

        if matches
          val = __send__(method)
          matches = val == value
        end
      end

      matches
    end

    module ClassMethods
      def load(file_path)
        parser = CsvParser.new(self, file_path)
        models = parser.parse_csv

        CsvModelRepository.persist_all(models)
      end

      def find(id)
        CsvModelRepository.find(self, id)
      end

      def find_by(**criteria)
        CsvModelRepository.find_by(self, criteria)
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /find_by_(\w+)/
          attributes = Regexp.last_match[1].split(/_and_/)

          hash = Hash[*attributes.zip(args).flatten].symbolize_keys
          return find_by(hash)
        end

        super
      end

      def respond_to_missing?(method, *)
        method.to_s =~ /find_by_(\w+)/ || super
      end

      def all
        CsvModelRepository.all self
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
