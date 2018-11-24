<template>
  <nb-container>
    <nb-content class="sidebar-content-wrapper" :bounces="false">
      <image :source="drawerCover" class="drawer-cover" :style="stylesObj.drawerCoverObj"/>
      
      <nb-list v-if="token">
        <nb-list-item button noBorder :selected="route.routeName == 'User'" :onPress="() => navigation.navigate('User')">
          <nb-left>
            <nb-icon active name="person" class="sidebar-icon" />
            <nb-text>
              {{userFullName}}
            </nb-text>
            <nb-icon active name="exit" class="extra-icon" :style="{color: '#df2736'}" :onPress="signOut" />
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder :selected="route.routeName == 'PublicGroups'" :onPress="() => navigation.navigate('PublicGroups')">
          <nb-left>
            <nb-icon active name="search" class="sidebar-icon" />
            <nb-text>Public Groups</nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder :selected="route.routeName == 'AddGroup'" :onPress="() => navigation.navigate('AddGroup')">
          <nb-left>
            <nb-icon active name="people" class="sidebar-icon" />
            <nb-text>My Groups</nb-text>
            <nb-icon active name="add-circle" class="extra-icon" />
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder v-for="g in groups" :key="'nav-group-'+g.id"
          :selected="(route.routeName=='Group' || route.routeName=='GroupDetail') && route.params.groupId==g.id"
          class="second-level-nav" :onPress="() => openGroup(g.id)">
          <nb-left>
            <nb-text>
              {{g.name}}
            </nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder>
          <nb-left>
            <nb-icon active name="chatboxes" class="sidebar-icon" />
            <nb-text>Direct Messages</nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder v-for="g in conversations" :key="'nav-group-'+g.id"
          :selected="(route.routeName=='Group' || route.routeName=='GroupDetail') && route.params.groupId==g.id"
          class="second-level-nav" :onPress="() => openGroup(g.id)">
          <nb-left>
            <nb-text>
              {{g.name}}
            </nb-text>
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
    }
  },
  created () {
    if(this.token) {
      axios.defaults.headers.common['Authorization'] = this.token
      this.requestGroups()
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
  font-size: 20;
  margin-left: 10;
  margin-top: 4;
}

.second-level-nav {
  margin-left: 47;
  margin-top: -10;
}

</style>



