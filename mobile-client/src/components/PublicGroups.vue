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
          <nb-card v-for="g in publicGroups" :key="'pub-' + g.id">
            <nb-card-item header button :onPress="() => openGroup(g.id)">
              <nb-text>{{g.name}}</nb-text>
              <nb-button primary small :style="{marginLeft: 'auto'}" v-if="!groups[g.id]" v-bind:on-press="() => joinGroup(g)">
                <nb-text>Join</nb-text>
              </nb-button>

            </nb-card-item>
            <nb-card-item :style="{marginTop: -15, marginBottom: -10}">
              <nb-body>
                <nb-text :style="{marginBottom: 5}">
                  {{g.owner.fullName}}  |  {{g.membershipCount}}
                </nb-text>
                <nb-text>
                  {{g.description}}
                </nb-text>
              </nb-body>
            </nb-card-item>
            <nb-card-item footer></nb-card-item>
          </nb-card>
        </view>

      </nb-content>
    </view>
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
      publicGroups: []
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
