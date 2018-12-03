<template>

  <nb-list>
    <nb-list-item itemHeader first v-if="!isContinued && (isNewChat || isNewDay)"
      :style="{paddingLeft: 0, paddingRight: 0, paddingTop: 5, paddingBottom: 5, borderBottomWidth: 1, borderColor: seperatorColor, marginTop: seperatorMarginTop, marginBottom: seperatorMarginBottom}">
      <nb-left :style="{flex: 2}">
        <nb-text v-if="isNewDay" :style="{fontSize: 16, fontWeight: '700', color: '#363636'}">{{isNewDay}}</nb-text>
      </nb-left>
      <nb-right :style="{flex: 2}">
        <nb-text v-if="isNewChat" :style="{color: '#df2736'}">new messages</nb-text>
      </nb-right>
    </nb-list-item>

    <nb-list-item avatar :style="{marginLeft: 0, marginTop: isContinued ? -15 : 0}" :onLongPress="handleLongPress">
      <nb-left :style="{paddingTop: 10}">
        <nb-thumbnail small :source="isContinued ? {} : logo" :style="{borderRadius: 3}"/>
      </nb-left>
      <nb-body :style="{marginLeft: 8, borderColor: 'transparent', paddingTop: 8, paddingBottom: 8}">
        <nb-text v-if="!isContinued" :style="{fontWeight: '700', color: '#363636'}">{{chat1.user.fullName}}  <nb-text :style="{fontWeight: '300', fontSize: 12}" note>{{chat1.timeLabel}}</nb-text></nb-text>
        <nb-text :style="{color: '#363636'}">{{chat1.message}}</nb-text>
        <view v-if="chat1.downloadLink">
          <view v-if="chat1.fileType=='image'">
            <touchable-without-feedback :onPress="showImageViewFromHere">
              <image :source="{uri: chat1.downloadLink}" :style="{width: imageWidth, height: imageHeight, resizeMode: 'contain'}" />
            </touchable-without-feedback>
          </view>
          <!--<view v-if="chat1.fileType=='video'">
            <video v-if="!videoError" :source="{uri: chat1.downloadLink}" :style="{width: videoWidth, height: videoHeight}" useNativeControls :resizeMode="'contain'" :onError="onVideoError" />
          </view>-->
          <view>
             <nb-button transparent primary small :onPress="openUri">
              <nb-text :style="{paddingLeft: 0}"><nb-icon name="download" :style="{fontSize: 18, color: '#005aff'}" /> {{chat1.filename}}</nb-text>
            </nb-button>
          </view>
        </view>
      </nb-body>
    </nb-list-item>

  </nb-list>

</template>

<script>
import { Dimensions } from "react-native";
import { Alert } from "react-native";
import { ActionSheet, Toast } from "native-base";
import store from '../store'
import axios from 'axios'
import logo from "../../assets/128x128.png";
//import { Video } from 'expo';
import moment from 'moment';

const deviceWidth = Dimensions.get("window").width;

export default {
  name: 'chat',
  components: {
    //Video
  },
  props: {
    navigation: {
      type: Object
    },
    chat0: {
      type: Object
    },
    chat1: {
      type: Object
    },
    showImageView: {
      type: Function
    },
    openWebView: {
      type: Function
    }
  },
  data: function() {
    return {
      message: '',
      logo,
      contentWidth: deviceWidth - 76,
      videoError: false,
    }
  },
  computed: {
    userId () {
      return store.state.user.user.id
    },
    groupId () {
      return this.navigation.state.params.groupId
    },
    group () {
      return store.state.groups.groups[this.groupId]
    },
    lastTimestamp () {
      return store.state.groups.lastTimestamps[this.groupId]
    },
    isNewChat () {
      if(!this.lastTimestamp)
        return false
      if(!this.chat0)
        if(this.chat1.timestamp > this.lastTimestamp)
          return true
        else
          return false
      if(this.chat0.timestamp <= this.lastTimestamp && this.chat1.timestamp > this.lastTimestamp)
        return true
      return false
    },
    isNewDay () {
      if(!this.chat0){
        var d = moment(this.chat1.timestamp)
        return d.format('MMM D')
      }
      var d0 = moment(this.chat0.timestamp)
      var day0 = d0.format('MMM D')
      var d1 = moment(this.chat1.timestamp)
      var day1 = d1.format('MMM D')
      if(day0 != day1)
        return day1
      return false
    },
    isContinued () {
      if(this.isNewDay || this.isNewChat)
        return false
      if(!this.chat0)
        return false
      if(this.chat0.userId != this.chat1.userId)
        return false
      return true
    },
    imageWidth () {
      return this.contentWidth
    },
    imageHeight () {
      return this.imageWidth * 0.75
    },
    videoWidth () {
      return this.contentWidth
    },
    videoHeight () {
      return this.videoWidth * 0.55
    },
    seperatorColor () {
      if(this.isNewChat)
        return '#df2736'
      if (this.isNewDay)
        return '#363636'
      return 'rgba(0,0,0,0)'
    },
    seperatorMarginTop () {
      if(this.isNewDay){
        return 10
      }
      return 0
    },
    seperatorMarginBottom () {
      if(this.isNewDay){
        return 5
      }
      return 0
    },
    otherGroups () {
      var groupId = this.groupId
      return Object.values(store.state.groups.groups).filter(function(g){
        return (g && (g.id != groupId))
      })
    },
  },
  methods: {
    showError (error) {
      Toast.show({
        text: error,
        buttonText: "Okay",
        type: "danger",
        position: "top"
      })
    },
    showImageViewFromHere () {
      this.showImageView(this.chat1.id)
    },
    onVideoError (err) {
      this.videoError = true
    },
    openUri () {
      this.openWebView(this.chat1.downloadLink, this.chat1.filename)
    },
    handleLongPress () {
      var btnActions = []
      var btnOptions = []
      if(this.chat1.user.id != this.userId){
        btnActions.push({method: 'startConversation', arg: this.chat1.user.id})
        btnOptions.push('Message with ' + this.chat1.user.fullName)
      }
      this.otherGroups.forEach(function(g){
        btnActions.push({method: 'forwardMessage', arg: g})
        btnOptions.push('Forward to ' + (g.name == '__' ? 'Yourself Only!' : g.name))
      })
      btnOptions.push('Cancel')
      ActionSheet.show(
        {
          options: btnOptions,
          cancelButtonIndex: btnOptions.length - 1,
        },
        buttonIndex => {
          var action = btnActions[buttonIndex]
          if(action){
            this[action.method](action.arg)
          }
        }
      );
    },
    startConversation (userId) {
      var vm = this
      axios.post(xHTTPx + '/start_conversation', {userId: userId})
        .then(res => {
          var group = res.data
          store.commit('groups/updateGroup', group)
          vm.$nextTick(function(){
            vm.navigation.navigate('Group', {groupId: group.id})
          })
        })
        .catch(function (error) {
          vm.showError('Failed to start conversation!')
        })
    },
    forwardMessage (group) {
      var message = {message: this.chat1.message, attachmentKey: this.chat1.attachmentKey, forward: 'yes'}
      var vm = this
      axios.post(xHTTPx + '/add_chat/' + group.id, message)
        .then(res => {
        })
        .catch(function (error) {
          vm.showError('Failed to forward message!')
        })
    }
  },
  mounted () {
  
  }
}
</script>

 
<style>

</style>
