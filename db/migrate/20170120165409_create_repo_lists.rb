# frozen_string_literal: true

##
# Creates RepoLists table
class CreateRepoLists < ActiveRecord::Migration[5.0]
  def change
    create_table :repo_lists do |t|
      t.string :name, null: false
      t.timestamps

      t.index :name, unique: true
    end
  end
end
