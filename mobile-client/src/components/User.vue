<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      <view class="form-container">
        <nb-form>
          <nb-item floatingLabel>
            <nb-label>Email</nb-label>
            <nb-input disabled v-model="email" />
          </nb-item>
          <nb-item floatingLabel>
            <nb-label>Full Name</nb-label>
            <nb-input disabled v-model="fullName" />
          </nb-item>
        </nb-form>
        <nb-button block danger :style="{marginTop: 25}" v-bind:on-press="signOut">
          <nb-text>Sign Out</nb-text>
        </nb-button>
      </view>
    </nb-content>

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
      email: null,
      fullName: null,
    }
  },
  methods: {
    signOut () {
      Alert.alert(
        'Sign Out',
        'Are you sure to sign out?',
        [
          {text: 'Yes, sign me out', onPress: this.signOutConfirmed},
          {text: 'Cancel', style: 'cancel'},
        ],
        { cancelable: false }
      )
    },
    signOutConfirmed () {
      store.commit('user/reset')
      this.navigation.navigate('Home')
    }
  },
  created () {
    this.email = store.state.user.user.email
    this.fullName = store.state.user.user.fullName
  }
}
</script>

 
<style>

</style>
