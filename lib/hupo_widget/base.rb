# coding: utf-8
require 'singleton'

module HupoWidget
  class Base
    class NoInstanceAllowed < StandardError; end
    class UnknownWidget < StandardError; end
    class ConfigVerificationError < StandardError; end

    @widget_types = nil

    class << self
      attr_writer :widget_types, :all, :instances

      def instances
        @instances ||= {}
      end

      def widget_types
        return @widget_types if @widget_types
        @widget_types = []
        create_widgets_by_config
        @widget_types
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
        @all ||= widget_types.reject(&:abstract?).inject({}) {|res, type| res.deep_merge(type.instances_hash)}
      end

      def instances_hash
        prefix = Hash.new {|h, k| h[k] = {}}
        # Shortcuts::AccountInfo -> %w(shortcuts account_info)
        before_last = config_paths[0...-1].each_with_object(prefix) {|res, key| res[key]}
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

      def reload
        config.reload
      end

      def unload
        @widget_types.try(:each) do |type|
          if type.singleton?
            type.instance_variable_set(:@singleton__instance__, nil)
          else
            type.instances = nil
          end
        end
        @widget_types = nil
      end

      def singleton?
        self < Singleton
      end

      def new(*)
        new_instance = super
        # Save new instance to hash
        instances[new_instance.key] = new_instance
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
          class_name = '%sWidget' % widget_type

          if (widget_class = class_name.safe_constantize)
            @widget_types << widget_class

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
    end

    attr_reader :key
    delegate :singleton?, :abstract?, :config_paths, to: 'self.class'
    delegate :as_json, to: :@values
    delegate :config, to: 'HupoWidget::Base'

    def initialize(key = nil)
      raise NoInstanceAllowed, 'Could not create an instance of abstract class' if abstract?

      @key = singleton? ? 'singleton' : key

      type_config = config_paths.inject(config) {|c, k| c[k]}
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

      def current_user
        Session.find.user
      end
  end
end
