module HupoWidget
  class Loader
    def initialize(app)
      @app = app
    end

    def call(env)
      # Reload widgets parameters
      HupoWidget::Base.reload if Rails.env.development?
      # Preload widgets
      HupoWidget::Base.all
      @app.call(env)
    ensure
      HupoWidget::Base.all = nil
      HupoWidget::Base.unload if Rails.env.development?
    end
  end
end
