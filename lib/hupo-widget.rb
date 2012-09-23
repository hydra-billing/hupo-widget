require 'rails'
require 'hupo_widget/engine'
require 'hupo_widget/loader'

module HupoWidget
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Configuration
end
