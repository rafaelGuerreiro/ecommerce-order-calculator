module CsvModel
  module FileDump
    module ClassMethods
      def dump_csv(file_path, &block)
        generator = CsvGenerator.new(self, file_path)
        generator.dump_csv(&block)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
