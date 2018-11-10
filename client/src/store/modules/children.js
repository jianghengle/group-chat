import Vue from 'vue'

// initial state
export const state = {
  children: {},
}

// mutations
export const mutations = {

  setChildren (state, children) {
    var map = {}
    children.forEach(function(c){
      map[c.childId] = c
    })
    state.children = map
  },

  updateChild (state, child) {
    if(state.children[child.childId]){
      state.children[child.childId] = child
    }else{
      Vue.set(state.children, child.childId, child)
    }
  },

  deleteChild (state, childId) {
    state.children[childId] = null
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
