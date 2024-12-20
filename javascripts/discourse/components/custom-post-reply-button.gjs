import DButton from "discourse/components/d-button";
import PostMenuReplyButton from "discourse/components/post/menu/buttons/reply";
import concatClass from "discourse/helpers/concat-class";
import { i18n } from "discourse-i18n";
import { getFilteredSetting } from "../lib/setting-util";

export default class CustomPostReplyButton extends PostMenuReplyButton {
  get filteredSetting() {
    return getFilteredSetting(this.args.post, settings.custom_new_topic_text);
  }

  get customReplyLabel() {
    return this.filteredSetting?.reply_button_text;
  }

  get label() {
    return this.customReplyLabel || i18n("topic.reply.title");
  }

  <template>
    <DButton
      class={{concatClass
        "post-action-menu__reply"
        "reply"
        (if this.showLabel "create fade-out")
        (if this.customReplyLabel "custom-reply-button")
      }}
      ...attributes
      @action={{@buttonActions.replyToPost}}
      @icon="reply"
      @translatedLabel={{if this.showLabel this.label}}
      @title="post.controls.reply"
      @translatedAriaLabel={{i18n
        "post.sr_reply_to"
        post_number=@post.post_number
        username=@post.username
      }}
    />
  </template>
}
