const formatFilter = (filter) =>
  filter?.toLowerCase().trim().replace(/\s+/g, "-");

const settingFilter = (
  categoryID,
  categoryParentID,
  tagId,
  parsedSetting,
  inheritParentCategory
) => {
  let filteredSetting;

  // precedence: tag > category > parent category
  if (tagId) {
    filteredSetting = parsedSetting.find(
      (entry) => entry && formatFilter(entry.filter) === tagId
    );
  }

  if (!filteredSetting && categoryID) {
    filteredSetting = parsedSetting.find(
      (entry) => entry && parseInt(entry.filter, 10) === categoryID
    );
  }

  if (inheritParentCategory) {
    if (!filteredSetting && categoryParentID) {
      filteredSetting = parsedSetting.find(
        (entry) => entry && parseInt(entry.filter, 10) === categoryParentID
      );
    }
  }

  return filteredSetting;
};

export function getFilteredSetting(args, settingsText) {
  const parsedSetting = JSON.parse(settingsText);
  const category = args.topic?.category || args.category;
  const categoryID = category?.id;
  const categoryParentID = category?.parentCategory?.id;
  let filteredSetting;

  if (args.topic && args.topic?.tags?.length > 0) {
    // within topics, use the fist matching tag we can find
    for (let tag of args.topic.tags) {
      filteredSetting = settingFilter(
        categoryID,
        categoryParentID,
        tag,
        parsedSetting
      );

      if (filteredSetting) {
        break;
      }
    }
  } else {
    filteredSetting = settingFilter(
      categoryID,
      categoryParentID,
      args.tag?.id,
      parsedSetting
    );
  }

  return filteredSetting;
}
