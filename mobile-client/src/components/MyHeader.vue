<template>
  <nb-header>
    <nb-left>
      <nb-button transparent :onPress="goBack" v-if="route.routeName != 'Home'" :style="{width: 50}">
        <nb-icon name="arrow-back" />
      </nb-button>
    </nb-left>
    <nb-body>
      <nb-title :style="{width: 200}">{{title}}</nb-title>
    </nb-body>
    <nb-right>
      <nb-button transparent :onPress="goGroupDetail" v-if="route.routeName == 'Group'">
        <nb-icon active name="more" />
      </nb-button>
    </nb-right>
  </nb-header>
</template>

<script>
import { Toast } from "native-base";
import store from '../store'
import axios from 'axios'

export default {
  name: 'my-header',
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      waiting: false
    }
  },
  computed: {
    route () {
      return this.navigation.state
    },
    title () {
      if(this.route.routeName == 'User')
        return 'User Profile'
      if(this.route.routeName == 'Home')
        return 'Sign In'
      if(this.route.routeName == 'PublicGroups')
        return 'Public Groups'
      if(this.route.routeName == 'Group' || this.route.routeName == 'GroupDetail'){
        var group = store.state.groups.groups[this.route.params.groupId]
        if(group)
          return (group.category == 'conversation' && group.name == '__') ? 'Yourself Only!' : group.name
      }
      if(this.route.routeName == 'AddGroup')
        return 'Add Group'
      return 'Header'
    }
  },
  methods: {
    goBack () {
      if(this.route.routeName == 'GroupDetail'){
        var groupId = this.route.params.groupId
        this.navigation.navigate('Group', {groupId: groupId})
      } else {
        this.navigation.navigate('DrawerOpen')
      }
    },
    goGroupDetail () {
      var groupId = this.route.params.groupId
      this.navigation.navigate('GroupDetail', {groupId: groupId})
    }
  },
  created () {
    
  }
}
</script>

 
<style>

</style>
