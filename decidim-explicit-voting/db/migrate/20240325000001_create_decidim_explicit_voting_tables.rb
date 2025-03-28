# frozen_string_literal: true

# Zmień na odpowiednią wersję ActiveRecord, jeśli używasz innej niż 6.1
class CreateDecidimExplicitVotingTables < ActiveRecord::Migration[6.1]
  def change
    # === POPRAWKA 1: Zmiana nazwy tabeli na liczbę mnogą ===
    create_table :decidim_explicit_voting_votings do |t| # <--- Zmieniono na liczbę mnogą
      t.string :title, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date, null: false
      t.boolean :secret, default: false
      # Indeks jest tworzony automatycznie przez `references`, ale możemy zostawić dla pewności
      t.references :decidim_component, null: false, foreign_key: true, index: { name: "decidim_exp_voting_votings_on_component_id" } # Skrócona nazwa indeksu, aby uniknąć przekroczenia limitu długości

      t.timestamps
    end

    create_table :decidim_explicit_voting_options do |t|
      t.references :voting, # Ta nazwa kolumny (voting_id) jest OK
                   # === POPRAWKA 2: Aktualizacja docelowej tabeli w kluczu obcym ===
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade }, # <--- Zmieniono na liczbę mnogą
                   index: { name: "decidim_exp_voting_options_on_voting_id" } # Skrócona nazwa indeksu
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end

    create_table :decidim_explicit_votes do |t|
      t.references :voting, # Ta nazwa kolumny (voting_id) jest OK
                   # === POPRAWKA 3: Aktualizacja docelowej tabeli w kluczu obcym ===
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade }, # <--- Zmieniono na liczbę mnogą
                   index: { name: "decidim_exp_voting_votes_on_voting_id" } # Skrócona nazwa indeksu
      t.references :voting_option,
                   foreign_key: { to_table: :decidim_explicit_voting_options, on_delete: :cascade },
                   index: { name: "decidim_exp_voting_votes_on_option_id" } # Skrócona nazwa indeksu
      t.references :decidim_user,
                   foreign_key: true, # Zakłada, że tabela decidim_users istnieje
                   index: { name: "decidim_exp_voting_votes_on_user_id" } # Skrócona nazwa indeksu

      t.timestamps
    end

    add_index :decidim_explicit_votes,
              [:voting_id, :decidim_user_id],
              unique: true,
              # === POPRAWKA 4: Skrócenie nazwy indeksu unikalnego ===
              name: "decidim_exp_votes_unique_user_voting" # <--- Skrócona nazwa indeksu

    create_table :decidim_explicit_voting_protocols do |t|
      t.references :voting, # Ta nazwa kolumny (voting_id) jest OK
                   # === POPRAWKA 5: Aktualizacja docelowej tabeli w kluczu obcym ===
                   foreign_key: { to_table: :decidim_explicit_voting_votings, on_delete: :cascade }, # <--- Zmieniono na liczbę mnogą
                   index: { name: "decidim_exp_voting_protocols_on_voting_id" } # Skrócona nazwa indeksu
      t.timestamp :generated_at
      t.string :file_path
      # Dodano timestamps - zazwyczaj się przydają
      t.timestamps
    end
  end
end