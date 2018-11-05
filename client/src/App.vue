<template>
  <div id="app">
    <my-header :show-sidebar="showSidebar" @toggle-sidebar="toggleSidebar"></my-header>
    <div v-if="token">
      <div class="sidebar-container" v-show="showSidebar" :style="{'width': sidebarContainerWidth+'px', 'padding-left': sidePadding+'px'}">
        <div class="my-sidebar">
          sidebar
        </div>
      </div>
      <div class="main-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px', 'padding-right': sidePadding+'px', 'padding-left': showSidebar ? '0px' : sidePadding+'px'}">
        <router-view></router-view>
      </div>
    </div>
    <div v-else>
      <sign-in></sign-in>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import MyHeader from './components/MyHeader'
import SignIn from './components/SignIn'

export default {
  name: 'App',
  components: {
    MyHeader,
    SignIn
  },
  data () {
    return {
      windowWidth: 0,
      maxWidth: 1500,
      sidebarWidth: 300,
      showSidebar: true,
      mobileWidth: 768
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
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
    }
  },
  methods: {
    handleResize () {
      this.windowWidth = window.innerWidth
    },
    toggleSidebar () {
      this.showSidebar = !this.showSidebar
    }
  },
  mounted () {
    this.windowWidth = window.innerWidth
    if(this.windowWidth < this.mobileWidth)
      this.showSidebar = false
    window.addEventListener('resize', this.handleResize)
    if(this.token){
      Vue.http.headers.common['Authorization'] = this.token
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
  background-color: #f5f7f9;
}

.main-container {
  position: fixed;
  top: 52px;
  right: 0px;
  height: 100%;
  overflow: auto;
  min-width: 300px;
}
</style>
