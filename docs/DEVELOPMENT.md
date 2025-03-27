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