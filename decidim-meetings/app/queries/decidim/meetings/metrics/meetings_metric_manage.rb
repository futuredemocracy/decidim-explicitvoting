# frozen_string_literal: true

module Decidim
  module Meetings
    module Metrics
      class MeetingsMetricManage < Decidim::MetricManage
        def metric_name
          "meetings"
        end

        def save
          cumulative.each do |key, cumulative_value|
            next if cumulative_value.zero?

            quantity_value = quantity[key] || 0
            taxonomy_id, space_type, space_id = key
            record = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                           organization: @organization, decidim_taxonomy_id: taxonomy_id,
                                                           participatory_space_type: space_type, participatory_space_id: space_id)
            record.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            record.save!
          end
        end

        private

        def query
          return @query if @query

          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(@organization).public_spaces
          end
          @query = Decidim::Meetings::Meeting.where(component: visible_components_from_spaces(spaces)).joins(:component)
                                             .left_outer_joins(:taxonomizations).visible
          @query = @query.where(decidim_meetings_meetings: { created_at: ..end_time })
          @query = @query.group("decidim_taxonomizations.taxonomy_id",
                                :participatory_space_type,
                                :participatory_space_id)
          @query
        end

        def quantity
          @quantity ||= query.where(decidim_meetings_meetings: { created_at: start_time.. }).count
        end
      end
    end
  end
end
