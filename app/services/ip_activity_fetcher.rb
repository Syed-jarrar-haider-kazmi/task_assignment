class IpActivityFetcher
  MAX_TOTAL = 3000
  MAX_KYC = 10
  MAX_LOGIN = 1000
  MAX_TRADE = MAX_TOTAL - MAX_KYC - MAX_LOGIN

  def initialize(user)
    @user = user
  end

  def call
    IpActivity
      .unscoped
      .where(id: combined_ids)
      .includes(:ip_address_record, :user, :trading_account)
      .order(Arel.sql(activity_type_priority_sql))
  end

  private

  def combined_ids
    kyc_ids = fetch_ids(:kyc, MAX_KYC)
    login_ids = fetch_ids(:login, MAX_LOGIN)
    # We have to fill remaining slots with tarde activities so from the existing count of KYC and login activities, lets subract from MAX_TOTAL
    remaining = MAX_TOTAL - kyc_ids.size - login_ids.size
    trade_ids = fetch_ids(:trade, remaining)

    kyc_ids + login_ids + trade_ids
  end

  def fetch_ids(type, limit)
    IpActivity
      .unscoped
      .for_user(@user)
      .recent_n_per_activity_type(limit)
      .pluck(:id)
  end

  # Optional, but I considering that as since we are prioritizing activities, it makes sense to have a custom order in which they are grouop by their types
  def activity_type_priority_sql
    <<~SQL
      CASE
        WHEN activity_type = 2 THEN 0  -- KYC
        WHEN activity_type = 1 THEN 1  -- Login
        WHEN activity_type = 0 THEN 2  -- Trade
      END ASC,
      created_at DESC
    SQL
  end
end
