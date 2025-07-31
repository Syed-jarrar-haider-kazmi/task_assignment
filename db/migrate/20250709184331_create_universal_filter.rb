class CreateUniversalFilter < ActiveRecord::Migration[7.2]
  def change
    create_table :universal_filters do |t|
      t.string :name
      t.string :filterable_type
      t.bigint :filterable_id
      t.string :target_model, null: false
      t.jsonb :filter_params, null: false, default: {}
      t.timestamps
    end
    
    add_index :universal_filters, [:filterable_type, :filterable_id]
    add_index :universal_filters, :target_model
  end
end
