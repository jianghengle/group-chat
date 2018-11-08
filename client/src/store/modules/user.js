// initial state
export const state = {
  email: localStorage.getItem('email'),
  token: localStorage.getItem('token'),
  firstName: localStorage.getItem('firstName'),
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

  setFirstName (state, firstName) {
    state.firstName = firstName
  },

  setUserId (state, userId) {
    state.userId = userId
  },

  reset (state) {
    state.email = null
    state.token = null
    state.firstName = null
    state.userId = null
    localStorage.removeItem('email')
    localStorage.removeItem('token')
    localStorage.removeItem('firstName')
    localStorage.removeItem('userId')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
