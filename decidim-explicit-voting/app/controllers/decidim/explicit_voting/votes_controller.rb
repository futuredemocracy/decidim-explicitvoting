# frozen_string_literal: true

module Decidim
  module ExplicitVoting
    class VotesController < Decidim::ApplicationController
      before_action :authenticate_user!
      before_action :set_votable

      def create
        @vote = Vote.new(vote_params)
        @vote.author = current_user
        @vote.organization = current_organization

        if @vote.save
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".error")
        end

        redirect_back(fallback_location: root_path)
      end

      def destroy
        @vote = Vote.find_by(votable: @votable, author: current_user)
        
        if @vote&.destroy
          flash[:notice] = t(".success")
        else
          flash[:alert] = t(".error")
        end

        redirect_back(fallback_location: root_path)
      end

      private

      def set_votable
        @votable = GlobalID::Locator.locate(params[:votable_gid])
      end

      def vote_params
        params.require(:vote).permit(:vote_type)
      end
    end
  end
end 