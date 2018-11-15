// initial state
export const state = {
  email: localStorage.getItem('email'),
  token: localStorage.getItem('token'),
  fullName: localStorage.getItem('fullName'),
  userId: localStorage.getItem('userId')
}

// mutations
export const mutations = {

  setEmail (state, email) {
    state.email = email
  },

  setToken (state, token) {
    state.token = token
  },

  setFullName (state, fullName) {
    state.fullName = fullName
  },

  setUserId (state, userId) {
    state.userId = userId
  },

  reset (state) {
    state.email = null
    state.token = null
    state.fullName = null
    state.userId = null
    localStorage.removeItem('email')
    localStorage.removeItem('token')
    localStorage.removeItem('fullName')
    localStorage.removeItem('userId')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
