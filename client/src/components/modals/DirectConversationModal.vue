<template>
  <div class="modal"
      :class="{'is-active': opened}">
    <div class="modal-background"></div>
    <div class="modal-card">
      <header class="modal-card-head">
        <p class="modal-card-title">Direct Conversation</p>
        <button class="delete" @click="close"></button>
      </header>
      <section class="modal-card-body">
        <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
        </div>
        <div>Do you want to start direct conversation with {{user.fullName}}?</div>
      </section>
      <footer class="modal-card-foot">
        <a class="button is-danger" :class="{'is-loading': waiting}" @click="confirm">Yes</a>
        <a class="button" @click="close">Cancel</a>
      </footer>
    </div>
  </div>
</template>

<script>
export default {
  name: 'direct-conversation-modal',
  data () {
    return {
      error: '',
      waiting: false,
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.directConversationModal.opened
    },
    user () {
      return this.$store.state.modals.directConversationModal.user
    }
  },
  methods: {
    close(){
      this.$store.commit('modals/closeDirectConversationModal')
    },
    confirm(){
      this.$http.post(xHTTPx + '/start_conversation', {userId: this.user.id}).then(response => {
        var group = response.body
        this.$store.commit('groups/updateGroup', group)
        this.$router.push('/group/' + group.id)
        this.waiting= false
        this.error = ''
        this.close()
      }, response => {
        this.error = 'Failed to start conversation!'
        this.waiting= false
      })
    }
  },
}
</script>

<style lang="scss" scoped>

</style>