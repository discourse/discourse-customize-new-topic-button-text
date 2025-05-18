# frozen_string_literal: true

RSpec.describe "New Topic Submission from Tag URL", system: true do
  let!(:theme) { upload_theme_component }
  fab!(:admin)
  let!(:category) { Fabricate(:category, id: 79, slug: "aaa") }
  let!(:tag) { Fabricate(:tag, name: "new") }
  let!(:tag2) { Fabricate(:tag, name: "aaa") } # Needs two tags to trigger bug
  let(:composer) { PageObjects::Components::Composer.new }

  before { sign_in(admin) }

  before do
    custom_text = "asdf"
    theme.update_setting(
      :custom_new_topic_text,
      "[{\"filter\":\"#{category.id}\",\"icon\":\"plus\",\"button_text\":\"#{custom_text}\"}]",
    )
    theme.save!
  end

  # Testing for a regression fixed in 55d32e977f5595d6f7aa50abafe0e7de48735fe1
  it "submits a new topic from a tag URL and does not trigger a 500 error" do
    visit("/tags/c/#{category.slug}/#{category.id}/#{tag.name}")
    find("#custom-create-topic").click
    composer.fill_title("Test Topic Title - 1234567")
    composer.fill_content("This is a test topic body.")

    expect(page).to have_content("new")

    # Submit the topic
    find("button.create").click

    # Expect that topic creation does NOT create a 500 error
    # by checking for a successful topic being created.
    expect(page).to have_css(".fancy-title", text: "Test Topic Title - 1234567")
  end
end
