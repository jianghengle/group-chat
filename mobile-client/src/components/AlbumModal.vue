<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title>Album</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <nb-content padder>
      <camera-roll-picker :assetType="'All'" :selectSingleItem="true" :callback="getSelectedImages" />
      
    </nb-content>

  </modal>
</template>

<script>
import { Modal } from "react-native";
import CameraRollPicker from 'react-native-camera-roll-picker';

export default {
  name:'album-modal',
  components: {
    Modal,
    CameraRollPicker
  },
  data: function() {
    return {
      
    }
  },
  props: {
    album: {
      type: Object
    },
    closeAlbum: {
      type: Function
    }
  },
  computed: {
    opened () {
      return this.album.opened
    },
  },
  methods: {
    close () {
      this.closeAlbum()
    },
    getSelectedImages (images, current) {
      this.closeAlbum(current)
    }
  }
}
</script>

 
<style>

</style>
