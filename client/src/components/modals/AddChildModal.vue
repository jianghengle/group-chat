<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Add Child</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">First Name</label>
            <p class="control">
              <input v-if="opened" class="input" type="text" v-model="firstName">
            </p>
          </div>
          <div class="field">
            <label class="label">Last Name</label>
            <p class="control">
              <input v-if="opened" class="input" type="text" v-model="lastName">
            </p>
          </div>
          <div class="field">
            <label class="label">Relation</label>
            <p class="control">
              <input v-if="opened" class="input" type="text" v-model="relation">
            </p>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-link" :class="{'is-loading': waiting}" :disabled="!firstName.trim()" @click="addChild">Add Child</a>
          <a class="button" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>

export default {
  name: 'add-child-modal',
  data () {
    return {
      error: '',
      waiting: false,
      firstName: '',
      lastName: '',
      relation: ''
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.addChildModal.opened
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.firstName = ''
        this.lastName = ''
        this.relation = ''
        this.error = ''
      }
    },
  },
  methods: {
    close () {
      this.$store.commit('modals/closeAddChildModal')
    },
    addChild () {
      if(!this.firstName.trim()) return
      this.waiting = true
      var message = {firstName: this.firstName.trim(), lastName: this.lastName, relation: this.relation}
      this.$http.post(xHTTPx + '/guardian_add_child', message).then(response => {
        this.waiting= false
        if(this.$route.path != '/' && this.$route.path != '/children'){
          this.$router.push('/children')
        }
        this.close()
      }, response => {
        this.error = 'Failed to add child!'
        this.waiting= false
      })
    }
  }
}
</script>

<style lang="scss" scoped>


</style>