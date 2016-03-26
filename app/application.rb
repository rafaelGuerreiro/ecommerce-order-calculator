require 'active_support/core_ext/object/blank'

require 'require_all'
require_all 'app/**/*.rb'

class Application
  def initialize(paths)
    models = [Coupon, Product, Order, OrderProduct, :result]

    paths = paths.map do |file_path|
      unless file_path.start_with? '/'
        file_path = File.expand_path(File.join('..', '..', file_path), __FILE__)
      end

      file_path
    end

    @files = Hash[*models.zip(paths).flatten]
  end

  def load_models
    @files.each do |clazz, file_path|
      if clazz.is_a?(Class) && clazz < CsvModel::Base
        clazz.load(file_path)
        puts "Loaded #{clazz} from #{file_path}"
      end
    end
  end

  def serialize_result
    Order.dump_csv(@files[:result]) do |order|
      [order.id, order.total_with_discount]
    end

    puts "Finished dumping orders into #{@files[:result]}"
  end
end
