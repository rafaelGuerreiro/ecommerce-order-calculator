#!/usr/bin/ruby

require_relative 'app/application'

app = Application.new(ARGV)
app.load_models
app.serialize_result
