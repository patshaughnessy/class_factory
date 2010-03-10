require 'helper'

class TestClassFactory < Test::Unit::TestCase

  should "raise an exception for an undefined class factory" do
    assert_raise RuntimeError do
      ClassFactory :unknown
    end
  end

  should "create a Ruby class with the expected name and with the specified super class" do
    ClassFactory.define :plain_object, :super => Object
    klass = ClassFactory :plain_object
    assert_equal PlainObject, klass
    assert_equal Object, klass.superclass

    ClassFactory.define :array_object, :super => Array
    klass = ClassFactory :array_object
    assert_equal ArrayObject, klass
    assert_equal Array, klass.superclass
  end

  context "A class factory definition for simple Ruby class" do
    setup do
      ClassFactory.define :plain_object, :super => Object
      ClassFactory :plain_object
      PlainObject.class_eval do
        def some_method
          'return value'
        end
      end
    end

    should "create a Ruby class that you can add methods to" do
      assert_equal 'return value', PlainObject.new.some_method
    end

    should "allow you to redefine a class more than once" do
      assert_equal 'return value', PlainObject.new.some_method
      ClassFactory :plain_object
      assert_raise NoMethodError do
        PlainObject.new.some_method
      end
    end
  end

  context "A class factory definition for simple Ruby class with a class_eval option specified" do
    setup do
      ClassFactory.define :plain_object, :super => Object, :class_eval => <<END
        def some_method
          'return value'
        end
END
    end

    should "execute that class eval code when the class is created" do
      ClassFactory :plain_object
      assert_equal 'return value', PlainObject.new.some_method
    end

    should "allow the class eval code to be overriden with different code" do
      ClassFactory :plain_object, :class_eval => <<END
        def some_method
          'a different return value'
        end
END
      assert_equal 'a different return value', PlainObject.new.some_method
    end

    should "not change the original definition after overriding the class_eval setting" do
      ClassFactory :plain_object, :class_eval => <<END
        def some_method
          'return value'
        end
END
      ClassFactory :plain_object
      assert_equal 'return value', PlainObject.new.some_method
    end
  end

  context "A class factory definition for simple Ruby class" do
    setup do
      ClassFactory.define :plain_object, :super => Object
    end

    should "allow you to override the super class when the class is created" do
      klass = ClassFactory :plain_object, :super => Array
      assert_equal PlainObject, klass
      assert_equal Array, klass.superclass
    end

    should "not change the original definition after overriding the super class setting" do
      ClassFactory :plain_object, :super => Array
      klass = ClassFactory :plain_object
      assert_equal PlainObject, klass
      assert_equal Object, klass.superclass
    end
  end

  context "A class factory definition for simple Ruby class with a class setting" do
    setup do
      ClassFactory.define :plain_object, :super => Object, :class => 'CertainClass'
    end

    should "create a class with the specified name" do
      klass = ClassFactory :plain_object
      assert_equal CertainClass, klass
    end

    should "allow you to override the default class name" do
      klass = ClassFactory :plain_object, :class => 'DifferentClass'
      assert_equal DifferentClass, klass
    end

    should "not change the original definition after overriding the class name setting" do
      ClassFactory :plain_object, :class => 'DifferentClass'
      klass = ClassFactory :plain_object
      assert_equal CertainClass, klass
    end

    should "allow you to use a class name not in camel case" do
      klass = ClassFactory :plain_object, :class => 'some_otherType_OfClass_name'
      assert_equal SomeOtherTypeOfClassName, klass
    end
  end

end
