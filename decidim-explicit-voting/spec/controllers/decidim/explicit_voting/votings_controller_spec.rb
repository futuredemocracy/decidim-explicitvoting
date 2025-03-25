# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    describe VotingsController, type: :controller do
      routes { Decidim::ExplicitVoting::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:component) { create(:explicit_voting_component, participatory_space: participatory_process) }
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_component"] = component
        request.env["decidim.current_participatory_space"] = participatory_process
        sign_in user
      end

      describe "GET index" do
        let!(:votings) { create_list(:voting, 3, component: component) }

        it "renders the index template" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
        end

        it "assigns votings" do
          get :index
          expect(assigns(:votings)).to match_array(votings)
        end
      end

      describe "GET show" do
        let(:voting) { create(:voting, component: component) }
        let!(:voting_options) { create_list(:voting_option, 3, voting: voting) }

        it "renders the show template" do
          get :show, params: { id: voting.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:show)
        end

        it "assigns voting and voting_options" do
          get :show, params: { id: voting.id }
          expect(assigns(:voting)).to eq(voting)
          expect(assigns(:voting_options)).to match_array(voting_options)
        end

        context "when voting is secret and not finished" do
          let(:voting) { create(:voting, :secret, component: component) }

          it "hides votes count" do
            get :show, params: { id: voting.id }
            expect(assigns(:voting).votes.count).to eq(0)
          end
        end
      end
    end
  end
end 