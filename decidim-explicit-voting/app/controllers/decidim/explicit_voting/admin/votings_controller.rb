# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class VotingsController < Decidim::ExplicitVoting::Admin::ApplicationController
        helper_method :votings, :resource

        def index
          enforce_permission_to :read, :voting
          @votings = collection.order(created_at: :desc)

          respond_to do |format|
            format.html
            format.pdf do
              pdf = generate_voting_list_pdf(@votings)
              send_data pdf.render,
                        filename: "lista_glosowan_#{Time.current.strftime('%Y%m%d')}.pdf",
                        type: "application/pdf",
                        disposition: "attachment"
            end
          end
        end

        def show
          enforce_permission_to :read, :voting, voting: resource
        end

        def new
          enforce_permission_to :create, :voting
          @form = form(VotingForm).instance
        end

        def create
          enforce_permission_to :create, :voting
          @form = form(VotingForm).from_params(params)

          CreateVoting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.create.error", scope: "decidim.explicit_voting.admin")
              render :new, status: :unprocessable_entity
            end
          end
        end

        def edit
          enforce_permission_to :update, :voting, voting: resource
          voting = resource

          @form = form(VotingForm).from_params(
            {
              title: voting.title.is_a?(Hash) ? voting.title : {},
              description: voting.description.is_a?(Hash) ? voting.description : {},
              start_date: voting.start_date,
              end_date: voting.end_date,
              secret: voting.secret
            }
          )
        end

        def update
          enforce_permission_to :update, :voting, voting: resource
          voting = resource
          @form = form(VotingForm).from_params(voting_params)

          if @form.valid?
            attributes = {
              title: @form.title || {},
              description: @form.description || {},
              start_date: @form.start_date,
              end_date: @form.end_date,
              secret: @form.secret
            }

            if voting.update(attributes)
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.explicit_voting.admin")
              redirect_to votings_path
            else
              flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
              render :edit, status: :unprocessable_entity
            end
          else
            flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
            render :edit, status: :unprocessable_entity
          end
        end

        def destroy
          enforce_permission_to :destroy, :voting, voting: resource
          voting = resource

          if voting.destroy
            flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.explicit_voting.admin")
          else
            flash[:alert] = I18n.t("votings.destroy.error", scope: "decidim.explicit_voting.admin", error: voting.errors.full_messages.join(", "))
          end
          redirect_to votings_path, status: :see_other
        end

        def results
          enforce_permission_to :read, :voting, voting: resource
        end

        def protocol
          enforce_permission_to :read, :voting, voting: resource
          voting = resource

          respond_to do |format|
            format.pdf do
              pdf_generator = Decidim::ExplicitVoting::GenerateProtocolPdf.new(voting)
              pdf = pdf_generator.call
              send_data pdf.render,
                        filename: "protokol_glosowania_#{voting.id}.pdf",
                        type: "application/pdf",
                        disposition: "attachment"
            end

            format.html do
              redirect_to votings_path, alert: I18n.t("votings.protocol.no_html_format", scope: "decidim.explicit_voting.admin")
            end
          end
        end

        private

        def votings
          @votings ||= collection.order(created_at: :desc)
        end

        def voting_params
          params.require(:voting).permit(
            :start_date, :end_date, :secret,
            title: current_organization.available_locales,
            description: current_organization.available_locales
          )
        end

        def collection
          @collection ||= Decidim::ExplicitVoting::Voting.where(component: current_component)
        end

        def resource
          @resource ||= collection.find(params[:id])
        end
      end
    end
  end
end
