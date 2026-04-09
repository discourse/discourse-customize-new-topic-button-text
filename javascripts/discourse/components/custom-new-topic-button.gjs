import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DTooltip from "discourse/float-kit/components/d-tooltip";
import Composer from "discourse/models/composer";
import { and, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import I18n from "discourse-i18n"; // Import global I18n to register keys
import { getFilteredSetting, getTagName } from "../lib/setting-util";
import TopicDraftsDropdown from "discourse/components/topic-drafts-dropdown";

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
    const text = this.filteredSetting?.button_text;
    
    if (text) {
      // Trick the i18n system!
      // Dynamically register your custom text as a valid translation key.
      const customKey = "custom_topic_button_text";
      I18n.translations[I18n.currentLocale()].js[customKey] = text;
      
      // Return the new valid key!
      return customKey;
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
