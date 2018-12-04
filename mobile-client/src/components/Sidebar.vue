<template>
  <nb-container>
    <nb-content class="sidebar-content-wrapper" :bounces="false">
      <image :source="drawerCover" class="drawer-cover" :style="stylesObj.drawerCoverObj"/>
      
      <nb-list v-if="token">
        <nb-list-item button noBorder :selected="route.routeName == 'User'" :onPress="() => navigation.navigate('User')">
          <nb-left :style="{flex: 1}">
            <nb-icon name="person" class="sidebar-icon" />
            <nb-text>
              {{userFullName}}
            </nb-text>
            <nb-icon name="exit" class="extra-icon" :style="{color: '#df2736', fontSize: 26}" :onPress="signOut" />
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder :selected="route.routeName == 'PublicGroups'" :onPress="() => navigation.navigate('PublicGroups')">
          <nb-left>
            <nb-icon name="search" class="sidebar-icon" />
            <nb-text>Public Groups</nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder :selected="route.routeName == 'AddGroup'" :onPress="() => navigation.navigate('AddGroup')">
          <nb-left>
            <nb-icon name="people" class="sidebar-icon" />
            <nb-text>My Groups</nb-text>
            <nb-icon name="add-circle" class="extra-icon" />
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder v-for="g in groups" :key="'nav-group-'+g.id"
          :selected="(route.routeName=='Group' || route.routeName=='GroupDetail') && route.params.groupId==g.id"
          class="second-level-nav" :onPress="() => openGroup(g.id)">
          <nb-left>
            <nb-text :class="{'text-bold': (g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))}">
              {{g.name}}
            </nb-text>
            <nb-icon active name="chatbubbles" class="extra-icon" v-if="(g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))" />
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder>
          <nb-left>
            <nb-icon name="chatboxes" class="sidebar-icon" />
            <nb-text>Direct Messages</nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder v-for="g in conversations" :key="'nav-group-'+g.id"
          :selected="(route.routeName=='Group' || route.routeName=='GroupDetail') && route.params.groupId==g.id"
          class="second-level-nav" :onPress="() => openGroup(g.id)">
          <nb-left>
            <nb-text :class="{'text-bold': (g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))}">
              {{g.name == '__' ? 'Yourself Only!' : g.name}}
            </nb-text>
            <nb-icon active name="chatbubbles" class="extra-icon" v-if="(g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))" />
          </nb-left>
        </nb-list-item>
        
      </nb-list>
    </nb-content>
  </nb-container>
</template>

<script>
import { Dimensions, Platform, Alert } from "react-native";
import { Toast } from "native-base";
import drawerCover from "../../assets/drawer-cover.png";
import axios from 'axios'
import store from '../store'

const deviceHeight = Dimensions.get("window").height;
const deviceWidth = Dimensions.get("window").width;
export default {
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      drawerCover: drawerCover,
      stylesObj: {
        drawerCoverObj: {
          height: deviceHeight / 4
        },
      },
    };
  },
  computed: {
    token () {
      return store.state.user.user.token
    },
    userFullName () {
      return store.state.user.user.fullName
    },
    route () {
      var index = this.navigation.state.index
      return this.navigation.state.routes[index]
    },
    groups () {
      return Object.values(store.state.groups.groups).filter(function(g){
        return (g && (g.category != 'conversation'))
      })
    },
    conversations () {
      return Object.values(store.state.groups.groups).filter(function(g){
        return (g && (g.category == 'conversation'))
      }).sort(function(a, b){
        return a.timestamp - b.timestamp
      })
    }
  },
  watch: {
    token: function (val) {
      if(val){
        axios.defaults.headers.common['Authorization'] = this.token
        this.requestGroups()
        this.connectWebSocket()
      }else{
        delete axios.defaults.headers.common['Authorization']
        store.commit('groups/reset')
      }
    },

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
      this.navigation.navigate('Home');
    },
    showError (error) {
      Toast.show({
        text: error,
        buttonText: "Okay",
        type: "danger",
        position: "top"
      })
    },
    requestGroups () {
      var vm = this
      axios.get(xHTTPx + '/get_groups')
        .then(res => {
          var groups = res.data
          store.commit('groups/setGroups', groups)
        })
        .catch(function (error) {
          vm.showError('Failed to get groups!')
        })
    },
    openGroup (groupId) {
      this.navigation.navigate('Group', {groupId: groupId})
    },
    connectWebSocket () {
      store.commit('user/setWebSocket', 'Connecting...')
      var vm = this
      var url = xWEBSOCKETx + '/?token=' +this.token
      this.ws = new WebSocket(url)
      this.ws.onopen = function () {
        console.log('ws opened')
        vm.requestGroups()
        store.commit('user/setWebSocket', 'Connected')
        setTimeout(vm.keepWebSocketActive, 60000)
      }
      this.ws.onmessage = function (evt) {
        var msg = evt.data
        var obj = JSON.parse(msg)
        vm[obj[0]](obj[1])
      }
      this.ws.onclose = function () {
        console.log('ws closed')
        vm.ws = null
        if(vm.token){
          console.log('try to reconnect in 2 secs')
          setTimeout(vm.connectWebSocket, 2000)
        }
      }
    },
    keepWebSocketActive () {
      if(this.ws){
        this.ws.send('')
        setTimeout(this.keepWebSocketActive, 60000)
      }
    },
    pullGroup (groupId) {
      axios.get(xHTTPx + '/get_group/' + groupId)
        .then(res => {
          var group = res.data
          store.commit('groups/updateGroup', group)
        })
        .catch(function (error) {
          store.commit('groups/deleteGroup', groupId)
        })
    },
  },
  created () {
    if(this.token) {
      axios.defaults.headers.common['Authorization'] = this.token
      this.requestGroups()
      this.connectWebSocket()
    }
  }
};
</script>

<style>
.sidebar-content-wrapper {
  flex: 1;
  background-color: #fafafa;
}

.drawer-cover {
  flex: 1;
  align-self: stretch;
  position: relative;
  margin-bottom: 10;
}

.sidebar-icon {
  font-size: 26;
  width: 30;
}

.extra-icon {
  font-size: 22;
  margin-left: 15;
  margin-top: 3;
}

.second-level-nav {
  margin-left: 47;
  margin-top: -10;
}

.text-bold {
  font-weight: 700;
}

</style>



