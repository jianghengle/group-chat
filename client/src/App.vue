<template>
  <div id="app">
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
      <sign-in @user-signed-in="userSignedIn"></sign-in>
    </div>

    <confirm-modal></confirm-modal>
    <upload-file-modal></upload-file-modal>
    <image-modal></image-modal>
  </div>
</template>

<script>
import Vue from 'vue'
import DateForm from 'dateformat'
import SignIn from './components/SignIn'
import MySidebar from './components/MySidebar'
import ConfirmModal from './components/modals/ConfirmModal'
import UploadFileModal from './components/modals/UploadFileModal'
import ImageModal from './components/modals/ImageModal'

export default {
  name: 'App',
  components: {
    SignIn,
    MySidebar,
    ConfirmModal,
    UploadFileModal,
    ImageModal
  },
  data () {
    return {
      windowWidth: 0,
      maxWidth: 1500,
      sidebarWidth: 280,
      mobileWidth: 768,
      ws: null,
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    userId () {
      return this.$store.state.user.userId
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
    },
    routePath () {
      return this.$route.path
    },
  },
  watch: {
    isMobile: function (val) {
      this.$store.commit('ui/setIsMobile', val)
    },
    mainContainerLeft: function (val) {
      this.$store.commit('ui/setMainContainerLeft', val)
    },
    mainContainerWidth: function (val) {
      this.$store.commit('ui/setMainContainerWidth', val)
    },
    mainContainerInnerWidth: function (val) {
      this.$store.commit('ui/setMainContainerInnerWidth', val)
    },
    token: function (val) {
      if(!val && this.ws){
        this.ws.close()
      }
    },
    routePath: function (val) {
      if (val == '/add_group') {
        this.requestGroups()
      }
    }
  },
  methods: {
    openSidebar () {
      this.$store.commit('ui/setShowSidebar', true)
    },
    handleResize () {
      this.windowWidth = window.innerWidth
    },
    userSignedIn () {
      this.$nextTick(function(){
        this.requestGroups()
        this.connectWebSocket()
      })
    },
    requestGroups () {
      this.$http.get(xHTTPx + '/get_groups').then(response => {
        var groups = response.body
        this.$store.commit('groups/setGroups', groups)
      }, response => {
        this.error = 'Failed to get groups!'
      })
    },
    connectWebSocket () {
      this.$store.commit('user/setWebSocket', 'Connecting...')
      var vm = this
      var url = xWEBSOCKETx + '/?token=' +this.token
      this.ws = new WebSocket(url)
      this.ws.onopen = function () {
        console.log('ws opened')
        vm.requestGroups()
        vm.$store.commit('user/setWebSocket', 'Connected')
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
          setTimeout(vm.connectWebSocket(), 2000)
        }
      }
    },
    pullGroup (groupId) {
      this.$http.get(xHTTPx + '/get_group/' + groupId).then(response => {
        var group = response.body
        this.$store.commit('groups/updateGroup', group)
      }, response => {
        if(this.routePath == '/group/' + groupId){
          this.$router.push('/')
        }
        this.$store.commit('groups/deleteGroup', groupId)
      })
    },
  },
  mounted () {
    this.windowWidth = window.innerWidth
    if(this.windowWidth < this.mobileWidth){
      this.$store.commit('ui/setShowSidebar', false)
    }
    this.$nextTick(function(){
      this.$store.commit('ui/setIsMobile', this.isMobile)
      this.$store.commit('ui/setMainContainerInnerWidth', this.mainContainerInnerWidth)
      this.$store.commit('ui/setMainContainerLeft', this.mainContainerLeft)
    })
    window.addEventListener('resize', this.handleResize)
    if(this.token){
      Vue.http.headers.common['Authorization'] = this.token
      this.requestGroups()
      this.connectWebSocket()
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
  top: 0px;
  height: 100%;
  overflow: auto;
  background-color: #f5f5f5;
}

.main-container {
  position: fixed;
  top: 0px;
  right: 0px;
  height: 100%;
  overflow: auto;
  min-width: 300px;
}

.main-view {

}

.my-sidebar {
  padding-top: 5px;
  padding-left: 20px;
  padding-bottom: 20px;
}

.clickable {
  cursor: pointer;
}

.desktop-header {
  height: 50px;
  padding-left: 10px;
  padding-right: 10px;
}

.mobile-header {
  height: 40px;
  padding-left: 10px;
  padding-right: 10px;
}

.common-header {
  position: fixed;
  top: 0px;
  background-color: white;
  z-index: 1;
  min-width: 300px;
  box-shadow: 0 2px 0 0 #f5f5f5;
}


</style>
