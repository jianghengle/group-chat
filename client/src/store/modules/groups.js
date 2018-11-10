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
    if(state.groups[group.id]){
      var g = state.groups[group.id]
      g.name = group.name
      g.category = group.category
      g.description = group.description
      g.capacity = group.capacity
      g.access = group.access
      g.enroll = group.enroll
      g.ownerId = group.ownerId
      g.owner = group.owner
      g.involved = group.involved
    }else{
      Vue.set(state.groups, group.id, group)
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
