<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <scroll-view :style="{padding: 10}" ref="chatsContainer">
      <view :style="{padding: 10}">
      <nb-spinner v-if="loadingHistory" />
      <view :style="{flex: 1, flexDirection: 'row', justifyContent: 'center', marginBottom: -15}">
        <nb-button transparent primary small :onPress="loadOldChats" v-if="!historyLoaded">
          <nb-text>Load more</nb-text>
        </nb-button>
        <nb-button transparent primary small v-if="historyLoaded">
          <nb-text>Got the oldest point</nb-text>
        </nb-button>
      </view>

      <view v-for="(c, i) in chatsAsc">
        <chat :chat0="chatsAsc[i-1]" :chat1="chatsAsc[i]" :navigation="navigation" :showImageView="showImageView" :openWebView="openWebView"></chat>
      </view>

      <nb-spinner v-if="loadingChats" />
      </view>
    </scroll-view>

    <image-view
      :images="images" :imageIndex="imageViewIndex"
      :isVisible="isImageViewVisible"
      :renderFooter="renderImageViewFooter"
      :onClose="closeImageView"
    />

    <web-view-modal :webView="webView" :closeWebView="closeWebView"></web-view-modal>

    <chat-modal :newChat="newChat" :closeNewChat="closeNewChat"></chat-modal>

    <keyboard-avoiding-view behavior="padding">
      <view :style="{flexDirection: 'row', backgroundColor: '#f6f6f6'}">
        <nb-button transparent :onPress="openNewChat">
          <nb-text :style="{fontWeight: '500', fontSize: 28, color: '#7a7a7a'}">+</nb-text>
        </nb-button>
        <text-input
          keyboardType="default"
          returnKeyType="done"
          v-bind:onChangeText="(text) => inputTextChanged(text)"
          multiline
          class="message-input"
          underline-color-android="transparent"
          placeholder="Type here"
          :value="emptyMessage" />
      </view>
    </keyboard-avoiding-view>
  </nb-container>
</template>

<script>
import { Alert, Keyboard, Dimensions, View, Text } from "react-native";
import React from "react";
import { Toast } from "native-base";
import store from '../store'
import axios from 'axios'
import moment from 'moment';
import Chat from './Chat'
import MyHeader from './MyHeader'
import ImageView from 'react-native-image-view'
import WebViewModal from './WebViewModal'
import ChatModal from './ChatModal'

const deviceWidth = Dimensions.get("window").width;
const deviceHeight = Dimensions.get("window").height;

export default {
  name: 'chats',
  components: {
    MyHeader,
    Chat,
    ImageView,
    WebViewModal,
    ChatModal
  },
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      emptyMessage: '',
      message: '',
      loadingChats: false,
      loadingHistory: false,
      isImageViewVisible: false,
      imageViewIndex: 0,
      webView: {
        opened: false,
        uri: null,
        title: ''
      },
      newChat: {
        opened: false,
        message: '',
        groupId: null
      }
    }
  },
  computed: {
    groupId () {
      return this.navigation.state.params.groupId
    },
    group () {
      return store.state.groups.groups[this.groupId]
    },
    userId () {
      return store.state.user.user.id
    },
    chatsDesc () {
      return store.state.groups.chats[this.groupId]
    },
    chatsAsc () {
      if(this.chatsDesc){
        return this.chatsDesc.slice().reverse()
      }
      return []
    },
    latestTimestamp () {
      if(this.chatsDesc && this.chatsDesc.length){
        return this.chatsDesc[0].timestamp
      }
      return null
    },
    oldestTimestamp () {
      if(this.chatsDesc && this.chatsDesc.length){
        return this.chatsDesc[this.chatsDesc.length - 1].timestamp
      }
      return null
    },
    groupTimestamp () {
      if(this.group){
        return this.group.timestamp
      }
      return null
    },
    historyLoaded () {
      return store.state.groups.historyLoaded[this.groupId]
    },
    images () {
      var images = []
      this.chatsAsc.forEach(function(c){
        if(c.fileType=='image'){
          images.push({
            source: {uri: c.downloadLink},
            title: c.filename,
            width: deviceWidth,
            chatId: c.id
          })
        }
      })
      return images
    }
  },
  watch: {
    groupId: function (val) {
      store.commit('groups/setLastTimestamp', {groupId: this.groupId, timestamp: this.latestTimestamp})
      this.getChats()
      setTimeout(this.scrollToLatest, 500)
    },
    groupTimestamp: function (val) {
      if(!val)
        return
      this.getChats()
    },
  },
  methods: {
    getChats () {
      var chatNum = 30
      var url = xHTTPx + '/get_latest_chats/' + this.groupId + '/' + chatNum
      if(this.latestTimestamp){
        url = xHTTPx + '/get_chats_since/' + this.groupId + '/' + this.latestTimestamp
      }
      this.loadingChats = true
      var vm = this
      axios.get(url)
        .then(res => {
          var resp = res.data
          var chats = vm.buildChats(resp[0], resp[1])
          if(chats.length && chats[0].timestamp > vm.latestTimestamp){
            store.commit('groups/pushGroupChats', {groupId: vm.groupId, chats: chats})
            setTimeout(vm.scrollToLatest, 500)
          }
        })
        .catch(function (error) {
          vm.showError('Failed to get chats!')
        })
        .then(function () {
          vm.loadingChats = false
        })
    },
    buildChats (chats, users) {
      var userMap = {}
      users.forEach(function(u){
        userMap[u.id] = u
      })
      return chats.map(function(c){
        c.user = userMap[c.userId]
        var d = moment(c.timestamp)
        c.timeLabel = d.format('h:mm A')
        c.timeLabelSmall = d.format('h:mm')
        if(c.attachmentKey && c.filename){
          c.downloadLink = xHTTPx + /download_attachment/ + c.attachmentKey
          var ext = c.filename.includes('.') ? c.filename.split('.').pop().toLowerCase() : ''
          var imageExts = ['png', 'jpg', 'jpeg', 'gif', 'bmp']
          var videoExts = ['mp4', 'webm', 'ogg', 'mov']
          if(imageExts.includes(ext)){
            c.fileType = 'image'
          }else if(videoExts.includes(ext)){
            c.fileType = 'video'
          }else{
            c.fileType = 'other'
          }
        }
        return c
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
    inputTextChanged (text) {
      if(!text)
        return
      this.message = text
      var lastChar = this.message[this.message.length-1]
      if(lastChar == '\n'){
        this.sendMessage()
      }
    },
    sendMessage () {
      var message = this.message.trim()
      if(message){
        var vm = this
        axios.post(xHTTPx + '/add_chat/' + vm.groupId, {message: message, attachmentKey: '', forward: ''})
          .then(res => {
            var resp = res.data
            var chats = this.buildChats ([resp[0]], [resp[1]])
            store.commit('groups/pushGroupChats', {groupId: vm.groupId, chats: chats})
            setTimeout(function(){
              store.commit('groups/setLastTimestamp', {groupId: vm.groupId, timestamp: vm.latestTimestamp})
              setTimeout(vm.scrollToLatest)
            })
          })
          .catch(function (error) {
            vm.showError('Failed to send message!')
          })
      }
      this.message = ''
      if(this.emptyMessage){
        this.emptyMessage = ''
      }else{
        this.emptyMessage = ' '
        var vm = this
        setTimeout(function(){
          vm.emptyMessage = ''
        })
      }
    },
    loadOldChats () {
      this.loadingHistory = true
      var chatNum = 30
      var vm = this
      var url = xHTTPx + '/get_chats_before/' + this.groupId + '/' + this.oldestTimestamp + '/' + chatNum
      axios.get(url)
        .then(res => {
          var resp = res.data
          var chats = this.buildChats(resp[0], resp[1])
          if(chats.length < chatNum){
            store.commit('groups/setHistoryLoaded', vm.groupId)
          }
          store.commit('groups/prependGroupChats', {groupId: vm.groupId, chats: chats})
        })
        .catch(function (error) {
          vm.showError('Failed to load history!')
        })
        .then(function () {
          vm.loadingHistory = false
        })
    },
    showImageView (chatId) {
      var index = -1
      for(var i=0;i<this.images.length;i++){
        if(this.images[i].chatId == chatId){
          index = i
          break
        }
      }
      if(index != -1){
        this.imageViewIndex = index
        this.isImageViewVisible = true
      }
    },
    closeImageView () {
      this.isImageViewVisible = false
    },
    renderImageViewFooter: function(image) {
      return (
        <View>
          <Text style={{color: 'white', textAlign: 'center', width: deviceWidth, paddingBottom: 15}}>{image.title}</Text>
        </View>
      );
    },
    closeWebView () {
      this.webView.opened = false
      this.webView.uri = null
      this.webView.title = ''
    },
    openWebView (uri, title) {
      this.webView.uri = uri
      this.webView.title = title
      this.webView.opened = true
    },
    closeNewChat (message, resp) {
      if(resp){
        var vm = this
        var chats = this.buildChats ([resp[0]], [resp[1]])
        store.commit('groups/pushGroupChats', {groupId: vm.groupId, chats: chats})
        setTimeout(function(){
          store.commit('groups/setLastTimestamp', {groupId: vm.groupId, timestamp: vm.latestTimestamp})
          setTimeout(vm.scrollToLatest, 100)
        }, 100)
      }
      this.newChat.opened = false
    },
    openNewChat () {
      this.newChat.message = this.message
      this.newChat.groupId = this.groupId
      this.newChat.opened = true
    },
    scrollToLatest () {
      this.$refs.chatsContainer.scrollToEnd()
    },
  },
  mounted () {
    store.commit('groups/setLastTimestamp', {groupId: this.groupId, timestamp: this.latestTimestamp})
    this.getChats()
    setTimeout(this.scrollToLatest, 500)
  }
}
</script>

 
<style>
.message-input {
  flex: 1;
  margin: 8;
  padding: 5;
  font-size: 16;
  background-color: white;
  border-radius: 5;
}
</style>
