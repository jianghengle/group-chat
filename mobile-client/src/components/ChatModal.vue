<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title>New Message</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <nb-content padder>
      <nb-text>chat modal</nb-text>
      <nb-button primary :onPress="openNewPhoto">
          <nb-text>new photo</nb-text>
        </nb-button>
        <nb-button primary :onPress="openAlbum">
          <nb-text>Album</nb-text>
        </nb-button>
    </nb-content>

    <photo-modal :newPhoto="newPhoto" :closeNewPhoto="closeNewPhoto"></photo-modal>

    <album-modal :album="album" :closeAlbum="closeAlbum"></album-modal>
  </modal>
</template>

<script>
import { Dimensions, Modal } from "react-native";
import PhotoModal from './PhotoModal'
import AlbumModal from './AlbumModal'

const deviceWidth = Dimensions.get("window").width;
const deviceHeight = Dimensions.get("window").height;

export default {
  name:'chat-modal',
  components: {
    Modal,
    PhotoModal,
    AlbumModal
  },
  data: function() {
    return {
      newPhoto: {
        opened: false
      },
      album: {
        opened: false
      }
    }
  },
  props: {
    newChat: {
      type: Object
    },
    closeNewChat: {
      type: Function
    }
  },
  computed: {
    opened () {
      return this.newChat.opened
    },
  },
  methods: {
    close () {
      this.closeNewChat()
    },
    closeNewPhoto () {
      this.newPhoto.opened = false
    },
    openNewPhoto () {
      this.newPhoto.opened = true
    },
    closeAlbum () {
      this.album.opened = false
    },
    openAlbum () {
      this.album.opened = true
    },
  }
}
</script>

 
<style>

</style>
