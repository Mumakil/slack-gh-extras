# frozen_string_literal: true

##
# Creates channels table
class CreateChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :channels do |t|
      t.string :slack_id, null: false
      t.string :name, null: false
      t.string :default_repositories, null: false

      t.timestamps

      t.index :slack_id, unique: true
    end
  end
end
