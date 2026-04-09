import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DTooltip from "discourse/float-kit/components/d-tooltip";
import Composer from "discourse/models/composer";
import { and, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { getFilteredSetting, getTagName } from "../lib/setting-util";

export default class CustomNewTopicButton extends Component {
  @service currentUser;
  @service composer;

  get filteredSetting() {
    const setting = getFilteredSetting(
      this.args,
      settings.custom_new_topic_text
    );

    if (!setting?.button_text) {
      return;
    }

    return setting;
  }

  get customCreateTopicLabel() {
    if (this.currentUser.has_topic_draft) {
      return i18n("topic.open_draft");
    } else {
      return this.filteredSetting?.button_text;
    }
  }

  get customCreateTopicIcon() {
    return this.filteredSetting?.icon;
  }

  @action
  customCreateTopic() {
    this.composer.open({
      action: Composer.CREATE_TOPIC,
      draftKey: Composer.NEW_TOPIC_KEY,
      categoryId: this.args.category?.id,
      tags: Array.isArray(this.args.tag)
        ? this.args.tag.map((tag) => getTagName(tag))
        : this.args.tag
          ? [getTagName(this.args.tag)]
          : [],
    });
  }
  <template>
    {{#if (and this.filteredSetting (or @category @tag))}}
      {{#if @canCreateTopic}}
        <DButton
          @action={{this.customCreateTopic}}
          @icon={{this.customCreateTopicIcon}}
          @translatedLabel={{this.customCreateTopicLabel}}
          @disabled={{@createTopicDisabled}}
          id="custom-create-topic"
          class="btn-primary btn-icon-text"
        >
          {{#if @createTopicDisabled}}
            <DTooltip>{{i18n "topic.create_disabled_category"}}</DTooltip>
          {{/if}}
        </DButton>
      {{/if}}
    {{/if}}
  </template>
}
