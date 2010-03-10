class ClassFactory

  class << self

    attr_accessor :factories

    def define(name, options = {}, &block)
      factories[name] = self.new({ :name => name, :migration => block }.merge(options))
    end

    def create(name, options, block)
      raise "No such class factory defined" if !factories.has_key?(name)
      options.merge!(:migration => block) if block
      factories[name].create(options)
    end
  end

  def create(override_options)
    @options = @definition.merge(override_options)
    @options[:super] = ActiveRecord::Base if @options[:super].nil?
    create_table if is_active_record?(@options[:super])
    klass = create_class
    klass.class_eval @options[:class_eval] if @options[:class_eval]
    klass
  end

  private

  def initialize(options)
    @definition = options
  end

  def create_table
    ActiveRecord::Base.connection.create_table table_name, :force => true do |table|
      @options[:migration].call(table) unless @options[:migration].nil?
    end
  end

  def create_class
    Object.send(:remove_const, class_name) rescue nil
    Object.const_set class_name, Class.new(@options[:super])
  end

  def is_active_record?(klass)
    klass == ActiveRecord::Base || klass.ancestors.include?(ActiveRecord::Base)
  end

  def class_name
    (@options[:class] || @options[:name]).to_s.camelize
  end

  def table_name
    if @options[:table]
      @options[:table]
    else
      (@options[:class] || @options[:name]).to_s.underscore.pluralize.to_sym
    end
  end

  self.factories = {}

end

