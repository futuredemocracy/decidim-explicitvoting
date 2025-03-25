# Decidim::ExplicitVoting

Moduł głosowania jawnego dla platformy Decidim.

## Funkcjonalności

- Możliwość ustawienia pytania oraz materiału informacyjnego przed głosowaniem
- Trzy domyślne opcje głosowania: ZA, PRZECIW, WSTRZYMUJĘ SIĘ (z możliwością zmiany nazw)
- Głosujący po oddaniu głosu nie widzi natychmiastowego wyniku
- Po zakończeniu głosowania wyświetlane są wyniki (liczba głosów dla każdej opcji)
- Możliwość wygenerowania protokołu głosowania (lista głosujących i ich wyborów)
- Opcja tajnego głosowania (wyniki ogólne widoczne dla wszystkich, lista głosujących tylko dla administratora)

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