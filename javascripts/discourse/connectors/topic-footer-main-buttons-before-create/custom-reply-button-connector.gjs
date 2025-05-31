import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import CustomTopicReplyButton from "../../components/custom-topic-reply-button";

@tagName("span")
@classNames(
  "topic-footer-main-buttons-before-create-outlet",
  "custom-reply-button-connector"
)
export default class CustomReplyButtonConnector extends Component {
  <template><CustomTopicReplyButton @topic={{@outletArgs.topic}} /></template>
}
