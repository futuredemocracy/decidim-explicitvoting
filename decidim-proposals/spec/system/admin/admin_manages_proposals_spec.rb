# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage settings"
  it_behaves_like "manage taxonomy filters in settings"
  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  it_behaves_like "export proposals"
  it_behaves_like "manage announcements"
  it_behaves_like "manage proposals help texts"
  it_behaves_like "when managing proposals taxonomies as an admin"
  it_behaves_like "import proposals"
  it_behaves_like "manage proposals permissions"
  it_behaves_like "merge proposals"
  it_behaves_like "split proposals"
  it_behaves_like "publish answers"

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:proposal, 27, component: current_component) }
  end
end
