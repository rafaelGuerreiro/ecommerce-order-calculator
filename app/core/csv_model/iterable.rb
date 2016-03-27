module CsvModel
  module Iterable
    module ClassMethods
      def each(&block)
        all.each(&block)
      end

      def each_with_index(*args, &block)
        all.each_with_index(*args, &block)
      end

      def count(*args, &block)
        all.count(*args, &block)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
