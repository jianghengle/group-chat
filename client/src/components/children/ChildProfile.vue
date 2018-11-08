<template>
  <div>

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
        
    <div class="field">
      <label class="label">First Name</label>
      <p class="control">
        <input class="input" type="text" v-model="newFirstName">
      </p>
      <p class="help is-danger" v-if="!newFirstName">The first name must not be empty!</p>
    </div>

    <div class="field">
      <label class="label">Last Name</label>
      <p class="control">
        <input class="input" type="text" v-model="newLastName">
      </p>
    </div>

    <div class="field">
      <label class="label">Relation to You</label>
      <p class="control">
        <input class="input" type="text" v-model="newRelation">
      </p>
    </div>

    <div class="field is-grouped">
      <div class="control">
        <button class="button is-link" :disabled="!profileChanged || !newProfile" @click="updateProfile">Update</button>
      </div>
      <div class="control" v-if="oldGuardian && oldGuardian.master">
        <button class="button is-danger" :disabled="profileChanged" @click="deleteChild">Delete</button>
      </div>
      <div class="control">
        <button class="button is-text" @click="loadChild">Cancel</button>
      </div>
    </div>

  </div>
</template>

<script>

export default {
  name: 'child-profile',
  props: ['child'],
  data () {
    return {
      waiting: false,
      error: '',
      newFirstName: '',
      newLastName: '',
      newRelation: '',
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    childId () {
      return this.$route.params.childId
    },
    oldGuardian () {
      if(!this.child.guardians)
        return null
      for(var i=0;i<this.child.guardians.length;i++){
        var guardian = this.child.guardians[i]
        if(guardian.parentId == this.userId){
          return guardian
        }
      }
      return null
    },
    profileChanged () {
      if(!this.oldGuardian)
        return false
      return ((this.newFirstName != this.child.firstName)
        || (this.newLastName != this.child.lastName)
        || (this.newRelation != this.oldGuardian.relation)
      )
    },
    newProfile () {
      if(!this.newFirstName.trim())
        return null
      return {
        firstName: this.newFirstName.trim(),
        lastName: this.newLastName,
        guardianId: this.oldGuardian.id,
        relation: this.newRelation
      }
    }
  },
  watch: {
    child: function (val) {
      this.loadChild()
    }
  },
  methods: {
    loadChild () {
      this.newFirstName = this.child.firstName
      this.newLastName = this.child.lastName
      this.newRelation = this.oldGuardian ? this.oldGuardian.relation : null
    },
    updateProfile () {
      if(!this.newProfile)
        return
      this.$http.post(xHTTPx + '/guardian_update_child/' + this.childId, this.newProfile).then(response => {
        this.waiting= false
        this.error = ''
        this.$emit('child-profile-updated')
      }, response => {
        this.error = 'Failed to update!'
        this.waiting= false
      })
    },
    deleteChild () {
      if(!this.oldGuardian || !this.oldGuardian.master)
        return
      this.$store.commit('modals/openConfirmModal', {
        title: 'Delete Child',
        message: 'Are you sure to delete this child: ' + this.child.firstName + ' ' + this.child.lastName,
        button: 'Yes, I am sure!',
        callback: {
          method: this.deleteChildConfirmed,
          context: this,
          args: []
        }
      })
    },
    deleteChildConfirmed () {
      var message = {guardianId: this.oldGuardian.id}
      this.$http.post(xHTTPx + '/guardian_delete_child/' + this.childId, message).then(response => {
        this.requestChildren()
        this.$router.push('/children')
      }, response => {
        this.error = 'Failed to delete children!'
      })
    },
    requestChildren () {
      this.$http.get(xHTTPx + '/guardian_get_children').then(response => {
        var resp = response.body
        var userMap = {}
        resp[0].forEach(function(u){
          userMap[u.id] = u
        })
        var children = resp[1].map(function(c){
          c.child = userMap[c.childId]
          return c
        })
        this.$store.commit('children/setChildren', children)
      })
    },
  },
  mounted () {
    this.loadChild()
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

</style>
