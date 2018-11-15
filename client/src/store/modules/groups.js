import Vue from 'vue'

// initial state
export const state = {
  groups: {},
}

// mutations
export const mutations = {

  setGroups (state, gs) {
    var groups = {}
    gs.forEach(function(g){
      groups[g.id] = g
    })
    state.groups = groups
  },

  updateGroup (state, g) {
    if(state.groups[g.id]){
      state.groups[g.id] = g
    }else{
      Vue.set(state.groups, g.id, g)
    }
  },

  deleteGroup (state, groupId) {
    state.groups[groupId] = null
  },

  setGroupChats (state, obj) {
    state.groups[obj.groupId].chats = obj.chats
  },

  pushGroupChat (state, obj) {
    state.groups[obj.groupId].chats.push(obj.chat)
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
