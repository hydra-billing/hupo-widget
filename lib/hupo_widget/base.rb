# coding: utf-8
require 'singleton'

module HupoWidget
  class Base
    class WidgetAlreadyInitialized < StandardError; end
    class NoInstanceAllowed < StandardError; end
    class UnknownWidget < StandardError; end
    class ConfigVerificationError < StandardError; end

    @widget_types = []
    @widgets

    class << self
      attr_accessor  :widget_types, :instances

      def inherited(base)
        # Remember all subclasses
        Base.widget_types << base
        base.instances = {}
        super
      end

      # Creates single unique object of widget
      def singleton!
        include Singleton
      end

      def abstract!
        @abstract_class = true
      end

      def abstract?
        @abstract_class ||= false
      end

      # Returns hash with all widget objects in hash with classes' and modules' names as keys
      def all
        @widget_types.reject(&:abstract?).inject({}) {|res, type| res.deep_merge(type.instances_hash)}
      end

      def instances_hash
        prefix = Hash.new {|h, k| h[k] = {}}
        # Shortcuts::AccountInfo -> %w(shortcuts account_info)
        before_last = config_paths[0...-1].inject(prefix) {|res, key| res[key]}
        # Singleton class refers straight to object
        # Other class refer to an array of instances
        before_last[config_paths.last] = singleton? ? instance : instances
        # {shortcuts: {account_info: #{instances.as_json}}}
        prefix
      end

      def config_paths
        @config_paths ||= name.underscore.sub(/_widget$/, '').split('/')
      end

      def config
        @@config ||= HupoWidget::Configuration.new
      end

      def singleton?
        self < Singleton
      end

      def new(*)
        new_instance = super
        # Save new instance to hash
        @instances[new_instance.key] = new_instance
      end

      # Creates all widgets defined in configuration file
      def create_widgets_by_config(hash = config, prefix = '')
        # Raise an exception if hash is not config or hash
        if !hash.is_a?(Hash) and !hash.is_a?(HupoWidget::Configuration)
          raise UnknownWidget, 'Unknown widget type %s' % prefix.underscore.gsub('/', '.')
        end

        hash.each do |widget_type, values|
          widget_type = widget_type.camelize
          widget_type = '%s::%s' % [prefix, widget_type] if prefix != ''

          if (widget_class = ('%sWidget' % widget_type).safe_constantize)
            if widget_class.singleton?
              # Create a singleton object
              widget_class.instance
            else
              values.each_key {|key| widget_class.new(key)}
            end
          else
            # We need to go deeper
            create_widgets_by_config(values, widget_type)
          end
        end
      end

      def load_all!
        @widget_types.each {|type| type.instances.each_value(&:load!)}
      end
    end

    attr_reader :key
    delegate :singleton?, :abstract?, :config_paths, to: 'self.class'
    delegate :as_json, to: '@values'
    delegate :config, to: 'HupoWidget::Base'

    def initialize(key = nil)
      raise ArgumentError, 'Widget with key %s already exists' if self.class.instances.has_key?(key)
      raise NoInstanceAllowed, 'Could not create an instance of abstract class' if abstract?

      @key = singleton? ? 'singleton' : key
    end

    def load!
      raise WidgetAlreadyInitialized if defined?(@values) && !@values.nil?

      type_config = config_paths.inject(config) {|c, key| c[key]}
      @values = singleton? ? type_config : type_config[@key]
    end

    def [](k)
      @values[k]
    end

    def []=(k, v)
      @values[k] = v
    end

    protected

    def verify_config
      raise ConfigVerificationError, 'Configuration for widget %s with key not found' % self.class if @values.nil?
    end
  end
end