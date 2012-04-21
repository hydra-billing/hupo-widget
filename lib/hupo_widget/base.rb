# coding: utf-8
require 'singleton'

module HupoWidget
  class Base
    class WidgetAlreadyInitialized < StandardError; end

    @widget_types = []
    @widgets

    class << self
      attr_reader    :widget_types
      attr_accessor  :instances

      def inherited(base)
        # Remember all subclasses
        @widget_types << base
        base.instances = {}
        super
      end

      # Creates single unique object of widget
      def singleton!
        include Singleton
        self.instances = {widget_key => instance}
        instance.name = widget_key
        instance.load
      end

      # CommonWidget => 'support'
      # OtherWidgets::ReportWidget => 'otherWidgets.report'
      def widget_key
        @key ||= name.sub(/Widget$/, '').split('::').map do |path|
          path[0...1] = path[0...1].downcase
          path
        end.join('.').to_sym
      end

      # Returns hash with all widget objects indexed by self.widget_key
      def all
        @widget_types.inject({}) do |res, type|
          # Singleton class refers straight to object
          # Other class refer to an array of instances
          res[type.widget_key] = type.singleton? ? type.instance : type.instances
          res
        end
      end

      def config
        @@config ||= HupoWidget::Configuration.new
      end

      def singleton?
        self < Singleton
      end
    end

    attr_accessor :name
    delegate :singleton?, to: 'self.class'
    delegate :as_json, to: '@values'
    delegate :config, to: 'HupoWidget::Base'

    def initialize(key)
      raise ArgumentError, 'Widget with key %s already exist' if self.class.instances.has_key?(key)

      @key = key
      @name = '%s_%s' % [self.class.widget_key, key]
      self.class.instances[@name] = self
      load
    end

    def load
      raise WidgetAlreadyInitialized if defined?(@values) && !@values.nil?

      @values = config[@name]
    end

    def [](k)
      @values[k]
    end

    def []=(k, v)
      @values[k] = v
    end
  end
end