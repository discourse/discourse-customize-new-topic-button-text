// Here we change the composer action and button text based on the category and tag using the API
import { apiInitializer } from "discourse/lib/api";
import Category from "discourse/models/category";
import I18n from "I18n";

const parsedSetting = JSON.parse(settings.custom_new_topic_text);

const formatFilter = (filter) =>
  filter?.toLowerCase().trim().replace(/\s+/g, "-");

export default apiInitializer("0.11.1", (api) => {
  const getFilteredSetting = (model) => {
    const category = Category.findById(model._categoryId);
    const categoryID = category?.id;
    const categoryParentID = category?.parentCategory?.id;
    // not compatible with multiple tags
    // so just use the first one
    const firstTag =
      Array.isArray(model.tags) && model.tags.length > 0
        ? model.tags[0]
        : model.tags;

    let filteredSetting;

    // precedence: tag > category > parent category

    if (firstTag) {
      filteredSetting = parsedSetting.find(
        (entry) => firstTag && formatFilter(entry.filter) === firstTag
      );
    }

    if (!filteredSetting && categoryID) {
      filteredSetting = parsedSetting.find(
        (entry) => categoryID && parseInt(entry.filter, 10) === categoryID
      );
    }

    if (settings.inherit_parent_category) {
      if (!filteredSetting && categoryParentID) {
        filteredSetting = parsedSetting.find(
          (entry) =>
            categoryParentID && parseInt(entry.filter, 10) === categoryParentID
        );
      }
    }

    return filteredSetting;
  };

  api.customizeComposerText({
    actionTitle(model) {
      // if the topic is present, it's a reply
      if (!model.topic) {
        return getFilteredSetting(model)?.composer_action_text;
      }
    },

    saveLabel(model) {
      if (!model.topic) {
        const filteredSettingText =
          getFilteredSetting(model)?.composer_button_text;
        if (filteredSettingText) {
          const currentLocale = I18n.currentLocale();

            // a translation key is expected, so creating a temporary one here
            I18n.translations[currentLocale].js.topic.custom_composer_save_label =
              filteredSettingText;

            return "topic.custom_composer_save_label";
          }
      } else {
        // Reply button
        const filteredSettingText =
          getFilteredSetting(model)?.reply_button_text;
        if (filteredSettingText) {
          const currentLocale = I18n.currentLocale();
          // a translation key is expected, so creating a temporary one here
          I18n.translations[currentLocale].js.topic.custom_reply_label =
            filteredSettingText;

          return "topic.custom_reply_label";
        }
      }
    },
  });
});
