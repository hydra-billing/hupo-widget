# coding: utf-8

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'delegate'
require 'erb'

module HupoWidget
  class Configuration < SimpleDelegator
    def initialize
      reload
    end

    def reload
      files = Rails.application.config.paths['config/widgets'].existent

      @settings = files.inject(HashWithIndifferentAccess.new) do |settings, file|
        widget = YAML::load(ERB.new(IO.read(file)).result)
        settings.deep_merge(widget)
      end

      __setobj__(@settings)
    end
  end
end