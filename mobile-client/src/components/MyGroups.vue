<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      <nb-spinner v-if="waiting" />
      <view v-if="!waiting ">
        <view v-if="!myGroups.length">
          <nb-text>No group involved yet.</nb-text>
        </view>
        <view v-else>
          <nb-list-item :style="{marginLeft: 0, paddingTop: 10, paddingBottom: 10}" v-for="g in myGroups" :key="'my-group-' + g.id"
            :onPress="() => openGroup(g.id)" :onLongPress="() => handleLongPress(g)">
            <nb-body>
              <nb-text>{{g.name}}</nb-text>
              <nb-text note :style="{marginTop: 3}">{{g.owner.fullName}}  |  {{g.membershipCount}}</nb-text>
              <nb-text note :numberOfLines="1" :style="{marginTop: 3}">{{g.latestMessage}}</nb-text>
            </nb-body>
            
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
      myGroups: [],
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
    requestMyGroups () {
      var vm = this
      vm.waiting = true
      axios.get(xHTTPx + '/get_my_groups')
        .then(res => {
          var resp = res.data
          var userMap = {}
          resp[2].forEach(function(u){
            userMap[u.id] = u
          })
          var chatMap = {}
          resp[1].forEach(function(c){
            c.user = userMap[c.userId]
            chatMap[c.groupId] = c
          })
          vm.myGroups = resp[0].map(function(g){
            g.owner = userMap[g.ownerId]
            g.latestChat = chatMap[g.id]
            if(g.latestChat){
              var latestMessage = g.latestChat.message ? g.latestChat.message : "..."
              g.latestMessage = g.latestChat.user.fullName + ": " + latestMessage
            }
            return g
          })
        })
        .catch(function (error) {
          vm.showError('Failed to get my groups!')
        })
        .then(function () {
          vm.waiting = false
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
  },
  mounted () {
    this.$nextTick(function(){
      this.requestMyGroups()
    })
  }
}
</script>

 
<style>

</style>
