// initial state
export const state = {
  email: localStorage.getItem('email'),
  token: localStorage.getItem('token'),
  firstName: localStorage.getItem('firstName')
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

  reset (state) {
    state.email = null
    state.token = null
    state.firstName = null
    localStorage.removeItem('email')
    localStorage.removeItem('token')
    localStorage.removeItem('firstName')
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
