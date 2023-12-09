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

  let tags = [];

  // If args.tag is an object
  if (args.tag?.id) {
    tags.push(formatFilter(args.tag.id));
  }

  // If args.tags is a string
  if (typeof args.tags === "string") {
    tags.push(formatFilter(args.tags));
  }

  // If args.tags is an array
  else if (Array.isArray(args.tags)) {
    tags = tags.concat(args.tags.map((tag) => formatFilter(tag)));
  }

  // If args.topic.tags is present
  if (Array.isArray(args.topic?.tags)) {
    tags = tags.concat(args.topic.tags.map((tag) => formatFilter(tag)));
  }

  for (let tag of tags) {
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

  // Use category settings if no tag setting is found
  if (!filteredSetting) {
    filteredSetting = settingFilter(
      categoryID,
      categoryParentID,
      null,
      parsedSetting
    );
  }

  return filteredSetting;
}
