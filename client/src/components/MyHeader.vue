<template>
  <div>
    <nav class="navbar has-shadow is-fixed-top">
      <div class="container">
        <div class="navbar-brand">
          <a class="navbar-item is-size-4 has-text-weight-bold has-text-black" @click="toggleSidebar">
            GROUP CHAT &nbsp;
            <span v-if="token" class="icon" :class="{'has-text-grey': !showSidebar, 'has-text-grey-dark': showSidebar}">
              <v-icon name="columns"/>
            </span>
          </a>
          <div class="navbar-burger burger app-burger" :class="{'is-active': menuActive}"
            @click="menuActive = !menuActive">
            <span></span>
            <span></span>
            <span></span>
          </div>
        </div>
        <div class="navbar-menu" v-if="token" :class="{'is-active': menuActive}">
          <div class="navbar-start">
            
          </div>
          <div class="navbar-end">
            <a class="navbar-item">
              <span class="icon">
                <v-icon name="user"/>
              </span>
              {{firstName}}
            </a>
            <a class="navbar-item" @click="signOut">
              <span class="icon">
                <v-icon name="sign-out-alt"/>
              </span>
              Sign Out
            </a>
          </div>
        </div>
      </div>
    </nav>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'my-header',
  data () {
    return {
      menuActive: false
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    firstName () {
      return this.$store.state.user.firstName
    },
    showSidebar () {
      return this.$store.state.ui.showSidebar
    },
  },
  methods: {
    toggleSidebar () {
      this.$store.commit('ui/toggleSidebar')
    },
    signOut () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

</style>
