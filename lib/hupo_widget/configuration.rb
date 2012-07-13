# coding: utf-8

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'delegate'

module HupoWidget
  class Configuration < SimpleDelegator
    def initialize
      load_files
      super(@settings)
    end

    private

    def load_files
      files = Rails.application.config.paths['config/widgets'].existent

      @settings = files.inject(HashWithIndifferentAccess.new) {|s, f| s.deep_merge(YAML.load(File.read(f)))}
    end
  end
end