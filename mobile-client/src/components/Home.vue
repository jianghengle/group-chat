<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <status-bar :barStyle="'light-content'"></status-bar>
    <nb-content v-if="ready" padder>
      <view class="home-container">
        <view class="text-container">
          <nb-h2 :style="{marginBottom: 8, fontWeight: '700'}">Group Chat</nb-h2>
          <nb-text>My hobby chat app like <nb-text :style="{fontStyle: 'italic'}">Slack</nb-text></nb-text>
        </view>
        <view class="form-container">
          <nb-form>
            <nb-item>
              <nb-icon active name="person" />
              <nb-input placeholder="Email" keyboardType="email-address" v-model="email" />
            </nb-item>
            <nb-item>
              <nb-icon active name="lock" />
              <nb-input secureTextEntry placeholder="Password" v-model="password" />
            </nb-item>
          </nb-form>
          <nb-spinner v-if="waiting" />
          <nb-button v-if="!waiting" block :style="{marginTop: 25, marginLeft: 15}" :disabled="waiting" v-bind:on-press="signIn">
            <nb-text>Sign In</nb-text>
          </nb-button>
        </view>
      </view>
    </nb-content>
  </nb-container>
</template>

<script>
import { Dimensions, Platform, AsyncStorage } from "react-native";
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
      ready: false,
      email: 'john.smith@guest.com',
      password: '123456',
      waiting: false
    }
  },
  methods: {
    signIn () {
      this.email = this.email.trim().toLowerCase()
      var message = {email: this.email, password: this.password}
      vm = this
      vm.waiting = true
      axios.post(xHTTPx + '/get_auth_token', message)
        .then(res => {
          var user = res.data
          store.commit('user/setUser', user)
          vm.navigation.navigate('MyGroups')
        })
        .catch(function (error) {
          vm.showError('Failed to authorize user!')
          store.commit('user/reset')
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
    loadUser: async function() {
      try {
        const value = await AsyncStorage.getItem('user');
        if (value !== null) {
          var user = JSON.parse(value)
          if(user.token){
            store.commit('user/setUser', user)
            this.navigation.navigate('MyGroups')
          }
        }
        this.ready = true
      } catch (error) {
        console.log('failed to get user from AsyncStorage')
        this.ready = true
      }
    }
  },
  created () {
    this.loadUser()
  }
}
</script>

 
<style>
.home-container {
  margin-top: 80;
}

.text-container {
  padding: 15;
  background-color: transparent;
}

.form-container {
  padding-left: 5;
  padding-right: 20;
}
</style>