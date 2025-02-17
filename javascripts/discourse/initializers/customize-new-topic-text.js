import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "discourse-i18n";
import CustomPostReplyButton from "../components/custom-post-reply-button";
import { getFilteredSetting } from "../lib/setting-util";

export default {
  name: "customize-new-topic-text",
  before: "inject-objects",

  initialize() {
    withPluginApi("1.34.0", (api) => {
      api.customizeComposerText({
        actionTitle(model) {
          if (!model.topic) {
            const filteredSetting = getFilteredSetting(
              model,
              settings.custom_new_topic_text
            );
            return filteredSetting?.composer_action_text;
          }
        },

        saveLabel(model) {
          const currentLocale = I18n.currentLocale();
          const topicKey = I18n.translations[currentLocale].js.topic;

          const filteredSetting = getFilteredSetting(
            model,
            settings.custom_new_topic_text
          );

          if (!model.topic) {
            // New topic
            if (filteredSetting?.composer_button_text) {
              topicKey.custom_composer_save_label =
                filteredSetting.composer_button_text;
              return "topic.custom_composer_save_label";
            }
          } else {
            // Reply
            if (filteredSetting?.reply_button_text) {
              topicKey.custom_reply_label = filteredSetting.reply_button_text;
              return "topic.custom_reply_label";
            }
          }
        },
      });

      api.registerValueTransformer(
        "post-menu-buttons",
        ({ value: dag, context: { buttonKeys } }) => {
          dag.replace(buttonKeys.REPLY, CustomPostReplyButton);
        }
      );
    });
  },
};
