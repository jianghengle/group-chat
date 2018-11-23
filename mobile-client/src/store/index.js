import Vue from "vue-native-core"
import Vuex from 'vuex'
import user from './modules/user'
import groups from './modules/groups'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    user: user,
    groups: groups
  }
})
