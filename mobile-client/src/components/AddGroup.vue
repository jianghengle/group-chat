<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      
        <nb-form>
          <nb-label class="my-form-label">Name</nb-label>
          <nb-input v-model="name" placeholder="Group Name" />

          <nb-label class="my-form-label">Description</nb-label>
          <nb-textarea :rowSpan="5" bordered v-model="description" placeholder="Group Description" />

          <nb-label class="my-form-label" :style="{marginTop: 20}">Status</nb-label>
          <nb-list-item :selected="status=='public'" :onPress="() => statusChange('public')">
            <nb-left>
              <nb-text>Public</nb-text>
            </nb-left>
            <nb-right>
              <nb-radio color='#f0ad4e' selectedColor='#5cb85c' :selected="status=='public'" />
            </nb-right>
          </nb-list-item>
          <nb-list-item :selected="status=='private'" :onPress="() => statusChange('private')">
            <nb-left>
              <nb-text>Private</nb-text>
            </nb-left>
            <nb-right>
              <nb-radio color='#f0ad4e' selectedColor='#5cb85c' :selected="status=='private'" />
            </nb-right>
          </nb-list-item>
        </nb-form>

        <nb-spinner v-if="waiting" />

        <nb-button block primary :style="{marginTop: 25}" v-bind:on-press="addGroup" :disabled="!name.trim()">
          <nb-text>Add Group</nb-text>
        </nb-button>

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
      name: '',
      description: '',
      status: 'public'
    }
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
    addGroup () {
      if(!this.name.trim())
        return

      var vm = this
      vm.waiting = true
      var message = {name: this.name.trim(), category: 'group', description: this.description, status: this.status}
      axios.post(xHTTPx + '/add_group', message)
        .then(res => {
          var group = res.data
          store.commit('groups/updateGroup', group)
          vm.$nextTick(function(){
            vm.navigation.navigate('Group', {groupId: group.id})
          })
        })
        .catch(function (error) {
          vm.showError('Failed to create group!')
        })
        .then(function () {
          vm.waiting = false
        })
    },
    statusChange: function(value) {
      this.status = value;
    },
    requestGroups () {
      var vm = this
      axios.get(xHTTPx + '/get_groups')
        .then(res => {
          var groups = res.data
          store.commit('groups/setGroups', groups)
        })
    },
  },
  mounted () {
    this.requestGroups()
  }
}
</script>

 
<style>
.my-form-label {
  font-weight: 700;
}
</style>
