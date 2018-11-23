import { AsyncStorage } from "react-native"

// initial state
export const state = {
  user: {
    id: null,
    email: null,
    token: null,
    fullName: null
  },
  webSocket: null
}


// mutations
export const mutations = {

  setUser (state, user) {
    state.user = user
    AsyncStorage.setItem('user', JSON.stringify(user))
  },

  reset (state) {
    var user = {
      id: null,
      email: null,
      token: null,
      fullName: null
    }
    state.user.id = null
    state.user.email = null
    state.user.token = null
    state.user.fullName = null
    state.webSocket = null
    AsyncStorage.removeItem('user')
  },

  setWebSocket (state, status) {
    state.webSocket = status
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
