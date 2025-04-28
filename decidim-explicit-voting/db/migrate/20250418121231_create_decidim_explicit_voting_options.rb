class CreateDecidimExplicitVotingOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_explicit_voting_options do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade },
                   index: { name: "decidim_exp_voting_options_on_voting_id" }
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end
  end
end
