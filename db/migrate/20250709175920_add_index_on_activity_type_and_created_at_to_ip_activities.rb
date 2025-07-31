class AddIndexOnActivityTypeAndCreatedAtToIpActivities < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :ip_activities,
              [:activity_type, :created_at],
              order: { created_at: :desc },
              name: 'index_ip_activities_on_type_and_created_at',
              algorithm: :concurrently
  end
end
