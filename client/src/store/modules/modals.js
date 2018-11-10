// initial state
export const state = {
  addChildModal: {opened: false},
  confirmModal: {
    opened: false,
    title: '',
    message: '',
    button: '',
    callback: null
  },
  addGroupModal: {opened: false},
  uploadFileModal: {opened: false, message: ''},
}

// mutations
export const mutations = {

  openAddChildModal (state) {
    state.addChildModal.opened = true
  },

  closeAddChildModal (state) {
    state.addChildModal.opened = false
  },

  openConfirmModal (state, confirm) {
    state.confirmModal.opened = true
    state.confirmModal.title = confirm.title
    state.confirmModal.message = confirm.message
    state.confirmModal.button = confirm.button
    state.confirmModal.callback = confirm.callback
  },

  closeConfirmModal (state) {
    state.confirmModal.opened = false
    state.confirmModal.title = ''
    state.confirmModal.message = ''
    state.confirmModal.button = ''
    state.confirmModal.callback = null
  },

  openAddGroupModal (state) {
    state.addGroupModal.opened = true
  },

  closeAddGroupModal (state) {
    state.addGroupModal.opened = false
  },

  openUploadFileModal (state, message) {
    state.uploadFileModal.message = message
    state.uploadFileModal.opened = true
  },

  closeUploadFileModal (state) {
    state.uploadFileModal.message = ''
    state.uploadFileModal.opened = false
  },
}

export default {
  namespaced: true,
  state,
  mutations
}
