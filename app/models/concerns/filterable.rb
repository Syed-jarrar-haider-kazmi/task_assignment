module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filter_fields
      {}
    end

    def filter_mappings
      {}
    end
  end

  def self.apply_filters(scope, filters)
    mappings = scope.klass.filter_mappings

    filters.reduce(scope) do |current_scope, (key, value)|
      handler = mappings[key.to_sym]
      if handler.respond_to?(:call)
        handler.call(current_scope, value)
      else
        current_scope
      end
    end
  end
end