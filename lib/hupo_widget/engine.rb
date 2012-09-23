# coding: utf-8

module HupoWidget
  class Engine < Rails::Engine

    initializer 'hupo_widget.add_widget_paths' do |app|
      app.config.paths.add 'app/widgets', glob: '**/*.rb'
      app.config.eager_load_paths += app.config.paths['app/widgets']
      app.config.paths.add 'config/widgets', glob: '**/*.yml'
    end

  end
end

