New tables structure:

======================
Table explicit_votings
======================

Column: id
Data type: integer
Constraints: PRIMARY KEY, AUTO_INCREMENT
Description: Unikalny identyfikator każdego głosowania.

Column: title
Data type: string
Constraints: NOT NULL
Description: Pytanie głosowania.

Column: description
Data type: text
Constraints: 
Description: Materiał informacyjny wyświetlany przed głosowaniem.

Column: start_date
Data type: datetime
Constraints: 
Description: Data i czas rozpoczęcia głosowania.

Column: end_date
Data type: datetime
Constraints: NOT NULL
Description: Data i czas zakończenia głosowania.

Column: secret
Data type: boolean
Constraints: DEFAULT: FALSE
Description: Określa, czy głosowanie jest tajne.

Column: component_id
Data type: integer
Constraints: FOREIGN KEY (references components.id)
Description: Identyfikator komponentu Decidim, z którym powiązane jest głosowanie.

Column: created_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu utworzenia rekordu.

Column: updated_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu ostatniej aktualizacji rekordu.

=============================
Table explicit_voting_options
=============================

Column: id
Data type: integer
Constraints: PRIMARY KEY, AUTO_INCREMENT
Description: Unikalny identyfikator każdej opcji głosowania.

Column: voting_id
Data type: integer
Constraints: FOREIGN KEY (references votings.id), ON DELETE CASCADE
Description: Identyfikator głosowania, do którego należy ta opcja.

Column: name
Data type: string
Constraints: NOT NULL
Description: Nazwa opcji głosowania (np. ZA, PRZECIW, WSTRZYMUJĘ SIĘ).

Column: position
Data type: integer
Constraints: 
Description: Kolejność wyświetlania opcji głosowania.

Column: created_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu utworzenia rekordu.

Column: updated_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu ostatniej aktualizacji rekordu.

====================
Table explicit_votes
====================

Column: id
Data type: integer
Constraints: PRIMARY KEY, AUTO_INCREMENT
Description: Unikalny identyfikator każdego oddanego głosu.

Column: voting_id
Data type: integer
Constraints: FOREIGN KEY (references votings.id), ON DELETE CASCADE
Description: Identyfikator głosowania, w którym oddano głos.

Column: voting_option_id
Data type: integer
Constraints: FOREIGN KEY (references voting_options.id), ON DELETE CASCADE
Description: Identyfikator wybranej opcji głosowania.

Column: decidim_user_id
Data type: integer
Constraints: FOREIGN KEY (references decidim_users.id)
Description: Identyfikator użytkownika Decidim, który oddał głos.

Column: created_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu oddania głosu.

Column: updated_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu ostatniej aktualizacji rekordu.

Index: UNIQUE (voting_id, decidim_user_id)
Description: Zapewnia, że każdy użytkownik może oddać tylko jeden głos w danym głosowaniu.

===============================
Table explicit_voting_protocols
===============================

Column: id
Data type: integer
Constraints: PRIMARY KEY, AUTO_INCREMENT
Description: Unikalny identyfikator wygenerowanego protokołu.

Column: voting_id
Data type: integer
Constraints: FOREIGN KEY (references votings.id), ON DELETE CASCADE
Description: Identyfikator głosowania, dla którego wygenerowano protokół.

Column: generated_at
Data type: timestamp
Constraints: 
Description: Znacznik czasu wygenerowania protokołu.

Column: file_path
Data type: string
Constraints: 
Description: Ścieżka do wygenerowanego pliku protokołu (CSV/PDF).
