const formatFilter = (filter) =>
  filter?.toLowerCase().trim().replace(/\s+/g, "-");

// TODO(https://github.com/discourse/discourse/pull/36678): The string check can be
// removed using .discourse-compatibility once the PR is merged.
export function getTagName(tag) {
  return typeof tag === "string" ? tag : tag.name;
}

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

  // If args.tag is present (string or object)
  if (args.tag) {
    tags.push(formatFilter(getTagName(args.tag)));
  }

  // If args.tags is a string (composer with one tag)
  if (typeof args.tags === "string") {
    tags.push(formatFilter(args.tags));
  }

  // If args.tags is an array (composer with multiple tags)
  else if (Array.isArray(args.tags)) {
    tags = tags.concat(args.tags.map((tag) => formatFilter(getTagName(tag))));
  }

  // If args.topic.tags is present
  if (Array.isArray(args.topic?.tags)) {
    tags = tags.concat(
      args.topic.tags.map((tag) => formatFilter(getTagName(tag)))
    );
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
