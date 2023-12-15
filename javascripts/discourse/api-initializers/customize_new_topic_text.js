import { apiInitializer } from "discourse/lib/api";
import I18n from "I18n";
import { getFilteredSetting } from "../lib/setting-util";

export default apiInitializer("0.11.1", (api) => {
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

  api.addPostMenuButton("customReplyButton", (attrs) => {
    const currentRoute = api.container.lookup("service:router").currentRoute;
    const isTopic = currentRoute.name.includes("topic");

    if (!isTopic || !attrs.canCreatePost) {
      document.querySelector("body").classList.remove("custom-reply-button");
      return;
    }

    const topic = {
      topic: currentRoute.parent.attributes,
    };

    const filteredSetting = getFilteredSetting(
      topic,
      settings.custom_new_topic_text
    );

    if (filteredSetting?.reply_button_text) {
      document.querySelector("body").classList.add("custom-reply-button");
      return {
        action: "replyToPost",
        icon: "reply",
        className: "reply create custom-reply-button fade-out",
        title: "post.controls.reply",
        position: "last",
        translatedLabel: !attrs.mobileView
          ? filteredSetting.reply_button_text
          : "",
      };
    }
  });
});
