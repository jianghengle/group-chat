// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'
import VueResource from 'vue-resource'
Vue.use(VueResource)

import 'vue-awesome/icons/sign-out-alt'
import 'vue-awesome/icons/user'
import 'vue-awesome/icons/chevron-left'
import 'vue-awesome/icons/chevron-right'
import 'vue-awesome/icons/columns'
import 'vue-awesome/icons/envelope'
import 'vue-awesome/icons/key'
import 'vue-awesome/icons/spinner'
import 'vue-awesome/icons/plus-circle'
import 'vue-awesome/icons/angle-down'
import 'vue-awesome/icons/arrow-alt-circle-up'
import 'vue-awesome/icons/arrow-alt-circle-down'
import 'vue-awesome/icons/minus-circle'
import 'vue-awesome/icons/plus'
import 'vue-awesome/icons/upload'
import 'vue-awesome/icons/search'
import 'vue-awesome/icons/users'
import 'vue-awesome/icons/users-cog'
import 'vue-awesome/icons/user-friends'
import 'vue-awesome/icons/comments'
import 'vue-awesome/icons/times'
import 'vue-awesome/icons/ellipsis-v'
import 'vue-awesome/icons/cog'
import Icon from 'vue-awesome/components/Icon'

Vue.component('v-icon', Icon)

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  components: { App },
  template: '<App/>'
})
