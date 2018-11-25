<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>

    </nb-content>

    <keyboard-avoiding-view behavior="padding">
      <view :style="{flexDirection: 'row', backgroundColor: '#f6f6f6'}">
        <nb-icon name="add" active :style="{width: 28, padding: 10, color: '#4a4a4a'}" />
        <text-input
          v-model="message"
          keyboardType="default"
          returnKeyType="done"
          v-bind:onChangeText="inputTextChanged"
          multiline
          class="message-input"
          underline-color-android="transparent"
          placeholder="Type here" />
      </view>
    </keyboard-avoiding-view>

  </nb-container>
</template>

<script>
import { Alert } from "react-native";
import { Toast } from "native-base";
import store from '../store'
import axios from 'axios'
import MyHeader from './MyHeader'

export default {
  components: {
    MyHeader
  },
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      message: '',
    }
  },
  computed: {
    groupId () {
      return this.navigation.state.params.groupId
    },
    group () {
      return store.state.groups.groups[this.groupId]
    }
  },
  watch: {
    groupId: function (val) {
      console.log('group changed', this.group)
    }
  },
  methods: {
    inputTextChanged () {
      if(!this.message)
        return
      var lastChar = this.message[this.message.length-1]
      if(lastChar == '\n'){
        this.sendMessage()
      }
    },
    sendMessage () {
      var message = this.message.trim()
      console.log('send', message)
      this.message = ''
    }
  },
  mounted () {
    console.log(this.group)
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
