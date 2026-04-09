import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DComboButton from "discourse/components/d-combo-button";
import DropdownSelectBox from "discourse/components/dropdown-select-box";
import DropdownSelectBoxRow from "discourse/components/dropdown-select-box/row";
import DTooltip from "discourse/float-kit/components/d-tooltip";
import Composer from "discourse/models/composer";
import { and, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { getFilteredSetting, getTagName } from "../lib/setting-util";

export default class CustomNewTopicButton extends Component {
  @service currentUser;
  @service composer;
  @service router; // Needed for draft navigation

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
    // We no longer need to check for drafts here, because drafts 
    // are handled by the combo button's dropdown menu!
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

  @action
  openDraft() {
    this.router.transitionTo("user.activity.drafts", this.currentUser);
  }

  <template>
    {{#if (and this.filteredSetting (or @category @tag))}}
      {{#if @canCreateTopic}}
        
        {{!-- Use DComboButton instead of DButton --}}
        <DComboButton
          @class="btn-primary"
          @id="custom-create-topic-combo"
          @disabled={{@createTopicDisabled}}
        >
          <:button>
            <DButton
              @action={{this.customCreateTopic}}
              @icon={{this.customCreateTopicIcon}}
              @translatedLabel={{this.customCreateTopicLabel}}
              @disabled={{@createTopicDisabled}}
              id="custom-create-topic"
              class="btn-primary"
            />
          </:button>

          <:dropdown>
            {{!-- This renders the dropdown arrow and menu, but ONLY if they have drafts --}}
            {{#if this.hasDrafts}}
              <DropdownSelectBox
                @class="btn-primary d-combo-button-dropdown"
                @options={{hash icon="angle-down"}}
              >
                <DropdownSelectBoxRow
                  @action={{this.openDraft}}
                  @icon="far-pen-to-square"
                  @label="topic.open_draft"
                />
              </DropdownSelectBox>
            {{/if}}
          </:dropdown>

        </DComboButton>

        {{#if @createTopicDisabled}}
          <DTooltip @bindTo="#custom-create-topic-combo">
            {{i18n "topic.create_disabled_category"}}
          </DTooltip>
        {{/if}}

      {{/if}}
    {{/if}}
  </template>
}
