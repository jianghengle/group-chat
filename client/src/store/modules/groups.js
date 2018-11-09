import Vue from 'vue'

// initial state
export const state = {
  groups: {},
}

// mutations
export const mutations = {

  setGroups (state, groups) {
    state.groups = groups
  },

  addGroup (state, group) {
    Vue.set(state.groups, group.id, group)
  },

  updateGroup (state, group) {
    var g = state.groups[group.id]
    g.name = group.name
    g.category = group.category
    g.description = group.description
    g.capacity = group.capacity
    g.access = group.access
    g.enroll = group.enroll
  },

  deleteGroup (state, groupId) {
    state.groups[groupId] = null
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
