require 'active_support'
require 'active_record'
require 'class_factory/class_factory'

def ClassFactory(name, options = {}, &block)
  ClassFactory.create(name, options, block)
end
