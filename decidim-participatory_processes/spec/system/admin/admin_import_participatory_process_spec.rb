# frozen_string_literal: true

require "spec_helper"

describe "Admin imports participatory process" do
  include_context "when admin administrating a participatory process"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "with context" do
    before "Imports the process with the basic fields" do
      within_admin_menu do
        click_on "Import"
      end

      within ".import_participatory_process" do
        fill_in_i18n(
          :participatory_process_title,
          "#participatory_process-title-tabs",
          en: "Import participatory process",
          es: "Importación del proceso participativo",
          ca: "Importació del procés participatiu"
        )
        fill_in :participatory_process_slug, with: "pp-import"
      end

      stub_get_request_with_format("http://localhost:3000/uploads/decidim/participatory_process/hero_image/1/city.jpeg", "image/jpeg")

      dynamically_attach_file(:participatory_process_document, Decidim::Dev.asset("participatory_processes.json"))

      click_on "Import"
    end

    it "imports the json document" do
      expect(page).to have_content("successfully")
      expect(page).to have_content("Import participatory process")
      expect(page).to have_content("Unpublished")

      within "tr", text: "Import participatory process" do
        click_on "Import participatory process"
      end

      within_admin_sidebar_menu do
        click_on "Phases"
      end

      within ".table-list" do
        expect(page).to have_content(translated("Magni."))
      end

      within_admin_sidebar_menu do
        click_on "Components"
      end

      expect(Decidim::ParticipatoryProcess.last.components.size).to eq(3)
      within ".table-list" do
        Decidim::ParticipatoryProcess.last.components.each do |component|
          expect(page).to have_content(translated(component.name))
        end
      end

      within_admin_sidebar_menu do
        click_on "Attachments"
      end

      if Decidim::ParticipatoryProcess.last.attachments.any?
        within ".table-list" do
          Decidim::ParticipatoryProcess.last.attachments.each do |attachment|
            expect(page).to have_content(translated(attachment.title))
          end
        end
      end
    end
  end
end
