// This component creates a new duplicate "Reply" button
// which avoids modifying the existing button/translations in core
import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import Composer from "discourse/models/composer";
import I18n from "I18n";
import { getFilteredSetting } from "../lib/setting-util";

export default class CustomReplyButton extends Component {
  @service router;
  @service currentUser;
  @service composer;

  get filteredSetting() {
    return getFilteredSetting(this.args, settings.custom_new_topic_text);
  }

  get customReplyLabel() {
    return (
      this.filteredSetting?.reply_button_text || I18n.t("topic.reply.title")
    );
  }

  @action
  customReply() {
    this.composer.open({
      action: Composer.REPLY,
      draftKey: this.args.topic.get("draft_key"),
      draftSequence: this.args.topic.get("draft_sequence"),
      topic: this.args.topic,
    });
  }
}
