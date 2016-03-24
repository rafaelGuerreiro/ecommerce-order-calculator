module CsvModel
  module ClassMethods
    def define_field(name, **options)
      define_fields [name], options
    end

    def define_fields(*names, **options)
      @fields ||= []

      names.each do |name|
        field = CsvModel::Field.new(self, name, options)

        next if !name.is_a?(Symbol) || @fields.include?(field)

        @fields << field
      end

      define_attr_reader
      define_initialize
      define_validity
    end

    def define_id_field(**options)
      define_field(:id, {
        type: :numeric
      }.merge(options))
    end

    private

    def define_attr_reader
      @fields.each do |field|
        class_eval { attr_reader field.name }
      end
    end

    def define_initialize
      init = %(
        def initialize(#{fields_as_arguments})
          #{fields_as_assignments}
        end
      )

      class_eval init
    end

    def fields_as_arguments
      @fields.map(&:to_argument).join(', ')
    end

    def fields_as_assignments
      @fields.map(&:to_assignment).join("\n")
    end

    def define_validity # rubocop:disable Metrics/MethodLength
      fields = @fields.map(&:to_validity)
                      .select(&:present?)
                      .join("\n")

      validity = %(
        def valid?
          result = true
          #{fields}
          result
        end

        def invalid?
          !valid?
        end
      )

      class_eval validity
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
end
