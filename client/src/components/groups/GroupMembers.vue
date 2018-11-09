<template>
  <div>

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
        
    <div v-if="owner">
      <div><strong>Activity Provider:</strong></div>
      <table class="table is-hoverable is-fullwidth">
        <tbody>
          <tr>
            <td>{{owner.firstName + ' ' + owner.lastName}} <span v-if="owner.id == userId">(Me)</span></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div>
      <div><strong>Members:</strong></div>
      <table class="table is-hoverable is-fullwidth">
        <thead>
          <tr>
            <th>#</th>
            <th>Member & Guardians</th>
            <th>Role</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(member, i) in allMembers">
            <td>{{i+1}}</td>
            <td>
              {{member.user.firstName + ' ' + member.user.lastName}} <span v-if="member.user.id == userId">(Me)</span>
              <span v-if="member.guardians">
                <span v-for="g in member.guardians">
                  <br/><small>{{g.firstName + '' + g.lastName}} ({{g.relation}}) <span v-if="g.id == userId">(Me)</span></small>
                </span>
              </span>
            </td>
            <td>{{member.role}}</td>
            <td>
              <span class="icon clickable" v-if="userRole=='owner' && member.role=='member' && !member.guardians" @click="updateRole(member, 'admin')">
                <v-icon name="arrow-alt-circle-up"></v-icon>
              </span>
              <span class="icon clickable" v-if="userRole=='owner' && member.role=='admin'" @click="updateRole(member, 'member')">
                <v-icon name="arrow-alt-circle-down"></v-icon>
              </span>
              <span class="icon clickable" v-if="userRole=='owner' || (userRole=='admin' && member.role=='member') || myEnrollments.includes(member)" @click="deleteMember(member)">
                <v-icon name="minus-circle"></v-icon>
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>

export default {
  name: 'group-members',
  props: ['group'],
  data () {
    return {
      waiting: false,
      error: '',
      owner: null,
      admins: [],
      members: []
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
    allMembers () {
      var admins = this.admins.slice().sort(this.compareNames)
      var members = this.members.slice().sort(this.compareNames)
      return admins.concat(members)
    },
    myEnrollments () {
      var vm = this
      return this.allMembers.filter(function(m){
        if(m.userId == vm.userId)
          return true
        if(m.guardians){
          for(var i=0;i<m.guardians.length;i++){
            if(m.guardians[i].id == vm.userId)
              return true
          }
        }
        return false
      })
    }
  },
  watch: {
    group: function (val) {
      this.requestGroupMembers()
    }
  },
  methods: {
    compareNames (a, b) {
      var aName = a.user.firstName + ' ' + a.user.lastName
      var bName = b.user.firstName + ' ' + b.user.lastName
      return aName.localeCompare(bName)
    },
    requestGroupMembers () {
      this.waiting= true
      this.$http.get(xHTTPx + '/get_group_members/' + this.group.id).then(response => {
        this.waiting= false
        var resp = response.body
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var guardianMap = {}
        resp[1].forEach(function(g){
          if(!guardianMap[g.childId]){
            guardianMap[g.childId] = []
          }
          var parent = JSON.parse(JSON.stringify(userMap[g.parentId]))
          parent.relation = g.relation
          guardianMap[g.childId].push(parent)
        })
        var admins = []
        var members = []
        resp[0].forEach(function(m){
          m.user = userMap[m.userId]
          m.guardians = guardianMap[m.userId]
          if(m.role == 'admin'){
            admins.push(m)
          }else{
            members.push(m)
          }
        })
        this.members = members
        this.admins = admins
        this.owner = userMap[this.group.ownerId]
        this.error = ''
      }, response => {
        this.$store.commit('groups/deleteGroup', this.group.id)
        this.$router.push('/groups')

        this.error = 'Failed to get members!'
        this.waiting= false
      })
    },
    updateRole (m, role) {
      this.$http.post(xHTTPx + '/update_group_membership/' + m.id, {role: role}).then(response => {
        this.waiting= false
        this.error = ''
        this.requestGroupMembers()
        this.requestGroups()
      }, response => {
        this.error = 'Failed to update!'
        this.waiting= false
      })
    },
    deleteMember (m) {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Delete Member',
        message: 'Are you sure to unenroll this member: ' + m.user.firstName + ' ' + m.user.lastName,
        button: 'Yes, I am sure!',
        callback: {
          method: this.deleteMemberConfirmed,
          context: this,
          args: [m]
        }
      })
    },
    deleteMemberConfirmed (m) {
      this.$http.post(xHTTPx + '/delete_group_membership/' + m.id).then(response => {
        this.waiting= false
        this.error = ''
        this.requestGroupMembers()
        this.requestGroups()
      }, response => {
        this.error = 'Failed to delete!'
        this.waiting= false
      })
    },
    requestGroups () {
      this.$http.get(xHTTPx + '/get_groups').then(response => {
        var resp = response.body
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var groups = {}
        resp[0].forEach(function(g){
          g.owner = userMap[g.ownerId]
          g.involved = []
          groups[g.id] = g
        })
        resp[1].forEach(function(m){
          var g = groups[m.groupId]
          m.user = userMap[m.userId]
          g.involved.push(m)
        })
        this.$store.commit('groups/setGroups', groups)
      }, response => {
        this.error = 'Failed to get groups!'
      })
    },
  },
  mounted () {
    this.requestGroupMembers()
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

</style>
