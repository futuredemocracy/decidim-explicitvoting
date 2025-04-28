class CreateDecidimExplicitVotingProtocols < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_explicit_voting_protocols do |t|
      t.references :voting,
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade },
                   index: { name: "decidim_exp_voting_protocols_on_voting_id" }
      t.timestamp :generated_at
      t.string :file_path

      t.timestamps
    end
  end
end
