# Instalacja środowiska deweloperskiego

## Wymagania wstępne

- Ruby 3.3.7
- PostgreSQL
- Node.js i Yarn
- Git

## Konfiguracja Git i SSH

1. Wygeneruj klucz SSH:
```bash
ssh-keygen -t ed25519 -C "twoj@email.com"
```

2. Dodaj klucz do agenta SSH:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

3. Sprawdź połączenie z GitHub:
```bash
ssh -T git@github.com
```

4. Sklonuj repozytorium używając SSH:
```bash
git clone git@github.com:futuredemocracy/decidim-explicitvoting.git
```

## Instalacja Ruby przez rbenv

1. Zainstaluj rbenv i ruby-build:
```bash
sudo apt update
sudo apt install rbenv ruby-build
```

2. Skonfiguruj rbenv:
```bash
rbenv init
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

3. Zainstaluj Ruby:
```bash
rbenv install 3.3.7
rbenv global 3.3.7
```

4. Sprawdź instalację:
```bash
ruby -v
```

## Konfiguracja bazy danych

1. Utwórz użytkownika PostgreSQL:
```bash
sudo -u postgres createuser -d -R -S decidim
sudo -u postgres psql -c "ALTER USER decidim WITH PASSWORD 'decidim';"
```

2. Utwórz bazę danych:
```bash
sudo -u postgres createdb -O decidim decidim_development
```

3. Sprawdź połączenie z bazą danych:
```bash
PGPASSWORD=decidim psql -h 127.0.0.1 -U decidim -d postgres
```

## Instalacja modułu

1. Przejdź do katalogu projektu:
```bash
cd decidim-explicitvoting
```

2. Zainstaluj zależności Ruby:
```bash
bundle install
```

3. Ustaw zmienne środowiskowe:
```bash
export RAILS_ENV=development
export RAILS_MASTER_KEY=1234567890abcdef1234567890abcdef
export DATABASE_USERNAME=decidim
export DATABASE_PASSWORD=decidim
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT=5432
export SKIP_SEEDS=true
```

4. Utwórz aplikację deweloperską:
```bash
bundle exec rake development_app
```

5. Przejdź do katalogu aplikacji deweloperskiej:
```bash
cd development_app
```

6. Zainstaluj zależności JavaScript:
```bash
yarn install
```

7. Zainstaluj migracje modułu:
```bash
bundle exec rake decidim_explicit_voting:install:migrations
```

8. Wykonaj migracje:
```bash
bundle exec rake db:migrate
```

9. Uruchom serwer:
```bash
bundle exec rails server
```

Aplikacja będzie dostępna pod adresem `http://localhost:3000`.

## Logowanie do aplikacji

Domyślne dane logowania:
- Email: admin@example.org
- Hasło: decidim123456

## Rozwiązywanie problemów

### Błędy związane z bazą danych

Jeśli występują problemy z połączeniem do bazy danych:
1. Sprawdź, czy PostgreSQL jest uruchomiony
2. Upewnij się, że użytkownik `decidim` ma odpowiednie uprawnienia
3. Sprawdź, czy zmienne środowiskowe są poprawnie ustawione
4. Sprawdź połączenie z bazą danych używając:
```bash
PGPASSWORD=decidim psql -h 127.0.0.1 -U decidim -d postgres
```

### Błędy związane z migracjami

Jeśli występują problemy z migracjami:
1. Upewnij się, że wszystkie zależności są zainstalowane
2. Spróbuj usunąć i ponownie utworzyć bazę danych
3. Sprawdź logi aplikacji w pliku `development_app.log`
4. Upewnij się, że wszystkie zmienne środowiskowe są ustawione

### Problemy z rbenv

Jeśli występują problemy z rbenv:
1. Sprawdź, czy rbenv jest poprawnie zainstalowany:
```bash
rbenv -v
```

2. Upewnij się, że ścieżka do rbenv jest dodana do `.bashrc`:
```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

3. Sprawdź dostępne wersje Ruby:
```bash
rbenv install --list
```

### Alternatywny sposób przekazywania zmiennych środowiskowych

Jeśli występują problemy z ustawianiem zmiennych środowiskowych, możesz przekazać je bezpośrednio w komendzie:

```bash
RAILS_ENV=development \
RAILS_MASTER_KEY=1234567890abcdef1234567890abcdef \
DATABASE_USERNAME=decidim \
DATABASE_PASSWORD=decidim \
DATABASE_HOST=127.0.0.1 \
DATABASE_PORT=5432 \
SKIP_SEEDS=true \
bundle exec rake development_app
```

lub w jednej linii:

```bash
RAILS_ENV=development RAILS_MASTER_KEY=1234567890abcdef1234567890abcdef DATABASE_USERNAME=decidim DATABASE_PASSWORD=decidim DATABASE_HOST=127.0.0.1 DATABASE_PORT=5432 SKIP_SEEDS=true bundle exec rake development_app
```

Ten sposób jest szczególnie przydatny, gdy:
1. Zmienne środowiskowe nie są poprawnie ustawione w systemie
2. Chcesz uruchomić komendę z innymi wartościami zmiennych
3. Masz problemy z konfiguracją pliku `.env.development`

Pamiętaj, że musisz używać tego formatu dla wszystkich komend rake, które wymagają zmiennych środowiskowych, np.:
```bash
RAILS_ENV=development RAILS_MASTER_KEY=1234567890abcdef1234567890abcdef DATABASE_USERNAME=decidim DATABASE_PASSWORD=decidim DATABASE_HOST=127.0.0.1 DATABASE_PORT=5432 SKIP_SEEDS=true bundle exec rake db:migrate
```

## Struktura modułu

- `lib/decidim/explicit_voting/` - główny kod modułu
  - `admin/` - kontrolery panelu administracyjnego
  - `engine.rb` - główny silnik modułu
  - `admin_engine.rb` - silnik panelu administracyjnego
  - `component.rb` - definicja komponentu
  - `vote.rb` - model głosu
  - `voting.rb` - model głosowania
  - `voting_option.rb` - model opcji głosowania

## Rozwój modułu

1. Wszystkie zmiany w kodzie powinny być testowane lokalnie
2. Używaj `bundle exec` przed komendami rake
3. Sprawdzaj logi w pliku `development_app.log`
4. Używaj `SKIP_SEEDS=true` aby pominąć przykładowe dane
5. W przypadku problemów z bazą danych, sprawdź uprawnienia użytkownika PostgreSQL
6. Upewnij się, że wszystkie zmienne środowiskowe są ustawione przed uruchomieniem komend 

## Konfiguracja uprawnień

### Struktura uprawnień

Moduł używa dwóch klas uprawnień:

1. `Decidim::ExplicitVoting::Admin::Permissions` - dla panelu administracyjnego
2. `Decidim::ExplicitVoting::Permissions` - dla głównego modułu

### Konfiguracja uprawnień komponentu

Uprawnienia komponentu są konfigurowane w następujących miejscach:

1. W pliku `lib/decidim/explicit_voting/component.rb`:
```ruby
component.permissions_class_name = "Decidim::ExplicitVoting::Permissions"
component.actions = %w(create read update destroy)
```

2. W bazie danych poprzez ustawienie uprawnień dla komponentu:
```ruby
component.update!(
  permissions: {
    "admin" => {
      "authorization_handlers" => {
        "default" => {
          "options" => {
            "permissions" => {
              "manage" => true,
              "create" => true,
              "read" => true,
              "update" => true,
              "destroy" => true
            }
          }
        }
      }
    }
  }
)
```

### Kontrolery administracyjne

Kontrolery administracyjne powinny dziedziczyć od `Decidim::Admin::Components::BaseController`, który zapewnia:

1. Dostęp do komponentu poprzez `current_component`
2. Dostęp do przestrzeni partycypacyjnej poprzez `current_participatory_space`
3. Podstawowe uprawnienia i autoryzację
4. Odpowiedni layout i helpers

Przykład implementacji kontrolera bazowego:
```ruby
class ApplicationController < Decidim::Admin::Components::BaseController
  layout "decidim/admin/application"

  def permission_class_chain
    [
      Decidim::ExplicitVoting::Admin::Permissions,
      Decidim::Admin::Permissions
    ]
  end
end
```

### Rozwiązywanie problemów z uprawnieniami

1. Sprawdź, czy użytkownik jest administratorem:
```ruby
user = Decidim::User.find_by(email: "admin@example.org")
puts "Admin?: #{user.admin?}"
```

2. Sprawdź uprawnienia komponentu:
```ruby
component = Decidim::Component.find_by(manifest_name: "explicit_voting")
puts "Uprawnienia: #{component.permissions.inspect}"
```

3. Sprawdź, czy użytkownik jest administratorem przestrzeni:
```ruby
space = component.participatory_space
puts "Space admin?: #{space.admins.include?(user)}"
```

4. Sprawdź, czy klasa uprawnień jest załadowana:
```ruby
begin
  puts "Klasa uprawnień istnieje?: #{defined?(Decidim::ExplicitVoting::Permissions) != nil}"
rescue => e
  puts "Błąd sprawdzania klasy uprawnień: #{e.message}"
end
```

### Najczęstsze problemy

1. Brak uprawnień "manage" w konfiguracji komponentu
2. Niepoprawna implementacja klasy uprawnień
3. Brak wymaganych concernów w kontrolerze
4. Niepoprawna konfiguracja przestrzeni partycypacyjnej

### Rozwiązywanie problemów

1. Zrestartuj serwer Rails po zmianach w uprawnieniach
2. Sprawdź logi aplikacji w `development_app/log/development.log`
3. Użyj konsoli Rails do debugowania uprawnień
4. Upewnij się, że wszystkie wymagane pliki są w odpowiednich lokalizacjach 

Podsumowanie Debugowania Komponentu decidim-explicit-voting
Problem: Podczas tworzenia komponentu decidim-explicit-voting napotkano serię błędów uniemożliwiających poprawne działanie panelu administracyjnego i interakcję z bazą danych.

Sekwencja Błędów i Zastosowane Rozwiązania:

Błędy Konfiguracji Kontrolera Admina:

Błędy: NameError: uninitialized constant Decidim::NeedsComponent, NoMethodError: undefined method 'belongs_to' for class ...Controller.
Przyczyna: Próba użycia nieistniejącego modułu (NeedsComponent) oraz niepoprawne włączenie modułu Decidim::HasComponent (przeznaczonego dla modeli ActiveRecord) do kontrolera. Błędne dziedziczenie kontrolera bazowego.
Rozwiązanie: Poprawienie dziedziczenia głównego kontrolera administracyjnego komponentu (Admin::ApplicationController) na Decidim::Admin::Components::BaseController. Usunięcie niepoprawnego include Decidim::HasComponent z kontrolera.
Błąd Autoryzacji w Panelu Admina:

Błąd: You are not authorized to perform this action. podczas próby dostępu do zarządzania komponentem.
Przyczyna: Brak zdefiniowanej reguły w klasie uprawnień (Admin::Permissions) pozwalającej na wykonanie akcji :read na zasobie :participatory_space. Ta podstawowa weryfikacja była wymagana przez kontroler bazowy Decidim przed udzieleniem dostępu do widoków zarządzania komponentem.
Rozwiązanie: Dodanie w metodzie permissions (w klasie Decidim::ExplicitVoting::Admin::Permissions dziedziczącej z Decidim::DefaultPermissions) warunku sprawdzającego subject == :participatory_space i action == :read, który przyznaje dostęp (allow!) administratorom (globalnym lub przestrzeni).
Błąd Braku Tabeli w Bazie Danych:

Błąd: PG::UndefinedTable: ERROR: relation "decidim_explicit_voting_votings" does not exist.
Przyczyna: Niezgodność nazwy tabeli zdefiniowanej w pliku migracji (decidim_explicit_votings - liczba pojedyncza) z oczekiwaniami ActiveRecord opartymi na konwencji Rails i nazwie modelu Voting (decidim_explicit_voting_votings - liczba mnoga).
Rozwiązanie: Poprawienie pliku migracji: zmiana nazwy tabeli głównej na decidim_explicit_voting_votings oraz aktualizacja odwołań (kluczy obcych foreign_key: { to_table: ... }) w definicjach pozostałych tabel (_options, _votes, _protocols). Następnie cofnięcie błędnej migracji (bin/rails db:rollback STEP=1) i ponowne uruchomienie poprawionej migracji (bin/rails db:migrate).
Problemy z Inicjalizacją Bazy Danych i Odczytem Credentials:

Błędy: ERROR: relation "schema_migrations" does not exist (w psql), ActiveRecord::ConnectionNotEstablished: ... no password supplied (podczas db:prepare), ActiveSupport::MessageEncryptor::InvalidMessage (podczas db:prepare).
Przyczyna: Baza danych decidim_development nie była poprawnie zainicjowana dla aplikacji Rails (brak kluczowej tabeli schema_migrations). Kolejne błędy podczas próby wykonania db:prepare (problem z hasłem, a następnie z deszyfrowaniem credentials mimo podania poprawnego klucza RAILS_MASTER_KEY odczytanego z config/master.key) były najprawdopodobniej spowodowane przez zakłócenia ze strony preloadera Spring lub nieaktualny stan środowiska wykonawczego zadania Rake. Wykonanie bin/rails credentials:edit potwierdziło, że klucz i plik credentials były w rzeczywistości poprawne.
Rozwiązanie: Użycie polecenia bin/rails db:prepare (z odpowiednimi zmiennymi RAILS_ENV i RAILS_MASTER_KEY, choć ostatecznie zadziałało bez RAILS_MASTER_KEY dzięki config/master.key) w celu poprawnego zainicjowania bazy (wczytania schema.rb, utworzenia schema_migrations) i uruchomienia wszystkich migracji, w tym poprawionej migracji komponentu. Kluczowe było kilkukrotne próbowanie i upewnienie się, że Spring (bin/spring stop) nie zakłóca procesu.