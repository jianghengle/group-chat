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
      <label class="label">Name</label>
      <p class="control">
        <input class="input" :class="{'is-static': userRole=='member'}" :readonly="userRole=='member'" type="text" v-model="newName">
      </p>
      <p class="help is-danger" v-if="!newName.trim()">The name must not be empty!</p>
    </div>

    <div class="field">
      <label class="label">Category</label>
      <div class="control">
        <input class="input is-static" v-if="userRole=='member'" readonly type="text" v-model="newCategory">
        <div v-else class="select">
          <select v-model="newCategory">
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
        <textarea class="textarea" :readonly="userRole=='member'" placeholder="Description" v-model="newDescription"></textarea>
      </div>
    </div>
    <div class="field">
      <label class="label">Capacity</label>
      <p class="control">
        <input class="input" type="number" :class="{'is-static': userRole=='member'}" :readonly="userRole=='member'" v-model="newCapacity">
      </p>
    </div>
    <div class="field">
      <label class="label">Access</label>
      <div class="control">
        <input class="input is-static" v-if="userRole=='member'" readonly type="text" v-model="newAccess">
        <div v-else class="select">
          <select v-model="newAccess">
            <option>public</option>
            <option>private</option>
          </select>
        </div>
      </div>
    </div>
    <div class="field">
      <label class="label">Enroll</label>
      <div class="control">
        <input class="input is-static" v-if="userRole=='member'" readonly type="text" v-model="newEnroll">
        <div v-else class="select">
          <select v-model="newEnroll">
            <option>open</option>
            <option>request</option>
            <option>closed</option>
          </select>
        </div>
      </div>
    </div>

    <div class="field is-grouped" v-if="userRole != 'member'">
      <div class="control">
        <button class="button is-link" :disabled="!profileChanged || !newProfile" @click="updateProfile">Update</button>
      </div>
      <div class="control" v-if="userRole == 'owner'">
        <button class="button is-danger" :disabled="profileChanged" @click="deleteGroup">Delete</button>
      </div>
      <div class="control">
        <button class="button is-text" @click="loadGroup">Cancel</button>
      </div>
    </div>

  </div>
</template>

<script>

export default {
  name: 'group-profile',
  props: ['group'],
  data () {
    return {
      waiting: false,
      error: '',
      newName: '',
      newCategory: '',
      newDescription: '',
      newCapacity: null,
      newAccess: '',
      newEnroll: ''
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    userRole () {
      if(!this.group)
        return 'member'
      if(this.userId == this.group.ownerId){
        return 'owner'
      }
      for(var j=0;j<this.group.involved.length;j++){
        var m = this.group.involved[j]
        if(m.userId == this.userId && m.role != 'member'){
          return 'admin'
        }
      }
      return 'member'
    },
    profileChanged () {
      if(!this.group)
        return false
      return ((this.newName != this.group.name)
        || (this.newCategory != this.group.category)
        || (this.newDescription != this.group.description)
        || (this.newCapacity != this.group.capacity)
        || (this.newAccess != this.group.access)
        || (this.newEnroll != this.group.enroll)
      )
    },
    newProfile () {
      if(!this.newName.trim())
        return null
      return {
        name: this.newName.trim(),
        category: this.newCategory,
        description: this.newDescription,
        capacity: this.newCapacity,
        access: this.newAccess,
        enroll: this.newEnroll
      }
    }
  },
  watch: {
    group: function (val) {
      this.loadGroup()
    }
  },
  methods: {
    loadGroup () {
      if(!this.group)
        return
      this.newName = this.group.name
      this.newCategory = this.group.category
      this.newDescription = this.group.description
      this.newCapacity = this.group.capacity
      this.newAccess = this.group.access
      this.newEnroll = this.group.enroll
    },
    updateProfile () {
      if(!this.newProfile)
        return
      this.$http.post(xHTTPx + '/update_group/' + this.group.id, this.newProfile).then(response => {
        this.waiting= false
        this.error = ''
        this.$store.commit('groups/updateGroup', response.body)
      }, response => {
        this.error = 'Failed to update!'
        this.waiting= false
      })
    },
    deleteGroup () {
      if(this.userRole != 'owner')
        return
      this.$store.commit('modals/openConfirmModal', {
        title: 'Delete Group',
        message: 'Are you sure to delete this group: ' + this.group.name,
        button: 'Yes, I am sure!',
        callback: {
          method: this.deleteGroupConfirmed,
          context: this,
          args: []
        }
      })
    },
    deleteGroupConfirmed () {
      this.$http.post(xHTTPx + '/delete_group/' + this.group.id).then(response => {
        this.$store.commit('groups/deleteGroup', this.group.id)
        this.$router.push('/groups')
      }, response => {
        this.error = 'Failed to delete group!'
      })
    },
  },
  mounted () {
    this.loadGroup()
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

</style>
