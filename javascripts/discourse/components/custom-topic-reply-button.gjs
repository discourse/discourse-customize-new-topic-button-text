// This component creates a new duplicate "Reply" button
// which avoids modifying the existing button/translations in core
import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and } from "truth-helpers";
import DButton from "discourse/components/d-button";
import bodyClass from "discourse/helpers/body-class";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import { getFilteredSetting } from "../lib/setting-util";

export default class CustomTopicReplyButton extends Component {
  @service composer;

  get filteredSetting() {
    return getFilteredSetting(this.args, settings.custom_new_topic_text);
  }

  get customReplyLabel() {
    return this.filteredSetting?.reply_button_text || i18n("topic.reply.title");
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

  <template>
    {{#if
      (and
        @topic.details.can_create_post this.filteredSetting.reply_button_text
      )
    }}
      {{bodyClass "custom-reply-button"}}
      <DButton
        @icon="reply"
        @translatedLabel={{this.customReplyLabel}}
        @action={{this.customReply}}
        @title="topic.reply.help"
        class="btn-primary create custom-create"
      />
    {{/if}}
  </template>
}
