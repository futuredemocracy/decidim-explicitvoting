# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateComponentPermissions do
    subject(:command) { described_class.call(form, component, resource) }

    let(:organization) { create(:organization, available_authorizations: ["another_dummy_authorization_handler"]) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:user) { create(:user, organization:) }

    let(:component) do
      create(
        :component,
        participatory_space: participatory_process,
        permissions: {
          "create" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "thelma" => "louise" }
              }
            }
          },
          "vote" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "thelma" => "louise" }
              }
            }
          }
        }
      )
    end

    let(:resource) { nil }

    let(:manifest) { component.manifest }

    let(:form) do
      double(
        valid?: valid,
        permissions: {
          "create" => double(
            authorization_handlers: {
              another_dummy_authorization_handler: { options: { "perry" => "mason" } }
            },
            authorization_handlers_names: ["another_dummy_authorization_handler"],
            authorization_handlers_options: { "another_dummy_authorization_handler" => { "perry" => "mason" } }
          )
        },
        current_user: user
      )
    end

    let(:expected_permissions) do
      {
        "create" => {
          "authorization_handlers" => {
            "another_dummy_authorization_handler" => {
              "options" => { "perry" => "mason" }
            }
          }
        }
      }
    end

    let(:valid) { true }

    it "broadcasts :ok" do
      expect { subject }.to broadcast(:ok)
    end

    it "updates the component permissions" do
      expect { subject }.to change(component, :permissions).to(expected_permissions)
    end

    it "fires the hooks" do
      results = {}

      manifest.on(:permission_update) do |context|
        results = context.dup
      end

      subject

      component = results[:component]

      expect(component.permissions).to eq(expected_permissions)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("update_permissions", Decidim::Component, user)
        .and_call_original

      expect { subject }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.action).to eq("update_permissions")
      expect(action_log.version).to be_present
    end

    context "when receives a resource" do
      let(:resource) { create(:dummy_resource, component:) }
      let(:expected_permissions) { component.permissions.merge(changing_permissions) }
      let(:changing_permissions) do
        {
          "create" => {
            "authorization_handlers" => {
              "another_dummy_authorization_handler" => {
                "options" => { "perry" => "mason" }
              }
            }
          }
        }
      end

      it "broadcasts :ok" do
        expect { subject }.to broadcast(:ok)
      end

      it "does not update the component permissions" do
        expect { subject }.not_to change(component, :permissions)
      end

      it "updates the resource permissions, but only with the actions that change from components" do
        expect { subject }.to change(resource, :permissions).to(changing_permissions)
      end
    end

    context "with ephemeral authorizations" do
      subject(:command) { described_class.call(ephemeral_form, component, resource) }
      let(:organization) { create(:organization, available_authorizations: %w(ephemeral_dummy_authorization_handler another_dummy_authorization_handler)) }
      let(:other_organization) { create(:organization, available_authorizations: %w(ephemeral_dummy_authorization_handler another_dummy_authorization_handler)) }
      let(:ephemeral_form) do
        double(
          valid?: valid,
          permissions: {
            "create" => double(
              authorization_handlers: {
                ephemeral_dummy_authorization_handler: { options: { "perry" => "mason" } }
              },
              authorization_handlers_names: ["ephemeral_dummy_authorization_handler"],
              authorization_handlers_options: { "ephemeral_dummy_authorization_handler" => { "perry" => "mason" } }
            )
          },
          current_user: user
        )
      end
      let(:expected_permissions) do
        {
          "create" => {
            "authorization_handlers" => {
              "ephemeral_dummy_authorization_handler" => {
                "options" => { "perry" => "mason" }
              }
            }
          }
        }
      end
      let(:ephemeral_user) { create(:user, :ephemeral, organization:) }
      let(:other_organization_ephemeral_user) { create(:user, :ephemeral, organization: other_organization) }
      let!(:regular_authorization) { create(:authorization, :granted, name: "another_dummy_authorization_handler", user:) }
      let!(:ephemeral_authorization) { create(:authorization, :granted, name: "ephemeral_dummy_authorization_handler", user: ephemeral_user) }
      let!(:other_organization_ephemeral_authorization) { create(:authorization, :granted, name: "ephemeral_dummy_authorization_handler", user: other_organization_ephemeral_user) }

      let(:valid) { true }

      it "broadcasts :ok" do
        expect { subject }.to broadcast(:ok)
      end

      it "updates the component permissions" do
        expect { subject }.to change(component, :permissions).to(expected_permissions)
      end

      it "removes all the ephemeral authorizations of the type" do
        expect { subject }.to change(Decidim::Authorization, :count).by(-1)
        expect(Decidim::Authorization.where(id: ephemeral_authorization.id)).not_to exist
        expect(Decidim::Authorization.where(id: regular_authorization.id)).to exist
        expect(Decidim::Authorization.where(id: other_organization_ephemeral_authorization.id)).to exist
      end

      context "when receives a resource" do
        let(:resource) { create(:dummy_resource, component:) }
        let(:expected_permissions) { component.permissions.merge(changing_permissions) }
        let(:changing_permissions) do
          {
            "create" => {
              "authorization_handlers" => {
                "ephemeral_dummy_authorization_handler" => {
                  "options" => { "perry" => "mason" }
                }
              }
            }
          }
        end

        it "broadcasts :ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "does not update the component permissions" do
          expect { subject }.not_to change(component, :permissions)
        end

        it "updates the resource permissions, but only with the actions that change from components" do
          expect { subject }.to change(resource, :permissions).to(changing_permissions)
        end

        it "removes all the ephemeral authorizations of the type" do
          expect { subject }.to change(Decidim::Authorization, :count).by(-1)
          expect(Decidim::Authorization.where(id: ephemeral_authorization.id)).not_to exist
          expect(Decidim::Authorization.where(id: regular_authorization.id)).to exist
          expect(Decidim::Authorization.where(id: other_organization_ephemeral_authorization.id)).to exist
        end
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "does not update the permissions" do
        expect { subject }.to broadcast(:invalid)

        component.reload
        expect(component.permissions).not_to eq(expected_permissions)
      end
    end
  end
end
