# frozen_string_literal: true
RSpec.describe "Customize New Topic Text - composer action text", system: true do
  let!(:theme) { upload_theme_component }

  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  before { sign_in(user) }

  shared_examples "custom composer text" do |type, custom_text|
    fab!(:category)
    fab!(:category2) { Fabricate(:category) }
    fab!(:tag)
    fab!(:tag2) { Fabricate(:tag) }

    before do
      setting_type = type == "category" ? category.id : tag.name
      theme.update_setting(
        :custom_new_topic_text,
        "[{\"filter\":\"#{setting_type}\",\"composer_action_text\":\"#{custom_text}\",\"composer_button_text\":\"#{custom_text}\"}]",
      )
      theme.save!
    end

    it "the composer action and button text is custom" do
      visit_url_based_on_type(type, 1)
      find("#create-topic").click

      expect(find(".action-title")).to have_content(custom_text)
      expect(find(".save-or-cancel .create")).to have_content(custom_text)
    end

    it "the composer action and button text in a different #{type} is not custom" do
      visit_url_based_on_type(type, 2)
      find("#create-topic").click

      expect(find(".action-title")).not_to have_content(custom_text)
      expect(find(".save-or-cancel .create")).not_to have_content(custom_text)
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

  describe "When customizing the composer text for a category" do
    include_examples "custom composer text", "category", "Bawk!"
  end

  describe "When customizing the composer text for a tag" do
    include_examples "custom composer text", "tag", "Sqwauk!"
  end
end
