module HupoWidget
  class Loader
    def initialize(app)
      @app = app
    end

    def call(env)
      HupoWidget::Base.reload if Rails.env.development?
      # Preload widgets
      HupoWidget::Base.all
      @app.call(env)
    ensure
      HupoWidget::Base.all = nil
      unload_types if Rails.env.development?
    end

    def unload_types
      HupoWidget::Base.widget_types = nil
    end
  end
end
