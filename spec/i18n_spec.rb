# frozen_string_literal: true

require "i18n/tasks"
require 'yaml' # Needed to load the YAML file

describe "I18n sanity" do
  # Provides the locales to check, defaults to "en"
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en"
  end

  # Path to the module's config file relative to project root
  # (assuming test runs from project root using Dir.pwd)
  let(:config_path) do
    # Optional check to verify the expected structure relative to Dir.pwd
    project_root = Dir.pwd
    module_dir = File.join(project_root, 'decidim-explicit-voting')
    unless Dir.exist?(module_dir)
      # If this fails, the assumption about the working directory might be wrong
      raise "Test running from unexpected directory? Expected 'decidim-explicit-voting' subdir in '#{project_root}'"
    end
    File.expand_path('decidim-explicit-voting/config/i18n-tasks.yml', project_root)
  end

  # Manually load the configuration from the YAML file
  let(:config) do
    File.exist?(config_path) ? YAML.load_file(config_path) : {}
  end

  # Ignore patterns for unused keys (from loaded config)
  # Ensures it's an array, even if the key is missing in YAML
  let(:ignore_patterns) { config['ignore_unused'] || [] }

  # i18n-tasks instance (likely loads config implicitly, but we don't rely on it)
  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }

  # Get the 'raw' list of unused keys from the i18n instance
  # This list potentially contains keys that should be ignored according to config
  let(:raw_unused_keys) { i18n.unused_keys }

  # === MANUAL FILTERING LOGIC ===
  # Filter the 'raw' list of keys using the ignore_unused patterns loaded from config
  let(:unused_keys) do
    raw_unused_keys.reject do |key_node|
      # key_node is an object; get the full key as a string
      # Use .to_s for safety in case full_key returns non-string
      full_key = key_node.full_key.to_s

      # Check if the full key matches ANY pattern from the ignore_patterns list
      ignore_patterns.any? do |pattern|
        # Use File.fnmatch? to handle globbing patterns ('*') like in shell
        # FNM_PATHNAME and FNM_EXTGLOB options can be useful for complex patterns
        File.fnmatch?(pattern, full_key, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end
    end
  end
  # ============================

  # Other let blocks related to different i18n checks
  let(:missing_keys) { i18n.missing_keys }
  let(:non_normalized_paths) { i18n.non_normalized_paths }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  # Test specific to Norwegian locale (psych YAML parsing quirk)
  it "correct Norwegian locale keys should be surrounded by quotation marks" do
    i18n_no = I18n::Tasks::BaseTask.new(locales: "no")
    forest = i18n_no.data_forest(["no"])
    stats = i18n_no.forest_stats(forest)
    expect(stats[:locales]).to eq("no")
  end

  # Test checking for missing keys (uses 'missing_keys' let block)
  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, please run `ENFORCED_LOCALES=#{locales} bundle exec i18n-tasks missing --locales #{locales}' to show them"
  end

  # Test checking for unused keys (uses the manually filtered 'unused_keys' let block)
  it "does not have unused keys" do
    # Expect the manually filtered list to be empty
    expect(unused_keys).to be_empty,
                           "#{unused_keys.count} unused i18n keys (after manual filtering based on config). Please run `bundle exec i18n-tasks unused --locales #{locales}' to show them"
                           # Optional: Include keys in msg: "[#{unused_keys.map(&:full_key).join(', ')}]"
  end

  # Test checking for normalization (unless skipped via ENV variable)
  unless ENV["SKIP_NORMALIZATION"]
    it "is normalized" do
      error_message = "The following files need to be normalized:\n" \
                      "#{non_normalized_paths.map { |path| "  #{path}" }.join("\n")}\n" \
                      "Please run `bundle exec i18n-tasks normalize --locales #{locales}` to fix them"

      expect(non_normalized_paths).to be_empty, error_message
    end
  end

  # Test checking for inconsistent interpolations
  it "does not have inconsistent interpolations" do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Please run `bundle exec i18n-tasks check-consistent-interpolations --locales #{locales}` to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end