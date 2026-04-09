import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DTooltip from "discourse/float-kit/components/d-tooltip";
import Composer from "discourse/models/composer";
import { and, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { getFilteredSetting, getTagName } from "../lib/setting-util";
import TopicDraftsDropdown from "discourse/components/topic-drafts-dropdown"; // <-- Import core component!

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
    return this.filteredSetting?.button_text;
  }

  get customCreateTopicIcon() {
    return this.filteredSetting?.icon;
  }

  get hasDrafts() {
    return this.currentUser?.has_topic_draft;
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
        
        <TopicDraftsDropdown
          @action={{this.customCreateTopic}}
          @label={{this.customCreateTopicLabel}}
          @showDrafts={{this.hasDrafts}}
          @btnId="custom-create-topic"
          @btnClasses="btn-primary"
          @btnTypeClass="btn-primary"
          @disabled={{@createTopicDisabled}}
        />

        {{#if @createTopicDisabled}}
          <DTooltip @bindTo="#custom-create-topic">
            {{i18n "topic.create_disabled_category"}}
          </DTooltip>
        {{/if}}

      {{/if}}
    {{/if}}
  </template>
}
