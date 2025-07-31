class FilterService
  def initialize(scope:, filters: {})
    @scope = scope
    @filters = filters
  end

  def call
    return scope if filters.blank?

    Filterable.apply_filters(scope, filters)
  end

  private

  attr_reader :scope, :filters
end
