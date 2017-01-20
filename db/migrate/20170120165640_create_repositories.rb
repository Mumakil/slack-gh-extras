# frozen_string_literal: true

##
# Creates Repositories table
class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :repositories do |t|
      t.string :name, null: false
      t.references :repo_list, foreign_key: true, null: false

      t.timestamps

      t.index [:name, :repo_list_id], unique: true
    end
  end
end
