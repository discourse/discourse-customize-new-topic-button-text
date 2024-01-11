import Category from "discourse/models/category";
import I18n from "I18n";
import { withPluginApi } from "discourse/lib/plugin-api";
const parsedSetting = JSON.parse(settings.custom_new_topic_text);

const formatFilter = (filter) =>
  filter?.toLowerCase().trim().replace(/\s+/g, "-");

export default {
  name: "customize-new-topic-text",
  before: "chat-setup",

  initialize() {
    withPluginApi("0.11.1", (api) => {
      const getFilteredSetting = (model) => {
        const category = Category.findById(model._categoryId);
        const categorySlug = category?.slug;
        const categoryParentSlug = category?.parentCategory?.slug;
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

        if (!filteredSetting && categorySlug) {
          filteredSetting = parsedSetting.find(
            (entry) =>
              categorySlug && formatFilter(entry.filter) === categorySlug
          );
        }

        if (settings.inherit_parent_category) {
          if (!filteredSetting && categoryParentSlug) {
            filteredSetting = parsedSetting.find(
              (entry) =>
                categoryParentSlug &&
                formatFilter(entry.filter) === categoryParentSlug
            );
          }
        }

        return filteredSetting;
      };

      api.customizeComposerText({
        actionTitle(model) {
          return getFilteredSetting(model)?.composer_action_text;
        },

        saveLabel(model) {
          const filteredSettingText =
            getFilteredSetting(model)?.composer_button_text;

          if (filteredSettingText) {
            const currentLocale = I18n.currentLocale();

            I18n.translations[
              currentLocale
            ].js.topic.custom_composer_save_label = filteredSettingText;

            return "topic.custom_composer_save_label";
          }
        },
      });
    });
  },
};
