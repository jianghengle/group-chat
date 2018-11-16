// initial state
export const state = {
  showSidebar: true,
  isMobile: false,
  mainContainerLeft: 0,
  mainContainerWidth: 0,
  mainContainerInnerWidth: 0
}

// mutations
export const mutations = {
  toggleSidebar (state) {
    state.showSidebar = !state.showSidebar
  },
  
  setShowSidebar (state, showSidebar) {
    state.showSidebar = showSidebar
  },

  setIsMobile (state, isMobile) {
    state.isMobile = isMobile
  },

  setMainContainerWidth (state, mainContainerWidth) {
    state.mainContainerWidth = mainContainerWidth
  },

  setMainContainerInnerWidth (state, mainContainerInnerWidth) {
    state.mainContainerInnerWidth = mainContainerInnerWidth
  },

  setMainContainerLeft (state, mainContainerLeft) {
    state.mainContainerLeft = mainContainerLeft
  },
}

export default {
  namespaced: true,
  state,
  mutations
}
