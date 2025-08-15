// This component creates a new duplicate "New Topic" button
// which avoids modifying the existing button/translations in core
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { and, or } from "truth-helpers";
import DButton from "discourse/components/d-button";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";
import DTooltip from "float-kit/components/d-tooltip";
import { getFilteredSetting } from "../lib/setting-util";

export default class CustomNewTopicButton extends Component {
  @service router;
  @service currentUser;
  @service composer;

  @tracked hasDraft = this.currentUser.has_topic_draft;

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
    if (this.hasDraft) {
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
        ? this.args.tag.map((tag) => tag.id)
        : this.args.tag
          ? [this.args.tag.id]
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
          class="btn-default"
        >
          {{#if @createTopicDisabled}}
            <DTooltip>{{i18n "topic.create_disabled_category"}}</DTooltip>
          {{/if}}
        </DButton>
      {{/if}}
    {{/if}}
  </template>
}
