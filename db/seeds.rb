# frozen_string_literal: true

# Create users
puts "Creating users..."
20.times do
  User.create!(
    email: Faker::Internet.unique.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    country_code: Faker::Address.country_code
  )
end

# Create trading accounts
puts "Creating trading accounts..."
User.all.each do |user|
  rand(1..5).times do
    user.trading_accounts.create!(
      name: "#{user.first_name}'s Account #{Faker::Number.number(digits: 3)}",
      login: Faker::Number.unique.number(digits: 10).to_s,
      phase: TradingAccount.phases.keys.sample,
      platform: TradingAccount.platforms.keys.sample
    )
  end
end

# Create IP addresses
puts "Creating IP addresses..."
100.times do
  IpAddress.create!(
    address: Faker::Internet.unique.ip_v4_address,
    region: Faker::Address.state,
    country: Faker::Address.country_code,
    city: Faker::Address.city,
    lat: Faker::Address.latitude,
    lon: Faker::Address.longitude,
    is_vpn: [true, false].sample
  )
end

# Create IP activities with realistic distribution
puts "Creating IP activities..."
User.all.each do |user|
  # Create KYC activities (tied to user, max 10 per user)
  puts "Creating KYC activities for user #{user.id}..."
  kyc_count = rand(1..10)
  kyc_count.times do
    user.ip_activities.create!(
      ip_address: IpAddress.all.sample.address,
      activity_type: 'kyc',
      created_at: rand(6.months.ago..Time.current)
    )
  end

  # Create LOGIN activities (tied to user, max 1000 per user)
  puts "Creating LOGIN activities for user #{user.id}..."
  login_count = rand(10..100) # Realistic range for login activities
  login_count.times do
    user.ip_activities.create!(
      ip_address: IpAddress.all.sample.address,
      activity_type: 'login',
      created_at: rand(3.months.ago..Time.current)
    )
  end

  # Create TRADE activities (tied to trading accounts, 1000-10000 per user)
  puts "Creating TRADE activities for user #{user.id}..."
  user.trading_accounts.each do |trading_account|
    trade_count = rand(50..500) # Distribute across trading accounts
    trade_count.times do
      trading_account.ip_activities.create!(
        ip_address: IpAddress.all.sample.address,
        activity_type: 'trade',
        created_at: rand(1.month.ago..Time.current)
      )
    end
  end
end

# Create some additional high-volume data for performance testing
puts "Creating additional high-volume data for performance testing..."
sample_users = User.limit(5)
sample_users.each do |user|
  # Add more trade activities to simulate high-volume scenarios
  user.trading_accounts.each do |trading_account|
    additional_trades = rand(1000..2000)
    puts "Adding #{additional_trades} additional trade activities for trading account #{trading_account.login}..."

    additional_trades.times do |i|
      trading_account.ip_activities.create!(
        ip_address: IpAddress.all.sample.address,
        activity_type: 'trade',
        created_at: rand(6.months.ago..Time.current)
      )

      # Show progress for large batches
      puts "Progress: #{i + 1}/#{additional_trades}" if (i + 1) % 500 == 0
    end
  end
end


# Create some filters for testing
10.times do |i|
  UniversalFilter.create!(
    name: "Recent Trade Activities #{i + 1}",
    target_model: 'IpActivity',
    filter_params: {
      'created_at_from' => (30 - i).days.ago.strftime('%Y-%m-%d'),
      'created_at_to' => Time.current.strftime('%Y-%m-%d'),
      'activity_type' => ['trade']
    }
  )
end
puts "Seed data created successfully!"
puts "Summary:"
puts "- Users: #{User.count}"
puts "- Trading Accounts: #{TradingAccount.count}"
puts "- IP Addresses: #{IpAddress.count}"
puts "- IP Activities: #{IpActivity.count}"
puts "  - KYC: #{IpActivity.kyc.count}"
puts "  - Login: #{IpActivity.login.count}"
puts "  - Trade: #{IpActivity.trade.count}"
