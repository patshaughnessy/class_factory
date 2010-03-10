require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_record'

ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', :database => ':memory:' })

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'class_factory'

class Test::Unit::TestCase
end
