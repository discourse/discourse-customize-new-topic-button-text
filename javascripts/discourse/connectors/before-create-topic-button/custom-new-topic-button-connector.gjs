import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import CustomNewTopicButton from "../../components/custom-new-topic-button";

@tagName("")
export default class CustomNewTopicButtonConnector extends Component {
  <template>
    <CustomNewTopicButton
      @category={{@outletArgs.category}}
      @tag={{@outletArgs.tag}}
      @createTopicLabel={{@outletArgs.createTopicLabel}}
      @createTopicDisabled={{@outletArgs.createTopicDisabled}}
      @canCreateTopic={{@outletArgs.canCreateTopic}}
    />
  </template>
}
