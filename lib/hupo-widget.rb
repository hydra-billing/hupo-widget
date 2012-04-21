require 'rails'
require 'hupo_widget/engine'

module HupoWidget
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Configuration
end
