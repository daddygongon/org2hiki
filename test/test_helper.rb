$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "org2hiki"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use!
