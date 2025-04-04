# frozen_string_literal: true

module Decidim
  # This model holds all the data needed to send a newsletter.
  class Newsletter < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :subject

    belongs_to :author, class_name: "User"
    belongs_to :organization

    validates :subject, presence: true
    validate :author_belongs_to_organization

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::NewsletterPresenter
    end

    # Returns true if this newsletter was already sent.
    #
    # Returns a Boolean.
    def sent?
      sent_at.present?
    end

    def sent_to_all_users?
      extended_data["send_to_all_users"]
    end

    def sent_to_verified_users?
      extended_data["send_to_verified_users"]
    end

    def sent_to_users_with_verification_types
      extended_data["verification_types"]
    end

    def sent_to_followers?
      extended_data["send_to_followers"]
    end

    def sent_to_participants?
      extended_data["send_to_participants"]
    end

    def sent_to_participatory_spaces
      extended_data["participatory_space_types"]
    end

    def sent_to_private_members?
      extended_data["send_to_private_members"]
    end

    def template
      @template ||= Decidim::ContentBlock
                    .for_scope(:newsletter_template, organization:)
                    .find_by(scoped_resource_id: id)
    end

    def url(**)
      proxy_url(:newsletter_url, id:, **)
    end

    def notifications_settings_url(**)
      proxy_url(__method__, **)
    end

    def unsubscribe_newsletters_url(**)
      proxy_url(__method__, **)
    end

    def organization_official_url
      return "#" unless sent?

      organization.official_url || proxy_url(:root_url)
    end

    private

    def author_belongs_to_organization
      return if !author || !organization

      errors.add(:author, :invalid) unless author.organization == organization
    end

    def proxy_url(method, **)
      return "#" unless sent?

      router.public_send(method, host: organization.host, **)
    end

    def router
      @router ||= EngineRouter.new("decidim", {})
    end
  end
end
