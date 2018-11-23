<template>
  <nb-container>
    <nb-content class="sidebar-content-wrapper" :bounces="false">
      <image :source="drawerCover" class="drawer-cover" :style="stylesObj.drawerCoverObj"/>
      
      <nb-list v-if="token">
        <nb-list-item button noBorder>
          <nb-left>
            <nb-icon active name="person" class="sidebar-icon" />
            <nb-text>
              {{userFullName}}
            </nb-text>
          </nb-left>
        </nb-list-item>
        <nb-list-item button noBorder :onPress="signOut">
          <nb-left>
            <nb-text :style="{marginLeft: 30, marginTop: -10, marginBottom: 10}">
              Sign Out
            </nb-text>
          </nb-left>
        </nb-list-item>

        <nb-list-item button noBorder :selected="route.routeName == 'PublicGroups'" :onPress="() => navigation.navigate('PublicGroups')">
          <nb-left>
            <nb-icon active name="search" class="sidebar-icon" />
            <nb-text>Public Groups</nb-text>
          </nb-left>
        </nb-list-item>
        
      </nb-list>
    </nb-content>
  </nb-container>
</template>

<script>
import { Dimensions, Platform, Alert } from "react-native";
import drawerCover from "../../assets/drawer-cover.png";

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
      this.navigation.navigate('Home');
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

</style>



