# frozen_string_literal: true

module Decidim
  module Meetings
    module Polls
      class AnswersController < Decidim::Meetings::ApplicationController
        include Decidim::Meetings::PollsResources
        include FormFactory

        helper_method :question

        def admin
          enforce_permission_to(:update, :poll, meeting:)
        end

        def index
          enforce_permission_to(:reply_poll, :meeting, meeting:)
        end

        def create
          enforce_permission_to(:create, :answer, question:)
          @form = form(AnswerForm).from_params(params.merge(question:, current_user:))

          CreateAnswer.call(@form, questionnaire) do
            # Both :ok and :invalid render the same template, because
            # validation errors are displayed in the template
            respond_to do |format|
              format.js
            end
          end
        end

        private

        def question
          @question ||= questionnaire.questions.find(answer_params[:question_id]) if questionnaire
        end

        def answer_params
          params.require(:answer).permit(:question_id, choices: [:body, :answer_option_id])
        end
      end
    end
  end
end
