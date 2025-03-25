# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExplicitVoting
    describe VotesController, type: :controller do
      routes { Decidim::ExplicitVoting::Engine.routes }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let(:component) { create(:explicit_voting_component, participatory_space: participatory_process) }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:voting) { create(:voting, :active, component: component) }
      let(:voting_option) { create(:voting_option, voting: voting) }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_component"] = component
        request.env["decidim.current_participatory_space"] = participatory_process
        sign_in user
      end

      describe "POST create" do
        let(:params) do
          {
            voting_id: voting.id,
            vote: {
              voting_option_id: voting_option.id
            }
          }
        end

        context "when everything is ok" do
          it "creates a vote" do
            expect do
              post :create, params: params
            end.to change(Vote, :count).by(1)
          end

          it "redirects to voting path" do
            post :create, params: params
            expect(response).to redirect_to(voting_path(voting))
          end
        end

        context "when user has already voted" do
          before do
            create(:vote, voting: voting, user: user)
          end

          it "does not create a vote" do
            expect do
              post :create, params: params
            end.not_to change(Vote, :count)
          end

          it "redirects to voting path" do
            post :create, params: params
            expect(response).to redirect_to(voting_path(voting))
          end
        end

        context "when voting is not active" do
          let(:voting) { create(:voting, :upcoming, component: component) }

          it "does not create a vote" do
            expect do
              post :create, params: params
            end.not_to change(Vote, :count)
          end

          it "redirects to voting path" do
            post :create, params: params
            expect(response).to redirect_to(voting_path(voting))
          end
        end
      end
    end
  end
end 