<template>
  <div id="app">
    <my-header></my-header>
    <div v-if="token">
      <div class="sidebar-container" v-show="showSidebar" :style="{'width': sidebarContainerWidth+'px', 'padding-left': sidePadding+'px'}">
        <div class="my-sidebar">
          <my-sidebar></my-sidebar>
        </div>
      </div>
      <div class="main-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px', 'padding-right': sidePadding+'px', 'padding-left': showSidebar ? '0px' : sidePadding+'px'}">
        <div class="main-view">
          <router-view></router-view>
        </div>
      </div>
    </div>
    <div v-else>
      <sign-in @user-signed-in="initApp"></sign-in>
    </div>

    <add-child-modal></add-child-modal>
    <confirm-modal></confirm-modal>
    <add-group-modal></add-group-modal>
  </div>
</template>

<script>
import Vue from 'vue'
import MyHeader from './components/MyHeader'
import SignIn from './components/SignIn'
import MySidebar from './components/MySidebar'
import AddChildModal from './components/modals/AddChildModal'
import ConfirmModal from './components/modals/ConfirmModal'
import AddGroupModal from './components/modals/AddGroupModal'

export default {
  name: 'App',
  components: {
    MyHeader,
    SignIn,
    MySidebar,
    AddChildModal,
    ConfirmModal,
    AddGroupModal
  },
  data () {
    return {
      windowWidth: 0,
      maxWidth: 1500,
      sidebarWidth: 280,
      mobileWidth: 768
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    showSidebar () {
      return this.$store.state.ui.showSidebar
    },
    isMobile () {
      return this.windowWidth < this.mobileWidth
    },
    sidePadding () {
      if(this.windowWidth < this.maxWidth)
        return 0
      return (this.windowWidth - this.maxWidth) / 2
    },
    sidebarContainerWidth () {
      return this.sidePadding + this.sidebarWidth
    },
    mainContainerLeft () {
      if(this.showSidebar){
        return this.sidebarContainerWidth
      }
      return 0
    },
    mainContainerWidth () {
      if(this.showSidebar){
        return this.windowWidth - this.sidebarContainerWidth
      }
      return this.windowWidth
    },
    mainContainerInnerWidth () {
      var paddingRight = this.sidePadding
      var paddingLeft = this.showSidebar ? 0 : this.sidePadding
      return this.mainContainerWidth - paddingRight - paddingLeft
    }
  },
  watch: {
    isMobile: function (val) {
      this.$store.commit('ui/setIsMobile', val)
    },
    mainContainerLeft: function (val) {
      this.$store.commit('ui/setMainContainerLeft', val)
    },
    mainContainerInnerWidth: function (val) {
      this.$store.commit('ui/setMainContainerInnerWidth', val)
    }
  },
  methods: {
    handleResize () {
      this.windowWidth = window.innerWidth
    },
    initApp () {
      this.$nextTick(function(){
        this.requestChildren()
        this.requestGroups()
      })
    },
    requestChildren () {
      this.$http.get(xHTTPx + '/guardian_get_children').then(response => {
        var resp = response.body
        var userMap = {}
        resp[0].forEach(function(u){
          userMap[u.id] = u
        })
        var children = resp[1].map(function(c){
          c.child = userMap[c.childId]
          return c
        })
        this.$store.commit('children/setChildren', children)
      }, response => {
        this.error = 'Failed to get children!'
      })
    },
    requestGroups () {
      this.$http.get(xHTTPx + '/get_groups').then(response => {
        var resp = response.body
        console.log(resp)
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var groups = {}
        resp[0].forEach(function(g){
          g.owner = userMap[g.ownerId]
          g.involved = []
          groups[g.id] = g
        })
        resp[1].forEach(function(m){
          var g = groups[m.groupId]
          m.user = userMap[m.userId]
          g.involved.push(m)
        })
        this.$store.commit('groups/setGroups', groups)
      }, response => {
        this.error = 'Failed to get groups!'
      })
    }
  },
  mounted () {
    this.windowWidth = window.innerWidth
    if(this.windowWidth < this.mobileWidth){
      this.$store.commit('ui/setShowSidebar', false)
    }
    this.$nextTick(function(){
      this.$store.commit('ui/setIsMobile', this.isMobile)
      this.$store.commit('ui/setMainContainerInnerWidth', this.mainContainerWidth)
      this.$store.commit('ui/setMainContainerLeft', this.mainContainerLeft)
    })
    window.addEventListener('resize', this.handleResize)
    if(this.token){
      Vue.http.headers.common['Authorization'] = this.token
      this.initApp()
    }
  },
  beforeDestroy () {
    window.removeEventListener('resize', this.handleResize)
  }
}
</script>

<style lang="scss">
@import "~bulma/sass/utilities/initial-variables";

@import "~bulma";

.sidebar-container {
  position: fixed;
  top: 52px;
  height: 100%;
  overflow: auto;
  background-color: #f5f5f5;
}

.main-container {
  position: fixed;
  top: 52px;
  right: 0px;
  height: 100%;
  overflow: auto;
  min-width: 300px;
}

.main-view {
  padding: 20px;
}

.my-sidebar {
  padding-top: 20px;
  padding-left: 20px;
  padding-bottom: 20px;
}

.clickable {
  cursor: pointer;
}
</style>
