BEGIN;

-- Tworzenie tabeli głosowań
CREATE TABLE decidim_explicit_votings (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP NOT NULL,
    secret BOOLEAN DEFAULT FALSE,
    decidim_component_id INTEGER REFERENCES decidim_components(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tworzenie tabeli opcji głosowania
CREATE TABLE decidim_explicit_voting_options (
    id SERIAL PRIMARY KEY,
    voting_id INTEGER REFERENCES decidim_explicit_votings(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    position INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tworzenie tabeli głosów
CREATE TABLE decidim_explicit_votes (
    id SERIAL PRIMARY KEY,
    voting_id INTEGER REFERENCES decidim_explicit_votings(id) ON DELETE CASCADE,
    voting_option_id INTEGER REFERENCES decidim_explicit_voting_options(id) ON DELETE CASCADE,
    decidim_user_id INTEGER REFERENCES decidim_users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Dodanie unikalnego indeksu dla głosów
CREATE UNIQUE INDEX decidim_explicit_votes_unique_user_and_voting 
ON decidim_explicit_votes (voting_id, decidim_user_id);

-- Tworzenie tabeli protokołów
CREATE TABLE decidim_explicit_voting_protocols (
    id SERIAL PRIMARY KEY,
    voting_id INTEGER REFERENCES decidim_explicit_votings(id) ON DELETE CASCADE,
    generated_at TIMESTAMP,
    file_path VARCHAR
);

COMMIT;
