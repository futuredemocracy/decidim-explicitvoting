# frozen_string_literal: true

class CreateDecidimExplicitVotingTables < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_explicit_votings do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date, null: false
      t.boolean :secret, default: false
      t.references :decidim_component, foreign_key: true, index: true

      t.timestamps
    end

    create_table :decidim_explicit_voting_options do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_votings, on_delete: :cascade },
                   index: true
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end

    create_table :decidim_explicit_votes do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_votings, on_delete: :cascade },
                   index: true
      t.references :voting_option,
                   foreign_key: { to_table: :decidim_explicit_voting_options, on_delete: :cascade },
                   index: true
      t.references :decidim_user,
                   foreign_key: true,
                   index: true

      t.timestamps
    end

    add_index :decidim_explicit_votes,
              [:voting_id, :decidim_user_id],
              unique: true,
              name: "decidim_explicit_votes_unique_user_and_voting"

    create_table :decidim_explicit_voting_protocols do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_votings, on_delete: :cascade },
                   index: true
      t.timestamp :generated_at
      t.string :file_path
    end
  end
end 