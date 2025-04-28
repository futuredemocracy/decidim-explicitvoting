module Decidim
  module ExplicitVoting
    class GenerateProtocolPdf < Decidim::Command
      attr_reader :voting

      def initialize(voting)
        @voting = voting
      end

      def call
        raise "Prawn gem is missing" unless defined?(Prawn)

        pdf = Prawn::Document.new
        set_font(pdf)
        build_header(pdf)
        build_results(pdf)
        build_voters_list(pdf) unless voting.secret?
        build_footer(pdf)
        pdf
      end

      private

      def set_font(pdf)
        pdf.font_families.update(
          "DejaVu" => {
            normal: Rails.root.join("app/assets/fonts/DejaVuSans.ttf").to_s,
            bold: Rails.root.join("app/assets/fonts/DejaVuSans-Bold.ttf").to_s,
            italic: Rails.root.join("app/assets/fonts/DejaVuSans-Oblique.ttf").to_s,
            bold_italic: Rails.root.join("app/assets/fonts/DejaVuSans-BoldOblique.ttf").to_s
          }
        )
        pdf.fallback_fonts(["DejaVu"])
        pdf.font("DejaVu")
      end

      def build_header(pdf)
        pdf.font_size(16) { pdf.text "Protokół głosowania", align: :center }
        pdf.move_down 10
        pdf.text "ID głosowania: #{voting.id}"
        pdf.text "Pytanie: #{translated_attribute(voting.title)}"
        pdf.text "Data rozpoczęcia: #{I18n.l(voting.start_date, format: :long) if voting.start_date}"
        pdf.text "Data zakończenia: #{I18n.l(voting.end_date, format: :long)}"
        pdf.text "Głosowanie #{voting.secret? ? 'tajne' : 'jawne'}"
        if voting.active?
          pdf.move_down 10
          pdf.text "Głosowanie jest w trakcie w momencie wykonywania eksportu do sprawozdania", style: :italic
        end
        pdf.move_down 20
      end

      def build_results(pdf)
        pdf.font_size(14) { pdf.text "Wyniki głosowania:", style: :bold }
        pdf.move_down 10
        options_data = [["Opcja", "Liczba głosów", "Procent"]]
        total_votes = voting.votes.count
        result_text = I18n.t("decidim.explicit_voting.votings.show.results.#{voting.result_translation_key}")
        pdf.text result_text, style: :italic
        voting.options.each do |option|
          votes_count = option.votes.count
          percent = total_votes > 0 ? (votes_count.to_f / total_votes * 100).round(2) : 0
          options_data << [translated_attribute(option.name), votes_count.to_s, "#{percent}%"]
        end

        pdf.table(options_data, width: pdf.bounds.width) do
          row(0).font_style = :bold
          columns(1..2).align = :center
        end

        pdf.move_down 20
      end

      def build_voters_list(pdf)
        pdf.font_size(14) { pdf.text "Lista głosujących:", style: :bold }
        pdf.move_down 10
        votes_data = [["Użytkownik", "Wybrana opcja", "Data oddania głosu"]]

        voting.votes.includes(:user, :voting_option).each do |vote|
          user_name = vote.user&.name || "Nieznany użytkownik"
          option_name = translated_attribute(vote.voting_option&.name) || "Nieznana opcja"
          votes_data << [user_name, option_name, I18n.l(vote.created_at, format: :long)]
        end

        pdf.table(votes_data, width: pdf.bounds.width) do
          row(0).font_style = :bold
        end
      end

      def build_footer(pdf)
        pdf.move_down 30
        pdf.text "Protokół wygenerowany: #{I18n.l(Time.current, format: :long)}", align: :right
      end

      def translated_attribute(attribute)
        I18n.with_locale(I18n.locale) do
          attribute.is_a?(Hash) ? attribute[I18n.locale.to_s] : attribute
        end
      end
    end
  end
end
