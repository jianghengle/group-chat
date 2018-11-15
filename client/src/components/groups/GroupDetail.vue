<template>
  <div :class="{'mobile-body': isMobile, 'desktop-body': !isMobile}">

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>

    <div v-else>
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div v-if="group">
        <div class="field">
          <label class="label">Name</label>
          <p class="control">
            <input class="input" :class="{'is-static': !isOwner}" :readonly="!isOwner" type="text" v-model="newName">
          </p>
        </div>

        <div class="field">
          <label class="label">Description</label>
          <div class="control">
            <textarea class="textarea" :readonly="!isOwner" placeholder="Description" v-model="newDescription"></textarea>
          </div>
        </div>
        
        <div class="field">
          <label class="label">Status</label>
          <div class="control">
            <input class="input is-static" v-if="!isOwner" readonly type="text" v-model="newStatus">
            <div v-else class="select">
              <select v-model="newStatus">
                <option>public</option>
                <option>private</option>
              </select>
            </div>
          </div>
        </div>

        <div class="field is-grouped" v-if="isOwner">
          <div class="control">
            <button class="button is-link" :class="{'is-loading': waiting}" :disabled="!profileChanged || !newProfile" @click="updateProfile">Update</button>
          </div>
          <div class="control">
            <button class="button is-danger" :class="{'is-loading': waiting}" :disabled="profileChanged" @click="deleteGroup">Delete</button>
          </div>
          <div class="control">
            <button class="button is-text" @click="loadGroup">Cancel</button>
          </div>
        </div>

        <br />
        <br />

        <div class="field">
          <label class="label">Members</label>
          <div class="control">
            <table class="table is-hoverable is-fullwidth">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Full Name</th>
                  <th>Role</th>
                  <th>Remove</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>1</td>
                  <td>{{group.owner.fullName}} <span v-if="group.ownerId == userId">(Me)</span></td>
                  <td>Owner</td>
                  <td></td>
                </tr>
                <tr v-for="(member, i) in group.members">
                  <td>{{i+2}}</td>
                  <td>{{member.fullName}} <span v-if="member.id == userId">(Me)</span></td>
                  <td>Member</td>
                  <td>
                    <span class="icon clickable" v-if="isOwner" @click="deleteMember(member)">
                      <v-icon name="times"></v-icon>
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="field is-grouped" v-if="!isOwner">
          <div class="control">
            <button class="button is-danger" :class="{'is-loading': waiting}" @click="quitGroup">Quit</button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>

export default {
  name: 'group-detail',
  data () {
    return {
      waiting: false,
      error: '',
      group: null,
      newName: '',
      newDescription: '',
      newStatus: ''
    }
  },
  computed: {
    groupId () {
      return this.$route.params.groupId
    },
    userId () {
      return this.$store.state.user.userId
    },
    isOwner () {
      if(!this.group)
        return false
      return this.userId == this.group.ownerId
    },
    profileChanged () {
      if(!this.group)
        return false
      return (this.newName != this.group.name)
        || (this.newDescription != this.group.description)
        || (this.newStatus != this.group.status)
    },
    newProfile () {
      if(!this.newName.trim())
        return null
      return {
        name: this.newName.trim(),
        description: this.newDescription,
        status: this.newStatus
      }
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
  },
  watch: {
    groupId: function (val) {
      this.requestGroup()
    }
  },
  methods: {
    loadGroup () {
      if(!this.group)
        return
      this.newName = this.group.name
      this.newDescription = this.group.description
      this.newStatus = this.group.status
    },
    updateProfile () {
      if(!this.newProfile)
        return
      this.$http.post(xHTTPx + '/update_group/' + this.groupId, this.newProfile).then(response => {
        var resp = response.body
        this.group.name = resp.name
        this.group.description = resp.description
        this.group.status = resp.status
        this.$store.commit('groups/updateGroup', resp)
        this.loadGroup()
        this.waiting= false
        this.error = ''
      }, response => {
        this.error = 'Failed to update!'
        this.waiting= false
      })
    },
    deleteGroup () {
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
      this.$http.post(xHTTPx + '/delete_group/' + this.groupId).then(response => {
        this.$store.commit('groups/deleteGroup', this.groupId)
        this.$router.push('/')
      }, response => {
        this.error = 'Failed to delete group!'
      })
    },
    deleteMember (m) {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Delete Group',
        message: 'Are you sure to remove this member: ' + m.fullName,
        button: 'Yes, I am sure!',
        callback: {
          method: this.deleteMemberConfirmed,
          context: this,
          args: [m]
        }
      })
    },
    deleteMemberConfirmed (m) {
      this.waiting = true
      var message = {userId: m.id}
      this.$http.post(xHTTPx + '/quit_group/' + this.groupId, message).then(response => {
        var index = this.group.members.indexOf(m)
        this.group.members.splice(index, 1)
        this.waiting = false
        this.error = ''
      }, response => {
        this.waiting = false
        this.error = 'Failed to delete member!'
      })
    },
    quitGroup () {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Quit Group',
        message: 'Are you sure to quit this group: ' + this.group.name,
        button: 'Yes, I am sure!',
        callback: {
          method: this.quitGroupConfirmed,
          context: this,
          args: []
        }
      })
    },
    quitGroupConfirmed () {
      this.waiting = true
      var message = {userId: this.userId}
      this.$http.post(xHTTPx + '/quit_group/' + this.groupId, message).then(response => {
        this.waiting = false
        this.error = ''
        this.$store.commit('groups/deleteGroup', this.groupId)
        this.$router.push('/')
      }, response => {
        this.waiting = false
        this.error = 'Failed to quit group!'
      })
    },
    requestGroup () {
      this.waiting= true
      this.$http.get(xHTTPx + '/get_group_detail/' + this.groupId).then(response => {
        var resp = response.body
        var group = resp[0]
        var members = []
        resp[1].forEach(function(u){
          if(u.id == group.ownerId){
            group.owner = u
          }else{
            members.push(u)
          }
        })
        group.members = members
        this.group = group
        this.loadGroup()
        this.waiting= false
        this.error = ''
      }, response => {
        this.error = 'Failed to get detail!'
        this.waiting= false
      })
    }
  },
  mounted () {
    this.requestGroup()
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.desktop-body {
  margin-top: 50px;
  padding: 20px;
  overflow: auto;
}

.mobile-body {
  margin-top: 40px;
  padding: 10px;
  overflow: auto;
}

</style>
