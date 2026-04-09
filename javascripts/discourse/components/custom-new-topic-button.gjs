// This component creates a duplicate "New Topic" button with its own draft dropdown,
// fully replacing core's create-topic button (which is hidden via CSS)
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import DButton from "discourse/components/d-button";
import DComboButton from "discourse/components/d-combo-button";
import DropdownMenu from "discourse/components/dropdown-menu";
import DiscourseURL from "discourse/lib/url";
import Composer, {
  NEW_PRIVATE_MESSAGE_KEY,
  NEW_TOPIC_KEY,
} from "discourse/models/composer";
import { and, or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { getFilteredSetting, getTagName } from "../lib/setting-util";

const DRAFTS_LIMIT = 4;

export default class CustomNewTopicButton extends Component {
  @service currentUser;
  @service composer;
  @service appEvents;

  @tracked drafts = [];
  @tracked loading = false;
  @tracked draftCount = this.currentUser?.draft_count ?? 0;
  dMenu;

  trackDrafts = modifier(() => {
    const handler = () => {
      this.draftCount = this.currentUser?.draft_count ?? 0;
    };

    this.appEvents.on("user-drafts:changed", this, handler);

    return () => {
      this.appEvents.off("user-drafts:changed", this, handler);
    };
  });

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

  get showDrafts() {
    return this.draftCount > 0;
  }

  get otherDraftsCount() {
    return this.draftCount > DRAFTS_LIMIT ? this.draftCount - DRAFTS_LIMIT : 0;
  }

  get otherDraftsText() {
    return this.otherDraftsCount > 0
      ? i18n("drafts.dropdown.other_drafts", {
          count: this.otherDraftsCount,
        })
      : "";
  }

  get showViewAll() {
    return this.draftCount > DRAFTS_LIMIT;
  }

  draftIcon(item) {
    if (item.draft_key.startsWith(NEW_TOPIC_KEY)) {
      return "layer-group";
    } else if (item.draft_key.startsWith(NEW_PRIVATE_MESSAGE_KEY)) {
      return "envelope";
    } else {
      return "reply";
    }
  }

  @action
  onRegisterApi(api) {
    this.dMenu = api;
  }

  @action
  async onShowMenu() {
    if (this.loading) {
      return;
    }

    this.loading = true;

    try {
      const draftsStream = this.currentUser.userDraftsStream;
      draftsStream.reset();

      await draftsStream.findItems(this.site);
      this.drafts = draftsStream.content.slice(0, DRAFTS_LIMIT);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Failed to fetch drafts with error:", error);
    } finally {
      this.loading = false;
    }
  }

  @action
  async resumeDraft(draft) {
    await this.dMenu.close();

    if (draft.postUrl) {
      DiscourseURL.routeTo(draft.postUrl);
    } else {
      this.composer.open({
        draft,
        draftKey: draft.draft_key,
        draftSequence: draft.sequence,
        ...draft.data,
      });
    }
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
        <DComboButton
          {{this.trackDrafts}}
          class={{if this.showDrafts "--has-menu"}}
          aria-label={{i18n "topic.create_group"}}
          as |combo|
        >
          <combo.Button
            @action={{this.customCreateTopic}}
            @translatedLabel={{this.filteredSetting.button_text}}
            @icon={{or this.filteredSetting.icon "far-pen-to-square"}}
            @disabled={{@createTopicDisabled}}
            id="custom-create-topic"
            class="btn-default"
          />

          {{#if this.showDrafts}}
            <combo.Menu
              @identifier="topic-drafts-menu"
              @title={{i18n "drafts.dropdown.title"}}
              @onShow={{this.onShowMenu}}
              @onRegisterApi={{this.onRegisterApi}}
              @modalForMobile={{true}}
              aria-label={{i18n "drafts.dropdown.title"}}
              class="btn-default"
            >
              <DropdownMenu as |dropdown|>
                {{#each this.drafts as |draft|}}
                  <dropdown.item class="topic-drafts-item">
                    <DButton
                      @action={{fn this.resumeDraft draft}}
                      @icon={{this.draftIcon draft}}
                      @translatedLabel={{or
                        draft.title
                        (i18n "drafts.dropdown.untitled")
                      }}
                      class="btn-secondary"
                    />
                  </dropdown.item>
                {{/each}}

                {{#if this.showViewAll}}
                  <dropdown.divider />

                  <dropdown.item>
                    <DButton
                      @href="/my/activity/drafts"
                      @model={{this.currentUser}}
                      class="btn-link view-all-drafts"
                    >
                      <span
                        data-other-drafts={{this.otherDraftsCount}}
                      >{{this.otherDraftsText}}</span>
                      <span>{{i18n "drafts.dropdown.view_all"}}</span>
                    </DButton>
                  </dropdown.item>
                {{/if}}
              </DropdownMenu>
            </combo.Menu>
          {{/if}}
        </DComboButton>
      {{/if}}
    {{/if}}
  </template>
}
