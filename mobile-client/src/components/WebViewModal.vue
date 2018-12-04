<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title selectable>{{title}}</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <nb-spinner v-if="loading" />

    <view :style="{marginTop: 22, flex: 1}">
      <web-view v-if="uri" :source="{uri: uri}" :style="{height: viewHeight, width: viewWidth}" :onLoad="onLoad" />
    </view>
  </modal>
</template>

<script>
import { Dimensions, WebView, Modal } from "react-native";
const deviceWidth = Dimensions.get("window").width;
const deviceHeight = Dimensions.get("window").height;

export default {
  name:'web-view-modal',
  components: {
    WebView,
    Modal
  },
  data: function() {
    return {
      viewWidth: deviceWidth,
      viewHeight: deviceHeight - 41,
      loading: true
    }
  },
  props: {
    webView: {
      type: Object
    },
    closeWebView: {
      type: Function
    }
  },
  computed: {
    opened () {
      return this.webView.opened
    },
    uri () {
      return this.webView.uri
    },
    title () {
      return this.webView.title
    }
  },
  methods: {
    close () {
      this.closeWebView()
    },
    onLoad () {
      this.loading = false
    }
  }
}
</script>

 
<style>

</style>
