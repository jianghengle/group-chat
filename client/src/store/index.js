import Vue from 'vue'
import Vuex from 'vuex'
import user from './modules/user'
import modals from './modules/modals'
import ui from './modules/ui'
import groups from './modules/groups'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    user: user,
    modals: modals,
    ui: ui,
    groups: groups
  }
})
