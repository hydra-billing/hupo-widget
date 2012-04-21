# coding: utf-8

require 'active_support/hash_with_indifferent_access'

module HupoWidget
  class Configuration
    def initialize
      load_files
    end

    def [](key)
      @settings[key]
    end

    private

    def load_files
      files = Rails.application.config.paths['config/widgets'].existent

      @settings = files.inject(HashWithIndifferentAccess.new) do |s, f|
        s.merge!(YAML.load(File.read(f)))
        s
      end

      # TODO: Widgets must be created automatically based on content of YML-files
    end
  end
end