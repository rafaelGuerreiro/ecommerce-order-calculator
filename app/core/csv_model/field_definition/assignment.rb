module CsvModel
  module FieldDefinition
    module Assignment
      def to_assignment
        return if invalid?

        assignment = ''
        space = "\n          "

        assignment << date_assignment + space if @options[:type] == :date
        assignment << number_assignment + space if @options[:type] == :numeric
        assignment << enum_assignment + space if @options[:type] == :enum

        assignment << "@#{@name} = #{@name}"
      end

      private

      def date_assignment
        %(
          begin
            if #{@name}.is_a?(String)
              #{@name} = Date.strptime(#{@name}, '%Y/%m/%d')
            end
          rescue ArgumentError
            #{@name} = nil
          end)
      end

      def number_assignment
        %(
          begin
            if #{@name}.is_a?(String)
              if #{@name}.include?('.')
                #{@name} = Float(#{@name})
              else
                #{@name} = Integer(#{@name})
              end
            end
          rescue ArgumentError
            #{@name} = nil
          end)
      end

      def enum_assignment
        %(
          #{@name} = #{@name}.to_sym if #{@name}.is_a?(String)

          unless self.class.options(:#{@name}, :enum).include?(#{name})
            #{@name} = nil
          end)
      end
    end
  end
end
