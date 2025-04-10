# Decidim Explicit Voting

Moduł do przeprowadzania głosowań w systemie Decidim.

## Funkcjonalności

1. Możliwość ustawienia pytania oraz materiału informacyjnego przed głosowaniem (pole tekstowe dla administratora).
2. Trzy domyślne opcje głosowania: ZA, PRZECIW, WSTRZYMUJĘ SIĘ (z możliwością zmiany nazw przez administratora).
3. Głosujący po oddaniu głosu nie widzi natychmiastowego wyniku.
4. Po zakończeniu głosowania (określonym przez administratora czasie) wyświetlane są wyniki (liczba głosów dla każdej opcji).
5. Możliwość wygenerowania "protokołu głosowania" – lista głosujących i ich wyborów (jeśli nie jest to głosowanie tajne).
6. Opcja tajnego głosowania – wyniki ogólne widoczne dla wszystkich, ale lista głosujących dostępna tylko dla administratora.

## Opis procesu głosowania

### Widok użytkownika

1. Użytkownik przechodzi do sekcji głosowania w ramach konkretnego procesu.
2. Czyta opis głosowania [pole tekstowe].
3. Wybiera jedną z dostępnych opcji ("ZA", "PRZECIW", "WSTRZYMUJĘ SIĘ" lub ich zmodyfikowane nazwy).
4. Klikając "Oddaj głos", kończy swój udział w głosowaniu, ew. klika na przycisk ZA, PRZECIW itd
5. Otrzymuje komunikat potwierdzający oddanie głosu bez możliwości zmiany decyzji.
6. Po zakończeniu głosowania pojawia się widok lub możliwość pobrania protokołu (lista głosów i wyborów, jeśli nie jest tajne).

### Widok administratora

1. Tworzenie nowego głosowania:
   a) Ustawienie pytania i opisu.
   b) Ustalenie czasu trwania głosowania.
   c) Wybór trybu głosowania (jawne/tajne = brak wyświetlenia pkt 6 uzytkownikom).
2. Podgląd trwających głosowań.
3. Po zakończeniu głosowania:
   a) Wyświetlenie wyników.
   b) Pobranie protokołu (lista głosów i wyborów).
   c) Możliwość eksportu danych do pliku CSV/PDF.

## Instalacja

Dodaj ten gem do pliku Gemfile swojej aplikacji:

```ruby
gem "decidim-explicit_voting"
```

I wykonaj:

```bash
bundle install
bundle exec rails decidim_explicit_voting:install:migrations
bundle exec rails db:migrate
```

## Czcionki DejaVu

Ten moduł wykorzystuje czcionki DejaVu do generowania plików PDF z poprawną obsługą znaków UTF-8. Aby zapewnić prawidłowe działanie funkcji PDF, należy:

1. Pobrać czcionki DejaVu z oficjalnej strony: [Czcionki DejaVu](https://dejavu-fonts.github.io/)
2. Utworzyć katalog `app/assets/fonts` w głównej aplikacji Decidim (nie w module explicit-voting)
3. Umieścić następujące pliki czcionek w tym katalogu:
   - DejaVuSans.ttf
   - DejaVuSans-Bold.ttf
   - DejaVuSans-Oblique.ttf
   - DejaVuSans-BoldOblique.ttf
4. Upewnić się, że czcionki są uwzględnione w asset pipeline, dodając następujący kod do pliku `config/initializers/assets.rb`:
   ```ruby
   Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
   ```
5. Zrestartować serwer Rails po wprowadzeniu tych zmian

Te czcionki są wymagane do prawidłowego generowania protokołów głosowania i raportów ze znakami diakrytycznymi.

## Użycie

### Konfiguracja komponentu

1. Przejdź do panelu administracyjnego
2. Wybierz proces partycypacyjny
3. Dodaj komponent "Głosowanie Jawne"
4. Skonfiguruj ustawienia komponentu

### Tworzenie głosowania

1. Przejdź do panelu administracyjnego komponentu
2. Kliknij "Nowe głosowanie"
3. Wypełnij formularz:
   - Tytuł i opis głosowania
   - Data rozpoczęcia i zakończenia
   - Wybierz czy głosowanie ma być tajne

### Oddawanie głosów

1. Użytkownik przechodzi do sekcji głosowania
2. Czyta opis głosowania
3. Wybiera jedną z dostępnych opcji
4. Zatwierdza swój wybór
5. Otrzymuje potwierdzenie oddania głosu

### Wyniki głosowania

1. Po zakończeniu głosowania wyniki są automatycznie publikowane
2. Administrator może pobrać protokół głosowania zawierający:
   - Liczbę oddanych głosów
   - Rozkład głosów na poszczególne opcje
   - Listę głosujących (w przypadku głosowania jawnego)

## Rozwój

### Testy

Aby uruchomić testy:

```bash
bundle exec rspec
```

### Tłumaczenia

Moduł wspiera wielojęzyczność. Tłumaczenia znajdują się w katalogu `config/locales`.

## Licencja

Kod źródłowy jest dostępny na licencji [GNU AFFERO GENERAL PUBLIC LICENSE](LICENSE-AGPLv3.txt).

## Współpraca

Zobacz [Decidim](https://github.com/decidim/decidim). 