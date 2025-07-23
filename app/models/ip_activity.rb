# frozen_string_literal: true

class IpActivity < ApplicationRecord
  include Filterable

  enum :activity_type, { trade: 0, login: 1, kyc: 2 }

  validates :activity_type, :ip_address, presence: true
  validate :resource_presence

  belongs_to :ip_address_record,
             primary_key: :address,
             foreign_key: :ip_address,
             inverse_of:  :ip_activities,
             class_name:  "IpAddress"
  belongs_to :trading_account,
             primary_key: :login,
             foreign_key: :trading_account_login,
             inverse_of:  :ip_activities,
             optional:    true
  belongs_to :user, optional: true
  belongs_to :owning_user, class_name: "User", optional: true

  default_scope { order(created_at: :desc) }

  scope :for_user, lambda { |user|
    logins = TradingAccount.where(user_id: user.id).pluck(:login)
    where(user_id: user.id)
      .or(where(trading_account_login: logins))
  }
  scope :recent_n_per_activity_type, lambda { |limit|
    subquery = <<~SQL
      SELECT id FROM (
        SELECT id,
              ROW_NUMBER() OVER (PARTITION BY activity_type ORDER BY created_at DESC) AS row_num
        FROM ip_activities
      ) ranked
      WHERE row_num <= :limit
    SQL

    where("ip_activities.id IN (#{ApplicationRecord.sanitize_sql([subquery, { limit: limit }])})")
  }

  def self.filter_fields
    {
      created_at_from: { type: 'date' },
      created_at_to:   { type: 'date' },
      activity_type:   { type: 'enum', values: activity_types.keys },
      trading_account_login: { type: 'text' },
      phase:          { type: 'enum', values: TradingAccount.phases.keys },
      platform:       { type: 'enum', values: TradingAccount.platforms.keys }
    }
  end

  def self.filter_mappings
    {
      created_at_from: ->(scope, value) { scope.where('ip_activities.created_at >= ?', Time.zone.parse(value)) },
      created_at_to:   ->(scope, value) { scope.where('ip_activities.created_at <= ?', Time.zone.parse(value)) },
      activity_type:   ->(scope, value) { scope.where(activity_type: Array(value)) },
      trading_account_login: ->(scope, value) { scope.where(trading_account_login: Array(value)) },
      phase:           ->(scope, value) { scope.joins(:trading_account).where(trading_accounts: { phase: Array(value) }) },
      platform:        ->(scope, value) { scope.joins(:trading_account).where(trading_accounts: { platform: Array(value) }) }
    }
  end

  def resource
    trading_account || user
  end

  private

  def resource_presence
    errors.add(:base, "Either user or trading_account must be present") unless user.present? || trading_account.present?
  end
end
