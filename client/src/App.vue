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
    <upload-file-modal></upload-file-modal>
  </div>
</template>

<script>
import Vue from 'vue'
import DateForm from 'dateformat'
import MyHeader from './components/MyHeader'
import SignIn from './components/SignIn'
import MySidebar from './components/MySidebar'
import AddChildModal from './components/modals/AddChildModal'
import ConfirmModal from './components/modals/ConfirmModal'
import AddGroupModal from './components/modals/AddGroupModal'
import UploadFileModal from './components/modals/UploadFileModal'

export default {
  name: 'App',
  components: {
    MyHeader,
    SignIn,
    MySidebar,
    AddChildModal,
    ConfirmModal,
    AddGroupModal,
    UploadFileModal
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
    },
    token: function(val) {
      if(!val && this.ws){
        this.ws.close()
      }
    },

  },
  methods: {
    handleResize () {
      this.windowWidth = window.innerWidth
    },
    initApp () {
      this.$nextTick(function(){
        this.requestChildren()
        this.requestGroups()
        this.connectWebSocket()
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
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var groups = {}
        resp[0].forEach(function(g){
          g.owner = userMap[g.ownerId]
          g.involved = []
          g.chats = null
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
    },
    connectWebSocket () {
      var vm = this
      var url = xWEBSOCKETx + '/?token=' +this.token
      this.ws = new WebSocket(url)
      this.ws.onopen = function () {
        console.log('ws opened')
      }
      this.ws.onmessage = function (evt) {
        var msg = evt.data
        var obj = JSON.parse(msg)
        console.log('ws msg', obj)
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
    pullChild (childId) {
      this.$http.get(xHTTPx + '/guardian_get_child/' + childId).then(response => {
        var resp = response.body
        var child = null
        var vm = this
        resp[2].forEach(function(g){
          if(g.parentId == vm.userId) {
            child = g
            child.child = resp[0]
          }
        })
        this.$store.commit('children/updateChild', child)
      }, response => {
        this.$store.commit('children/deleteChild', childId)
      })
    },
    pullGroup (groupId) {
      this.$http.get(xHTTPx + '/get_group/' + groupId).then(response => {
        var resp = response.body
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var g = resp[0]
        g.owner = userMap[g.ownerId]
        g.involved = []
        resp[1].forEach(function(m){
          if(m.groupId == g.id){
            m.user = userMap[m.userId]
            g.involved.push(m)
          }
        })
        this.$store.commit('groups/updateGroup', g)
      }, response => {
        this.$store.commit('groups/deleteGroup', groupId)
      })
    },
    pullChat (chatId) {
      this.$http.get(xHTTPx + '/get_group_chat/' + chatId).then(response => {
        var resp = response.body
        var c = resp[0]
        c.user = resp[1]
        var d = new Date(c.timestamp)
        c.timeLabel = DateForm(d, 'h:MM TT mmm d')
        if(c.attachmentKey && c.filename){
          c.downloadLink = xHTTPx + /download_attachment/ + c.attachmentKey
          var ext = c.filename.includes('.') ? c.filename.split('.').pop().toLowerCase() : ''
          var imageExts = ['png', 'jpg', 'jpeg', 'gif', 'bmp']
          var videoExts = ['mp4', 'webm', 'ogg']
          if(imageExts.includes(ext)){
            c.fileType = 'image'
          }else if(videoExts.includes(ext)){
            c.fileType = 'video'
          }else{
            c.fileType = 'other'
          }
        }
        this.$store.commit('groups/pushGroupChat',  {groupId: c.groupId, chat: c})
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
  padding-top: 20px;
  padding-left: 20px;
  padding-right: 20px;
  padding-bottom: 200px;
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
