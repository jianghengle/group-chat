<template>
  <div>
    <div class="common-header level is-mobile"
      :class="{'mobile-header': isMobile, 'desktop-header': !isMobile}"
      :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="level-left">
        <a class="level-item" :class="{'has-text-grey': showSidebar, 'has-text-grey-light': !showSidebar}"
          @click="toggleSidebar">
          <span class="icon">
            <v-icon name="ellipsis-v"/>
          </span>
        </a>
        <div class="has-text-weight-bold level-item" :class="{'is-size-4': !isMobile, 'is-size-5': isMobile}">
          User Profile
        </div>
      </div>
      <div class="level-right">
        <div class="level-item has-text-grey is-size-7" v-if="webSocket != 'Connected'">
          {{webSocket}}
        </div>
      </div>
    </div>

    <div :class="{'mobile-body': isMobile, 'desktop-body': !isMobile}">
      <div class="field">
        <label class="label">Email</label>
        <p class="control">
          <input class="input is-static" type="text" v-model="email">
        </p>
      </div>
      <div class="field">
        <label class="label">Full Name</label>
        <p class="control">
          <input class="input is-static" type="text" v-model="fullName">
        </p>
      </div>
      <div class="field is-grouped">
        <div class="control">
          <button class="button is-danger" @click="signOut">Sign Out</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'my-user',
  data () {
    return {
      msg: 'Hello world!'
    }
  },
  computed: {
    email () {
      return this.$store.state.user.email
    },
    fullName () {
      return this.$store.state.user.fullName
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
    showSidebar () {
      return this.$store.state.ui.showSidebar
    },
    webSocket () {
      return this.$store.state.user.webSocket
    }
  },
  methods: {
    signOut () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
    },
    toggleSidebar () {
      this.$store.commit('ui/toggleSidebar')
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.desktop-body {
  margin-top: 50px;
  padding: 20px;
}

.mobile-body {
  margin-top: 40px;
  padding: 10px;
}
</style>
