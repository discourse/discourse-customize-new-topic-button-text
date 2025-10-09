# frozen_string_literal: true
RSpec.describe "Customize New Topic Text - reply button", system: true do
  let!(:theme) { upload_theme_component }

  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }

  before { sign_in(user) }

  shared_examples "custom reply button" do |type, custom_text|
    fab!(:category)
    fab!(:tag)
    fab!(:topic) do
      Fabricate(:topic, type == "category" ? { category: category } : { tags: [tag] })
    end
    fab!(:post) { Fabricate(:post, topic: topic) }

    fab!(:topic2, :topic)
    fab!(:post2) { Fabricate(:post, topic: topic2) }

    before do
      setting_type = type == "category" ? category.id : tag.name
      theme.update_setting(
        :custom_new_topic_text,
        "[{\"filter\":\"#{setting_type}\",\"reply_button_text\":\"#{custom_text}\"}]",
      )
      theme.save!
    end

    it "the reply button on posts has custom text" do
      visit("/t/-/#{topic.id}")
      expect(find(".post-controls .actions .reply")).to have_content(custom_text)
    end

    it "the reply button on posts in a different #{type} is not custom" do
      visit("/t/-/#{topic2.id}")
      expect(find(".post-controls .actions")).to have_no_css(".custom-reply-button")
      expect(find(".post-controls .actions .reply")).to have_no_content(custom_text)
    end

    it "the reply button in the footer has custom text" do
      visit("/t/-/#{topic.id}")
      expect(find(".topic-footer-main-buttons")).to have_css(".custom-create")
    end

    it "the reply button in the footer for a different #{type} is not custom" do
      visit("/t/-/#{topic2.id}")
      expect(find(".topic-footer-main-buttons")).not_to have_css(".custom-create")
    end

    it "the reply button in the composer has custom text" do
      visit("/t/-/#{topic.id}")
      find(".custom-create").click
      expect(find(".save-or-cancel .create")).to have_content(custom_text)
    end

    it "the reply button in the composer for a different #{type} is not custom" do
      visit("/t/-/#{topic2.id}")
      find(".topic-footer-main-buttons .create").click
      expect(find(".save-or-cancel .create")).to have_content("Reply")
    end
  end

  describe "When customizing the reply button for a category" do
    include_examples "custom reply button", "category", "Bawk!"
  end

  describe "When customizing reply button for a tag" do
    include_examples "custom reply button", "tag", "Sqwauk!"
  end
end
