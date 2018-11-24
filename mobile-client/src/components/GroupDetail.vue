<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      <nb-spinner v-if="!group" />
      <view v-if="group">
        <nb-form>
          <nb-label class="my-form-label">Name</nb-label>
          <nb-input v-model="newName" :disabled="!isOwner" />

          <nb-label class="my-form-label">Description</nb-label>
          <nb-textarea :rowSpan="5" bordered v-model="newDescription" :disabled="!isOwner" />

          <nb-label class="my-form-label" :style="{marginTop: 20}">Status</nb-label>
          <nb-list-item v-if="isOwner || newStatus=='public'" :selected="newStatus=='public'" :onPress="() => statusChange('public')">
            <nb-left>
              <nb-text>Public</nb-text>
            </nb-left>
            <nb-right>
              <nb-radio color='#f0ad4e' selectedColor='#5cb85c' :selected="newStatus=='public'" />
            </nb-right>
          </nb-list-item>
          <nb-list-item v-if="isOwner || newStatus=='private'" :selected="newStatus=='private'" :onPress="() => statusChange('private')">
            <nb-left>
              <nb-text>Private</nb-text>
            </nb-left>
            <nb-right>
              <nb-radio color='#f0ad4e' selectedColor='#5cb85c' :selected="newStatus=='private'" />
            </nb-right>
          </nb-list-item>
        </nb-form>
        <nb-spinner v-if="waiting" />
        <nb-button block danger :style="{marginTop: 25}" v-bind:on-press="updateProfile" v-if="isOwner && !waiting" :disabled="!profileChanged || !newProfile">
          <nb-text>Update</nb-text>
        </nb-button>

        <nb-label class="my-form-label" :style="{marginTop: 40}">Members</nb-label>
        <nb-swipe-row
          :body="getSwipeBodyComponet(group.owner.id == userId ? (group.owner.fullName + ' (Owner, Me)') : group.owner.fullName + ' (Owner)')"/>
        <view v-if="isOwner">
          <nb-swipe-row v-for="m in group.members" :key="'member-' + m.id"
            :rightOpenValue="-75"
            :body="getSwipeBodyComponet(m.id == userId ? (m.fullName + ' (Me)') : m.fullName)"
            :right="getSwipeRightComponet(m)" />
        </view>
        <view v-if="!isOwner">
          <nb-swipe-row v-for="m in group.members" :key="'member-' + m.id"
            :body="getSwipeBodyComponet(m.id == userId ? (m.fullName + ' (Me)') : m.fullName)" />
        </view>

        <nb-button block danger :style="{marginTop: 25}" v-bind:on-press="deleteGroup" v-if="isOwner && !waiting" :disabled="profileChanged">
          <nb-text>Delete</nb-text>
        </nb-button>

        <nb-button block danger :style="{marginTop: 25}" v-bind:on-press="quitGroup" v-if="!isOwner">
          <nb-text>Quit</nb-text>
        </nb-button>
      </view>
    </nb-content>

  </nb-container>
</template>

<script>
import { Alert } from "react-native";
import React from "react";
import { Toast, Picker, Icon , Button, Text, View} from "native-base";
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
      waiting: false,
      group: null,
      newName: '',
      newDescription: '',
      newStatus: ''
    }
  },
  computed: {
    groupId () {
      return this.navigation.state.params.groupId
    },
    userId () {
      return store.state.user.user.id
    },
    isOwner () {
      if(!this.group)
        return false
      return this.userId == this.group.ownerId
    },
    profileChanged () {
      if(!this.group)
        return false
      return (this.newName != this.group.name)
        || (this.newDescription != this.group.description)
        || (this.newStatus != this.group.status)
    },
    newProfile () {
      if(!this.newName.trim())
        return null
      return {
        name: this.newName.trim(),
        description: this.newDescription,
        status: this.newStatus
      }
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
    loadGroup () {
      if(!this.group)
        return
      this.newName = this.group.name
      this.newDescription = this.group.description
      this.newStatus = this.group.status
    },
    requestGroup () {
      var vm = this
      axios.get(xHTTPx + '/get_group_detail/' + vm.groupId)
        .then(res => {
          var resp = res.data
          var group = resp[0]
          var members = []
          resp[1].forEach(function(u){
            if(u.id == group.ownerId){
              group.owner = u
            }else{
              members.push(u)
            }
          })
          group.members = members
          vm.group = group
          vm.loadGroup()
        })
        .catch(function (error) {
          vm.showError('Failed to get group detail!')
        })
    },
    updateProfile () {
      if(!this.newProfile)
        return

      var vm = this
      vm.waiting = true
      axios.post(xHTTPx + '/update_group/' + vm.groupId, vm.newProfile)
        .then(res => {
          var resp = res.data
          vm.group.name = resp.name
          vm.group.description = resp.description
          vm.group.status = resp.status
          store.commit('groups/updateGroup', resp)
          vm.loadGroup()
        })
        .catch(function (error) {
          vm.showError('Failed to update group!')
        })
        .then(function () {
          vm.waiting = false
        })
    },
    statusChange: function(value) {
      if(this.isOwner)
        this.newStatus = value;
    },
    deleteGroup () {
      var vm = this
      Alert.alert(
        'Delete Group',
        'Are you sure to delete the whole group: ' + vm.group.name + '?',
        [
          {text: 'Yes', onPress: () => vm.deleteGroupConfirmed()},
          {text: 'Cancel', style: 'cancel'},
        ],
        { cancelable: false }
      )
    },
    deleteGroupConfirmed () {
      var vm = this
      vm.waiting = true
      axios.post(xHTTPx + '/delete_group/' + vm.groupId)
        .then(res => {
          vm.navigation.navigate('PublicGroups')
          store.commit('groups/deleteGroup', vm.groupId)
        })
        .catch(function (error) {
          vm.showError('Failed to delete group!')
          vm.waiting = false
        })
    },
    quitGroup () {
      var vm = this
      Alert.alert(
        'Quit Group',
        'Are you sure to quit this group: ' + vm.group.name + '?',
        [
          {text: 'Yes', onPress: () => vm.quitGroupConfirmed()},
          {text: 'Cancel', style: 'cancel'},
        ],
        { cancelable: false }
      )
    },
    quitGroupConfirmed () {
      var vm = this
      vm.waiting = true
      axios.post(xHTTPx + '/quit_group/' + vm.groupId, {userId: vm.userId})
        .then(res => {
          vm.navigation.navigate('PublicGroups')
          store.commit('groups/deleteGroup', vm.groupId)
        })
        .catch(function (error) {
          vm.showError('Failed to quit group!')
          vm.waiting = false
        })
    },
    deleteMember (m) {
      var vm = this
      Alert.alert(
        'Delete Member',
        'Are you sure to delete this member: ' + m.fullName + '?',
        [
          {text: 'Yes', onPress: () => vm.deleteMemberConfirmed(m)},
          {text: 'Cancel', style: 'cancel'},
        ],
        { cancelable: false }
      )
    },
    deleteMemberConfirmed (m) {
      var vm = this
      vm.waiting = true
      axios.post(xHTTPx + '/quit_group/' + vm.groupId, {userId: m.id})
        .then(res => {
          var index = vm.group.members.indexOf(m)
          vm.group.members.splice(index, 1)
        })
        .catch(function (error) {
          vm.showError('Failed to delete member!')
        })
        .then(function () {
          vm.waiting = false
        })
    },
    getSwipeBodyComponet: function(fullName) {
      return (
        <View>
          <Text>{fullName}</Text>
        </View>
      );
    },
    getSwipeRightComponet: function(member) {
      return (
        <Button danger onPress={() => this.deleteMember(member)}>
          <Icon active name="trash" />
        </Button>
      );
    },

  },
  mounted () {
    this.$nextTick(function(){
      this.requestGroup()
    })
  }
}
</script>

 
<style>
.my-form-label {
  font-weight: 700;
}
</style>
