# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en"
  end

  # Ścieżka do pliku konfiguracyjnego względem bieżącego pliku specyfikacji
  let(:config_path) { File.expand_path('../../config/i18n-tasks.yml', __dir__) }

  # Ręczne ładowanie konfiguracji z pliku YAML
  let(:config) do
    File.exist?(config_path) ? YAML.load_file(config_path) : {}
  end

  # Wzorce kluczy do zignorowania (z załadowanego configu)
  # Upewniamy się, że to tablica, nawet jeśli klucz nie istnieje w YAML
  let(:ignore_patterns) { config['ignore_unused'] || [] }

  # Instancja i18n-tasks (tak jak poprzednio)
  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }

  # Pobieramy 'surową' listę nieużywanych kluczy z instancji i18n
  # Ta lista zawiera potencjalnie te 9 kluczy, bo instancja i18n ignoruje config
  let(:raw_unused_keys) { i18n.unused_keys }

  # === NOWA LOGIKA FILTROWANIA ===
  # Filtrujemy 'surową' listę kluczy używając wzorców ignore_unused
  let(:unused_keys) do
    raw_unused_keys.reject do |key_node|
      # key_node to obiekt; pobieramy pełny klucz jako string
      # (zakładamy, że obiekt odpowiada na metodę .full_key)
      full_key = key_node.full_key

      # Sprawdzamy, czy pełny klucz pasuje do KTÓREGOKOLWIEK wzorca z listy ignore_patterns
      ignore_patterns.any? do |pattern|
        # Używamy File.fnmatch? do obsługi wzorców z '*' (globbing)
        # jak w powłoce systemowej.
        # Opcje FNM_PATHNAME i FNM_EXTGLOB mogą być przydatne dla bardziej złożonych wzorców.
        File.fnmatch?(pattern, full_key, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end
    end
  end
  # =============================

  let(:missing_keys) { i18n.missing_keys }
  let(:non_normalized_paths) { i18n.non_normalized_paths }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it "correct Norwegian locale keys should be surrounded by quotation marks" do
    # otherwise psych evaluates `no:` to `false`
    # see https://makandracards.com/makandra/24809-yaml-keys-like-yes-or-no-evaluate-to-true-and-false
    i18n = I18n::Tasks::BaseTask.new(locales: "no")
    forest = i18n.data_forest(["no"])
    stats = i18n.forest_stats(forest)
    expect(stats[:locales]).to eq("no")
  end

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, please run `ENFORCED_LOCALES=#{locales} bundle exec i18n-tasks missing --locales #{locales}' to show them"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.count} unused i18n keys (after manual filtering): [#{unused_keys.map(&:full_key).join(', ')}]. Please run `bundle exec i18n-tasks unused --locales #{locales}' to show them"
  end

  unless ENV["SKIP_NORMALIZATION"]
    it "is normalized" do
      error_message = "The following files need to be normalized:\n" \
                      "#{non_normalized_paths.map { |path| "  #{path}" }.join("\n")}\n" \
                      "Please run `bundle exec i18n-tasks normalize --locales #{locales}` to fix them"

      expect(non_normalized_paths).to be_empty, error_message
    end
  end

  it "does not have inconsistent interpolations" do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Please run `bundle exec i18n-tasks check-consistent-interpolations --locales #{locales}` to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
