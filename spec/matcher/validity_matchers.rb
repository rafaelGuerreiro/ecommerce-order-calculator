require 'rspec/expectations'

module CustomMatcher
  RSpec::Matchers.define :be_valid do
    match do |actual|
      actual.respond_to?(:valid?) && actual.valid?
    end
  end

  RSpec::Matchers.define :be_invalid do
    match do |actual|
      actual.respond_to?(:invalid?) && actual.invalid?
    end
  end
end