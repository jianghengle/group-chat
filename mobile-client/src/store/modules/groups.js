import Vue from "vue-native-core"

// initial state
export const state = {
  groups: {},
  chats: {},
  lastTimestamps: {},
  historyLoaded: {}
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

  pushGroupChats (state, obj) {
    var groupId = obj.groupId
    var chats = obj.chats
    if(state.chats[groupId]){
      var existing = state.chats[groupId]
      if(existing.length){
        var latest = existing[0]
        var newChats = []
        for(var i=0;i<chats.length;i++){
          var chat = chats[i]
          if(chat.timestamp <= latest.timestamp){
            break
          }
          newChats.push(chat)
        }
        state.chats[groupId] = newChats.concat(existing)
      }else{
        state.chats[groupId] = chats
      }
    }else{
      Vue.set(state.chats, groupId, chats)
    }
  },

  prependGroupChats (state, obj) {
    var groupId = obj.groupId
    var chats = obj.chats
    var existing = state.chats[groupId]
    if(existing.length){
      var oldest = existing[existing.length - 1]
      var oldChats = []
      for(var i=chats.length-1;i>=0;i--){
        var chat = chats[i]
        if(chat.timestamp >= oldest.timestamp){
          break
        }
        oldChats.unshift(chat)
      }
      state.chats[groupId] = existing.concat(oldChats)
    }else{
      state.chats[groupId] = chats
    }
  },

  setLastTimestamp (state, obj) {
    var groupId = obj.groupId
    var timestamp = obj.timestamp
    if(!timestamp){
      timestamp = state.groups[groupId].userTimestamp
    }
    if(state.lastTimestamps[groupId] == undefined){
      Vue.set(state.lastTimestamps, groupId, timestamp)
    }else{
      state.lastTimestamps[groupId] = timestamp
    }
  },

  setHistoryLoaded (state, groupId) {
    Vue.set(state.historyLoaded, groupId, true)
  },

  reset (state) {
    state.groups = {}
    state.chats = {}
    state.lastTimestamps = {}
    state.historyLoaded = {}
  }
}

export default {
  namespaced: true,
  state,
  mutations
}
