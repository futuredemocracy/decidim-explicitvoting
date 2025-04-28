class CreateDecidimExplicitVotingVotings < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_explicit_voting_votings do |t|
      t.jsonb :title, null: false
      t.jsonb :description, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.boolean :secret, default: false
      t.integer :quorum, default: 0
      t.references :decidim_component, null: false, foreign_key: true, index: { name: "decidim_exp_voting_votings_on_component_id" }

      t.timestamps
    end
  end
end
