<template>
  <div class="container sign-in-container">
    <div class="welcome">
      Welcome! Please sign in to use the app.
    </div>

    <div class="field">
      <p class="control has-icons-left">
        <input class="input login-text" type="text" placeholder="Email" v-model="email" @keyup.enter="login">
        <span class="icon is-small is-left">
          <v-icon name="envelope"></v-icon>
        </span>
      </p>
    </div>

    <div class="field">
      <p class="control has-icons-left">
        <input class="input login-text" type="password" placeholder="Password" v-model="password" @keyup.enter="login">
        <span class="icon is-small is-left">
          <v-icon name="key"></v-icon>
        </span>
      </p>
    </div>

    <div class="field">
      <p class="control">
        <label class="checkbox">
          <input type="checkbox" v-model="rememberMe">
          Remember me
        </label>
      </p>
    </div>

    <div v-if="error" class="notification is-danger login-text">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="field">
      <p class="control">
        <button class="button is-link" :class="{'is-loading': waiting}" @click="login">Sign In</button>
      </p>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'sign-in',
  data () {
    return {
      email: '',
      password: '',
      rememberMe: false,
      error: '',
      waiting: false
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    }
  },
  methods: {
    login () {
      this.email = this.email.trim().toLowerCase()
      var message = {email: this.email, password: this.password}
      this.$http.post(xHTTPx + '/get_auth_token', message).then(response => {
        var resp = response.body
        var token = resp.token
        var email = resp.email
        var firstName = resp.firstName
        Vue.http.headers.common['Authorization'] = token
        this.$store.commit('user/setToken', token)
        this.$store.commit('user/setEmail', email)
        this.$store.commit('user/setFirstName', firstName)
        if (this.rememberMe) {
          localStorage.setItem('token', token)
          localStorage.setItem('email', email)
          localStorage.setItem('firstName', firstName)
        }
      }, response => {
        this.error = 'Failed to authorize user!'
        this.$store.commit('user/reset')
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.sign-in-container {
  padding-top: 40px;
  padding-left: 10px;
  padding-right: 10px; 
}

.welcome {
  margin-bottom: 10px;
}

</style>
