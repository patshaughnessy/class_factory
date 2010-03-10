require 'helper'

class TestClassFactory < Test::Unit::TestCase

  context "A class definition for a simple active record model" do
    setup do
      ClassFactory.define :model
    end

    should "create an ActiveRecord model by default" do
      klass = ClassFactory :model
      assert_equal Model, klass
      assert_equal ActiveRecord::Base, klass.superclass
    end

    should "create a table for each new model with the correct name" do
      ClassFactory :model
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select * from models')
      end
    end

    should "create a table for each new model with the correct name if a different class name is specified" do
      ClassFactory :model, :class => 'different_class'
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select * from different_classes')
      end
    end
  end

  context "A class definition for an active record model with a migration specified" do
    setup do
      ClassFactory.define :person do |p|
        p.string  :first_name
        p.string  :last_name
        p.integer :age
      end
      ClassFactory :person
    end

    should "run the given migration on the new table" do
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select first_name from people')
      end
    end

    should "create an ActiveRecord model class that can be used in the normal way to insert and select data" do
      assert_equal 0, Person.count
      Person.create :first_name => 'Joe', :last_name => 'Blow', :age => 50
      assert_equal 1, Person.count
      assert_equal 'Joe', Person.first.first_name
      assert_equal 50, Person.find_by_age(50).age
    end

    should "delete the table and its contents if the model class is redefined" do
      Person.create :first_name => 'Joe', :last_name => 'Blow', :age => 50
      assert_equal 1, Person.count
      ClassFactory :person
      assert_equal 0, Person.count
    end
  end

  context "A class definition for an active record model with a certain table name specified" do
    setup do
      ClassFactory.define :model, :table => 'model_table' do |m|
        m.string :name
      end
    end

    should "create a table with the specified name" do
      ClassFactory :model
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select name from model_table')
      end
    end

    should "allow the table name be overriden" do
      ClassFactory :model, :table => 'table_for_models'
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select name from table_for_models')
      end
    end

    should "not change the original definition after overriding the table setting once" do
      ClassFactory :model
      ActiveRecord::Base.connection.execute('drop table model_table')
      ClassFactory :model, :table => 'table_for_models'
      ActiveRecord::Base.connection.execute('drop table table_for_models')
      ClassFactory :model
      assert_nothing_raised do
        ActiveRecord::Base.connection.execute('select name from model_table')
      end
    end
  end

  context "A class definition with a default migration specified" do
    setup do
      ClassFactory.define :person do |p|
        p.string  :first_name
        p.string  :last_name
        p.integer :age
      end
    end

    should "allow the migration to be overriden" do
      ClassFactory :person do |p|
        p.string  :name
        p.integer :age
        p.integer :group_id
      end
      assert_equal ["id", "name", "age", "group_id"], Person.column_names
    end

    should "not change the original definition after overriding the migration" do
      ClassFactory :person do |p|
        p.string  :name
        p.integer :age
        p.integer :group_id
      end
      ClassFactory :person
      assert_equal ["id", "first_name", "last_name", "age"], Person.column_names
    end
  end
end
