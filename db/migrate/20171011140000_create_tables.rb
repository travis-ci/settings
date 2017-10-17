class CreateTables < ActiveRecord::Migration[5.1]
  def change
    create_table :repositories do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :owner_name
      t.string :name
    end

    create_table :users do |t|
      t.string :login
    end

    create_table :organizations do |t|
      t.string :login
    end

    create_table :env_vars do |t|
      t.integer :owner_id
      t.string  :owner_type
      t.string :name
      t.string :value
      t.boolean :private
    end

    create_table :settings do |t|
      t.string :key
      t.integer :owner_id
      t.string  :owner_type
      t.string :value
      t.datetime :expires_at
      t.text :comment
    end
  end
end
