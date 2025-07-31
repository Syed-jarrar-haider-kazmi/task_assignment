class UniversalFilter < ApplicationRecord
  belongs_to :filterable, polymorphic: true, optional: true

  validates :target_model, presence: true
  validates :filter_params, presence: true
end
