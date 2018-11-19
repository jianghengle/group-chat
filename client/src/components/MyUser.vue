<template>
  <div>
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
  },
  methods: {
    signOut () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
      this.$store.commit('groups/reset')
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
