# coding: utf-8

module HupoWidget
  class Engine < Rails::Engine

    initializer 'hupo_widget.add_widget_paths' do |app|
      app.config.paths.add 'app/widgets', glob: '**/*.rb'
      app.config.autoload_paths += app.config.paths['app/widgets']
      app.config.autoload_once_paths += app.config.paths['app/widgets']

      app.config.paths.add 'config/widgets', glob: '**/*.yml'
    end

    initializer 'hupo_widget.load_all_widgets' do |app|
      # Preload all models due to inheritance hook in HupoWidget::Base
      app.config.paths['app/widgets'].existent.each {|f| require f}
      HupoWidget::Base.create_widgets_by_config
      HupoWidget::Base.load_all!
    end
  end
end

