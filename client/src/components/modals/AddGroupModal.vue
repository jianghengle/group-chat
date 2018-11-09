<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Add Activity</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Name</label>
            <p class="control">
              <input v-if="opened" class="input" type="text" v-model="name">
            </p>
          </div>
          <div class="field">
            <label class="label">Category</label>
            <div class="control">
              <div class="select">
                <select v-model="category">
                  <option>Program</option>
                  <option>Class</option>
                  <option>Club</option>
                  <option>Campus</option>
                  <option>Event</option>
                  <option>Discussion</option>
                </select>
              </div>
            </div>
          </div>
          <div class="field">
            <label class="label">Description</label>
            <div class="control">
              <textarea class="textarea" placeholder="Description" v-model="description"></textarea>
            </div>
          </div>
          <div class="field">
            <label class="label">Capacity</label>
            <p class="control">
              <input v-if="opened" class="input" type="number" v-model="capacity">
            </p>
          </div>
          <div class="field">
            <label class="label">Access</label>
            <div class="control">
              <div class="select">
                <select v-model="access">
                  <option>public</option>
                  <option>private</option>
                </select>
              </div>
            </div>
          </div>
          <div class="field">
            <label class="label">Enroll</label>
            <div class="control">
              <div class="select">
                <select v-model="enroll">
                  <option>open</option>
                  <option>request</option>
                  <option>closed</option>
                </select>
              </div>
            </div>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-link" :class="{'is-loading': waiting}" :disabled="!name.trim()" @click="addGroup">Add Activity</a>
          <a class="button" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>

export default {
  name: 'add-group-modal',
  data () {
    return {
      error: '',
      waiting: false,
      name: '',
      category: 'Class',
      description: '',
      capacity: null,
      access: 'public',
      enroll: 'open'
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.addGroupModal.opened
    }
  },
  watch: {
    opened: function (val) {
      if(val){
        this.name = ''
        this.category = 'Class'
        this.description = ''
        this.capacity = null
        this.access = 'public'
        this.enroll = 'open'
      }
    },
  },
  methods: {
    close () {
      this.$store.commit('modals/closeAddGroupModal')
    },
    addGroup () {
      if(!this.name.trim()) return
      this.waiting = true
      var message = {name: this.name.trim(), category: this.category, description: this.description,
        capacity: this.capacity, access: this.access, enroll: this.enroll}
      this.$http.post(xHTTPx + '/add_group', message).then(response => {
        this.waiting= false
        var resp = response.body
        var group = resp[0]
        group.owner = resp[1]
        group.involved = []
        this.$store.commit('groups/addGroup', group) 
        if(this.$route.path != '/' && this.$route.path != '/groups'){
          this.$router.push('/groups')
        }
        this.close()
      }, response => {
        this.error = 'Failed to add group!'
        this.waiting= false
      })
    },
    
  }
}
</script>

<style lang="scss" scoped>


</style>