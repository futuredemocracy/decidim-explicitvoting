# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class VotingsController < Decidim::Admin::ApplicationController
        def index
          enforce_permission_to :read, :voting
          @votings = collection
        end

        def show
          enforce_permission_to :read, :voting, voting: resource
          @voting = resource
        end

        def new
          enforce_permission_to :create, :voting
          @voting = Decidim::ExplicitVoting::Voting.new
        end

        def create
          enforce_permission_to :create, :voting
          @voting = Decidim::ExplicitVoting::Voting.new(voting_params)
          @voting.component = current_component

          if @voting.save
            flash[:notice] = I18n.t("votings.create.success", scope: "decidim.explicit_voting.admin")
            redirect_to votings_path
          else
            flash.now[:alert] = I18n.t("votings.create.error", scope: "decidim.explicit_voting.admin")
            render :new
          end
        end

        def edit
          enforce_permission_to :update, :voting, voting: resource
          @voting = resource
        end

        def update
          enforce_permission_to :update, :voting, voting: resource
          @voting = resource
          if @voting.update(voting_params)
            flash[:notice] = I18n.t("votings.update.success", scope: "decidim.explicit_voting.admin")
            redirect_to votings_path
          else
            flash.now[:alert] = I18n.t("votings.update.error", scope: "decidim.explicit_voting.admin")
            render :edit
          end
        end

        def destroy
          enforce_permission_to :destroy, :voting, voting: resource
          @voting = resource
          if @voting.destroy
            flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.explicit_voting.admin")
          else
            flash[:alert] = I18n.t("votings.destroy.error", scope: "decidim.explicit_voting.admin")
          end
          redirect_to votings_path
        end

        def results
          enforce_permission_to :read, :voting, voting: resource
          @voting = resource
        end

        def protocol
          enforce_permission_to :read, :voting, voting: resource
          @voting = resource
        end

        private

        def collection
          @collection ||= Decidim::ExplicitVoting::Voting.where(component: current_component)
        end

        def resource
          @resource ||= collection.find(params[:id])
        end

        def voting_params
          params.require(:voting).permit(:title, :description, :start_date, :end_date, :secret)
        end
      end
    end
  end
end 