<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title :style="{width: 200}">New Message</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <nb-content padder>
      <view>
        <nb-label :style="{fontWeight: '700'}">Message</nb-label>
        <nb-textarea :rowSpan="5" bordered v-model="message" placeholder="Type here" />
      </view>

      <view :style="{flex: 1,flexDirection: 'row', justifyContent: 'space-between', marginBottom: 5, marginTop: 5}">
        <nb-label :style="{fontWeight: '700', paddingTop: 12}">Attachment</nb-label>
        <nb-button transparent :onPress="openAlbum">
          <nb-icon :style="{fontSize: 34}" name="photos" />
        </nb-button>
        <nb-button transparent :onPress="openNewPhoto">
          <nb-icon :style="{fontSize: 34}" name="camera" />
        </nb-button>
        <nb-button transparent :onPress="clearAttachment">
          <nb-icon :style="{fontSize: 34}" name="backspace" />
        </nb-button>
      </view>

      <view>
        <nb-text v-if="!attachment">No attachment yet.</nb-text>
        <image v-if="attachment && attachment.uri" :source="{uri: attachment.uri}" :style="{width: '100%', height: 500, resizeMode: 'contain'}" />
        <nb-text v-if="attachment && attachment.filename" :style="{textAlign: 'center'}">{{attachment.filename}}</nb-text>
      </view>

      <nb-spinner v-if="waiting" />

      <nb-button block primary :style="{marginTop: 20}" :onPress="sendMessage">
        <nb-text>Send</nb-text>
      </nb-button>

    </nb-content>

    <photo-modal :newPhoto="newPhoto" :closeNewPhoto="closeNewPhoto"></photo-modal>

    <album-modal :album="album" :closeAlbum="closeAlbum"></album-modal>
  </modal>
</template>

<script>
import { Dimensions, Modal } from "react-native";
import { Toast } from "native-base";
import PhotoModal from './PhotoModal'
import AlbumModal from './AlbumModal'
import axios from 'axios'

export default {
  name:'chat-modal',
  components: {
    Modal,
    PhotoModal,
    AlbumModal
  },
  data: function() {
    return {
      waiting: false,
      message: '',
      attachment: null,
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
  watch: {
    opened: function (val) {
      if (val) {
        this.message = this.newChat.message
      }else{
        this.message = ''
        this.attachment = null
      }
    }
  },
  methods: {
    close () {
      this.closeNewChat(this.message)
    },
    closeNewPhoto (photo) {
      if(photo){
        this.attachment = photo
      }
      this.newPhoto.opened = false
    },
    openNewPhoto () {
      this.newPhoto.opened = true
    },
    closeAlbum (file) {
      if(file){
        this.attachment = file
      }
      this.album.opened = false
    },
    openAlbum () {
      this.album.opened = true
    },
    clearAttachment () {
      this.attachment = null
    },
    sendMessage () {
      if(this.waiting)
        return
      this.waiting = true
      var formData = new FormData()
      formData.append('message', JSON.stringify(this.message))
      if(this.attachment){
        var file = {
          uri: this.attachment.uri,
          name: this.attachment.filename ? this.attachment.filename : 'photo.jpg'
        }
        formData.append('file', file)
      }

      var vm = this
      axios.post(xHTTPx + '/add_chat_with_file/' + vm.newChat.groupId, formData)
        .then(res => {
          vm.closeNewChat('', res.data)
        })
        .catch(function (error) {
          vm.showError('Failed to send message!')
        })
        .then(function () {
          vm.waiting = false
        })
    },
    showError (error) {
      Toast.show({
        text: error,
        buttonText: "Okay",
        type: "danger",
        position: "top"
      })
    },
  }
}
</script>

 
<style>

</style>
