<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      <nb-spinner v-if="waiting" />
      <view v-if="!waiting ">
        <view v-if="!publicGroups.length">
          <nb-text>No public group found yet.</nb-text>
        </view>
        <view v-else>
          <nb-list-item :style="{marginLeft: 0, paddingTop: 10, paddingBottom: 10}" v-for="g in publicGroups" :key="'pub-group-' + g.id"
            :onPress="() => openGroup(g.id)" :onLongPress="() => handleLongPress(g)">
            <nb-body>
              <nb-text>{{g.name}}</nb-text>
              <nb-text note :style="{marginTop: 3}">{{g.owner.fullName}}  |  {{g.membershipCount}}</nb-text>
              <nb-text note :style="{marginTop: 3}">{{g.description}}</nb-text>
            </nb-body>
            <nb-right>
              <nb-button transparent v-if="!groups[g.id]" v-bind:on-press="() => joinGroup(g)">
                <nb-text>Join</nb-text>
              </nb-button>
            </nb-right>
          </nb-list-item>
        </view>

      </nb-content>
    </view>
  </nb-container>
</template>

<script>
import { Alert, CameraRoll } from "react-native";
import { Toast, ActionSheet } from "native-base";
import store from '../store'
import axios from 'axios'
import MyHeader from './MyHeader'

export default {
  components: {
    MyHeader,
  },
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      waiting: false,
      publicGroups: [],
      photos: [],
    }
  },
  computed: {
    userId () {
      return store.state.user.user.id
    },
    groups () {
      return store.state.groups.groups
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
    requestPublicGroups () {
      var vm = this
      vm.waiting = true
      axios.get(xHTTPx + '/get_public_groups')
        .then(res => {
          var resp = res.data
          var userMap = {}
          resp[1].forEach(function(u){
            userMap[u.id] = u
          })
          vm.publicGroups = resp[0].map(function(g){
            g.owner = userMap[g.ownerId]
            return g
          })
        })
        .catch(function (error) {
          vm.showError('Failed to get public groups!')
        })
        .then(function () {
          vm.waiting = false
        })
    },
    joinGroup (group) {
      var vm = this;
      Alert.alert(
        'Join Group',
        'Are you sure to join the group: ' + group.name + '?',
        [
          {text: 'Yes', onPress: () => vm.joinGroupConfirmed(group)},
          {text: 'Cancel', style: 'cancel'},
        ],
        { cancelable: false }
      )
    },
    joinGroupConfirmed (group) {
      var vm = this
      var message = {userId: this.userId}
      axios.post(xHTTPx + '/join_group/' + group.id, message)
        .then(res => {
          vm.openGroup(group.id)
        })
        .catch(function (error) {
          vm.showError('Failed to join group!')
        })
    },
    openGroup (groupId) {
      var vm = this
      axios.get(xHTTPx + '/get_group/' + groupId)
        .then(res => {
          var group = res.data
          store.commit('groups/updateGroup', group)
          vm.$nextTick(function(){
            vm.navigation.navigate('Group', {groupId: group.id})
          })
        })
        .catch(function (error) {
          vm.showError('Need to join the group first!')
        })
    },
    handleLongPress (g) {
      if(this.groups[g.id])
        return

      var btnActions = [{method: 'startConversation', arg: g.owner.id}]
      var btnOptions = ['Contact with ' + g.owner.fullName]
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
  },
  mounted () {
    this.$nextTick(function(){
      this.requestPublicGroups()
    })
  }
}
</script>

 
<style>

</style>
