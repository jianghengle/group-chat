<template>
  <div class="outer">
    <div class="middle">
      <div class="inner container">
        <div class="welcome">
          <p class="title is-3">Group Chat</p>
          <p class="subtitle is-6">My hobby chat app like <em>Slack</em></p>
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
    </div>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'sign-in',
  data () {
    return {
      email: 'john.smith@guest.com',
      password: '123456',
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
      if(this.waiting)
        return
      this.email = this.email.trim().toLowerCase()
      var message = {email: this.email, password: this.password}
      this.$http.post(xHTTPx + '/get_auth_token', message).then(response => {
        var resp = response.body
        var token = resp.token
        var email = resp.email
        var fullName = resp.fullName
        var userId = resp.id
        Vue.http.headers.common['Authorization'] = token
        this.$store.commit('user/setToken', token)
        this.$store.commit('user/setEmail', email)
        this.$store.commit('user/setFullName', fullName)
        this.$store.commit('user/setUserId', userId)
        if (this.rememberMe) {
          localStorage.setItem('token', token)
          localStorage.setItem('email', email)
          localStorage.setItem('fullName', fullName)
          localStorage.setItem('userId', userId)
        }
        this.$emit('user-signed-in')
      }, response => {
        this.error = 'Failed to authorize user!'
        this.$store.commit('user/reset')
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.outer {
  position: absolute;
  height: 100%;
  width: 100%;
}

.middle {
  position: relative;
  top: 20%;
}

.inner {
  max-width: 600px;
  padding: 10px;
}

.welcome {
  margin-bottom: 20px;
}

.contact-icons {
  float: right;
}

</style>
