import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import children from './modules/children'
import modals from './modules/modals'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    user: user,
    children: children,
    modals: modals
  }
})
