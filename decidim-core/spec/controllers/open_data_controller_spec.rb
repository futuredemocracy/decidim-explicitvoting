# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OpenDataController do
    routes { Decidim::Core::Engine.routes }

    let!(:organization) { create(:organization) }
    let(:open_data_file_url) do
      Rails.application.routes.url_helpers.rails_blob_url(organization.open_data_files.first.blob, only_path: true)
    end

    before do
      request.env["decidim.current_organization"] = organization
      organization.open_data_files.delete_all
    end

    describe "GET download" do
      before do
        OpenDataJob.perform_now(organization) if generate_file
        get :download
      end

      context "when the open data file exists" do
        let(:generate_file) { true }

        it "redirects to download it" do
          expect(response.content_type).to eq("application/zip")
          expect(response).to have_http_status(:ok)
        end
      end

      context "when the open data file does not exist" do
        let(:generate_file) { false }

        it "redirects to the open data page" do
          expect(controller).to redirect_to(open_data_path)
        end

        it "warns the user" do
          expect(controller.flash.alert).to have_content("not yet available")
        end

        it "schedules a generation" do
          expect(Decidim::OpenDataJob).to have_been_enqueued.on_queue("exports")
        end
      end
    end
  end
end
