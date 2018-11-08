// initial state
export const state = {
  children: [],
}

// mutations
export const mutations = {

  setChildren (state, children) {
    state.children = children
  },
}

export default {
  namespaced: true,
  state,
  mutations
}
