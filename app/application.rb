require 'active_support/core_ext/object/blank'

require 'require_all'
require_all 'app/**/*.rb'

class Application
  attr_reader :files

  def initialize(paths,
                 models = [Coupon, Product, Order, OrderProduct, :result])
    paths = [] unless paths.is_a?(Array)
    models = [] unless models.is_a?(Array)

    if paths.size != models.size
      raise ArgumentError, "You have to provide #{models.size} paths for the " \
        "program be able to continue.\nThe order of models being used is: " \
        "#{models}"
    end

    paths = normalize_paths(paths)

    @files = Hash[*models.zip(paths).flatten]
  end

  def load_models
    @files.each do |clazz, file_path|
      if clazz.is_a?(Class) && clazz < CsvModel::Base
        clazz.load(file_path)
        yield(clazz, file_path) if block_given?
      end
    end
  end

  def serialize_result
    Order.dump_csv(@files[:result]) do |order|
      [order.id, order.total_with_discount]
    end

    yield @files[:result] if block_given?
  end

  private

  def normalize_paths(paths)
    paths.map do |file_path|
      unless file_path.start_with? '/'
        file_path = File.expand_path(File.join('..', '..', file_path), __FILE__)
      end

      file_path
    end
  end
end
