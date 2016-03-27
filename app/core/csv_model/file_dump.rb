module CsvModel
  module FileDump
    module ClassMethods
      def dump_csv(file_path, &block)
        CsvGenerator.new(self, file_path).dump_csv(&block)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
