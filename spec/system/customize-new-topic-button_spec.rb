# frozen_string_literal: true
RSpec.describe "Customize New Topic Text - new topic button", system: true do
  let!(:theme) { upload_theme_component }

  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  before { sign_in(user) }

  shared_examples "custom new topic button" do |type, custom_text|
    fab!(:category)
    fab!(:category2) { Fabricate(:category) }
    fab!(:tag)
    fab!(:tag2) { Fabricate(:tag) }

    before do
      setting_type = type == "category" ? category.id : tag.name
      theme.update_setting(
        :custom_new_topic_text,
        "[{\"filter\":\"#{setting_type}\",\"button_text\":\"#{custom_text}\",\"icon\":\"question\"}]",
      )
      theme.save!
    end

    it "the new topic button has custom text" do
      visit_url_based_on_type(type, 1)
      expect(find("#custom-create-topic")).to have_content(custom_text)
    end

    it "the new topic button has a custom icon" do
      visit_url_based_on_type(type, 1)
      expect(find("#custom-create-topic")).to have_css(".d-icon-question")
    end

    it "the new topic button in a different #{type} is not custom" do
      visit_url_based_on_type(type, 2)
      expect(find("#create-topic .d-button-label")).to have_content("New Topic")
    end

    def visit_url_based_on_type(type, id)
      if type == "category"
        category_to_visit = id == 1 ? category : category2
        visit("/c/#{category_to_visit.id}")
      else
        tag_to_visit = id == 1 ? tag : tag2
        visit("/tag/#{tag_to_visit.name}")
      end
    end
  end

  describe "When customizing the new topic button for a category" do
    include_examples "custom new topic button", "category", "Bawk!"
  end

  describe "When customizing the new topic button for a tag" do
    include_examples "custom new topic button", "tag", "Sqwauk!"
  end
end
