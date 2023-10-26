// This component creates a new duplicate "Reply" button
// which avoids modifying the existing button/translations in core
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import Composer from "discourse/models/composer";
import I18n from "I18n";

const formatFilter = (filter) =>
  filter?.toLowerCase().trim().replace(/\s+/g, "-");

const settingFilter = (categoryID, categoryParentID, tagId, parsedSetting) => {
  let filteredSetting;

  // precedence: tag > category > parent category

  if (tagId) {
    filteredSetting = parsedSetting.find(
      (entry) => entry && formatFilter(entry.filter) === tagId
    );
  }

  if (!filteredSetting && categoryID) {
    filteredSetting = parsedSetting.find(
      (entry) => entry && parseInt(entry.filter, 10) === categoryID
    );
  }

  if (settings.inherit_parent_category) {
    if (!filteredSetting && categoryParentID) {
      filteredSetting = parsedSetting.find(
        (entry) => entry && parseInt(entry.filter) === categoryParentID
      );
    }
  }

  return filteredSetting;
};

export default class CustomReplyButton extends Component {
  @service router;
  @service currentUser;
  @service composer;

  get filteredSetting() {
    const parsedSetting = JSON.parse(settings.custom_new_topic_text);
    const category = this.args.topic.category;
    const categoryID = category?.id;
    const categoryParentID = category?.parentCategory?.id;
    const tagId = this.args.topic.tag?.id;

    return settingFilter(categoryID, categoryParentID, tagId, parsedSetting);
  }

  get customReplyLabel() {
    return this.filteredSetting?.reply_button_text || I18n.t("topic.reply.title");
  }

  @action
  customReply() {
    this.composer.open({
      action: Composer.REPLY,
      draftKey: this.args.topic.get("draft_key"),
      draftSequence: this.args.topic.get("draft_sequence"),
      topic: this.args.topic
    });
  }
}
