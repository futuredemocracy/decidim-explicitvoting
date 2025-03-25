# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    module Admin
      class VotingOptionsController < Decidim::Admin::ApplicationController
        def index
          @voting = voting
          @voting_options = voting.voting_options
        end

        def new
          @voting = voting
          @voting_option = Decidim::ExplicitVoting::VotingOption.new
        end

        def create
          @voting = voting
          @voting_option = Decidim::ExplicitVoting::VotingOption.new(voting_option_params)
          @voting_option.voting = @voting

          if @voting_option.save
            flash[:notice] = I18n.t("voting_options.create.success", scope: "decidim.explicit_voting.admin")
            redirect_to voting_voting_options_path(@voting)
          else
            flash.now[:alert] = I18n.t("voting_options.create.error", scope: "decidim.explicit_voting.admin")
            render :new
          end
        end

        def edit
          @voting = voting
          @voting_option = resource
        end

        def update
          @voting = voting
          @voting_option = resource
          if @voting_option.update(voting_option_params)
            flash[:notice] = I18n.t("voting_options.update.success", scope: "decidim.explicit_voting.admin")
            redirect_to voting_voting_options_path(@voting)
          else
            flash.now[:alert] = I18n.t("voting_options.update.error", scope: "decidim.explicit_voting.admin")
            render :edit
          end
        end

        def destroy
          @voting = voting
          @voting_option = resource
          if @voting_option.destroy
            flash[:notice] = I18n.t("voting_options.destroy.success", scope: "decidim.explicit_voting.admin")
          else
            flash[:alert] = I18n.t("voting_options.destroy.error", scope: "decidim.explicit_voting.admin")
          end
          redirect_to voting_voting_options_path(@voting)
        end

        def update_positions
          @voting = voting
          params[:positions].each do |id, position|
            @voting.voting_options.find(id).update(position: position)
          end
          head :ok
        end

        private

        def voting
          @voting ||= Decidim::ExplicitVoting::Voting.where(component: current_component).find(params[:voting_id])
        end

        def resource
          @resource ||= voting.voting_options.find(params[:id])
        end

        def voting_option_params
          params.require(:voting_option).permit(:name, :position)
        end
      end
    end
  end
end 