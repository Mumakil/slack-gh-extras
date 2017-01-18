# frozen_string_literal: true

##
# Creates users table
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.bigint :github_id, null: false
      t.string :github_token, null: false
      t.string :github_handle, null: false

      t.string :slack_id, null: false
      t.string :slack_handle, null: false

      t.timestamps

      t.index :github_id, unique: true
      t.index :slack_id, unique: true
    end
  end
end
