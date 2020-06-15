if Rails.env.test? || Rails.env.development?
  # This is the default but without setting this here
  # the deprecation below will only be logged to log.
  ActiveSupport::Deprecation.behavior = [:stderr, :log]

  # Rails 4.0 raises an error when duplicate named routes
  # are added. This was done without deprecation in 4.0.
  # This monkeypatch adds a deprecation warning for use with
  # Rails 3.2.
  ActionDispatch::Routing::RouteSet.module_eval do
    def add_route_with_duplicate_route_deprecation(*args, &block)
      name = args[4]
      if name && named_routes[name]
        ActiveSupport::Deprecation.warn "Invalid route name, already in use: '#{name}' \n" \
          "You may have defined two routes with the same name using the `:as` option, or " \
          "you may be overriding a route already defined by a resource with the same naming. " \
          "For the latter, you can restrict the routes created with `resources` as explained here: \n" \
          "http://guides.rubyonrails.org/routing.html#restricting-the-routes-created \n" \
          "This will be a breaking change in Rails 4.0 \n"
      end
      add_route_without_duplicate_route_deprecation(*args, &block)
    end
    alias_method_chain :add_route, :duplicate_route_deprecation
  end
end