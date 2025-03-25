# frozen_string_literal: true

class CreateDecidimExplicitVotingVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_explicit_voting_votes do |t|
      t.references :decidim_author, null: false, foreign_key: { to_table: :decidim_users }
      t.references :decidim_organization, null: false, foreign_key: true
      t.references :votable, polymorphic: true, null: false
      t.string :vote_type, null: false
      t.timestamps
    end

    add_index :decidim_explicit_voting_votes, [:votable_type, :votable_id, :decidim_author_id], 
              unique: true, 
              name: "index_decidim_explicit_voting_votes_on_votable_and_author"
  end
end 