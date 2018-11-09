<template>
  <div>
    <div class="is-size-4 has-text-weight-bold section-header">
      Search Activities
    </div>
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    <div v-else>
      <div v-if="error" class="notification is-danger login-text">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div v-if="!publicGroups.length">No activity found yet.</div>
      <div v-else>
        <div class="columns is-multiline">
          <div v-for="g in publicGroups" class="column is-half">
            <div class="box">
              <article class="media">
                <div class="media-content">
                  <div class="content">
                    <p>
                      <strong>{{g.name}}</strong><br/>
                      <small>{{g.category}} by {{g.owner.firstName + ' ' + g.owner.lastName}}</small><br/>
                      <small>{{g.description}}</small><br/>
                      <small>Enrolled: {{g.membershipCount}} &nbsp; | &nbsp; Capacity: {{g.capacity}}</small>
                    </p>
                  </div>
                </div>
              </article>
              <div class="dropdown enroll-dropdown" :class="{'is-active': g.dropdown}" v-if="g.enroll == 'open' && g.membershipCount < g.capacity">
                <div class="dropdown-trigger">
                  <button class="button" aria-haspopup="true" aria-controls="dropdown-menu" @click="g.dropdown=!g.dropdown">
                    <span>Enroll</span>
                    <span class="icon is-small">
                      <v-icon name="angle-down" aria-hidden="true"></v-icon>
                    </span>
                  </button>
                </div>
                <div class="dropdown-menu" id="dropdown-menu" role="menu">
                  <div class="dropdown-content">
                    <a class="dropdown-item" v-for="child in children" v-show="!myEnrollments[g.id] || !myEnrollments[g.id].includes(child.childId)" @click="enrollGroup(g, child.child)">
                      {{child.child.firstName + ' ' + child.child.lastName}}
                    </a>
                    <a class="dropdown-item" v-show="!myEnrollments[g.id] || !myEnrollments[g.id].includes(parseInt(userId))" @click="enrollGroup(g)">
                      Myself
                    </a>
                  </div>
                </div>
              </div>
              <div class="dropdown enroll-dropdown" :class="{'is-active': g.dropdown}" v-if="g.enroll == 'request'"">
                <div class="dropdown-trigger">
                  <button class="button" aria-haspopup="true" aria-controls="dropdown-menu" @click="g.dropdown=!g.dropdown">
                    <span>Request to Enroll</span>
                    <span class="icon is-small">
                      <v-icon name="angle-down" aria-hidden="true"></v-icon>
                    </span>
                  </button>
                </div>
                <div class="dropdown-menu" id="dropdown-menu" role="menu">
                  <div class="dropdown-content">
                    <a class="dropdown-item" v-for="child in children" v-show="!myEnrollments[g.id] || !myEnrollments[g.id].includes(child.childId)" @click="requestEnrollGroup(g, child.child)">
                      {{child.child.firstName + ' ' + child.child.lastName}}
                    </a>
                    <a class="dropdown-item" v-show="!myEnrollments[g.id] || !myEnrollments[g.id].includes(parseInt(userId))" @click="requestEnrollGroup(g)">
                      Myself
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'public-groups-section',
  data () {
    return {
      waiting: false,
      error: '',
      publicGroups: []
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    groups () {
      return this.$store.state.groups.groups
    },
    children () {
      return this.$store.state.children.children
    },
    myEnrollments () {
      var enrollments = {}
      Object.values(this.groups).forEach(function(g){
        var ids = g.involved.map(function(m){
          return m.userId
        })
        enrollments[g.id] = ids
      })    
      return enrollments
    }
  },
  methods: {
    requestPublicGroups () {
      this.$http.get(xHTTPx + '/get_public_groups').then(response => {
        this.waiting= false
        this.error = ''
        var resp = response.body
        var userMap = {}
        resp[1].forEach(function(u){
          userMap[u.id] = u
        })
        this.publicGroups = resp[0].map(function(g){
          g.owner = userMap[g.ownerId]
          g.dropdown = false
          return g
        })
      }, response => {
        this.error = 'Failed to get public groups!'
        this.waiting= false
      })
    },
    enrollGroup (group, user) {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Enroll Activity',
        message: 'Are you sure to enroll this activity: ' + group.name + ' for user: ' + (user ? (user.firstName + ' ' + user.lastName) : 'yourself'),
        button: 'Yes, I am sure!',
        callback: {
          method: this.enrollGroupConfirmed,
          context: this,
          args: [group, user]
        }
      })
    },
    enrollGroupConfirmed (group, user) {
      var message = {userId: user ? user.id : this.userId}
      this.$http.post(xHTTPx + '/enroll_group/' + group.id, message).then(response => {
        this.waiting= false
        this.error = ''
        this.requestGroups()
        this.requestPublicGroups()
      }, response => {
        this.error = 'Failed to enroll!'
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
    requestEnrollGroup (group, user) {
      console.log('request to enroll')
    }
  },
  mounted () {
    this.$nextTick(function(){
      this.requestPublicGroups ()
    })
  }

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.section-header {
  margin-bottom: 10px;
}

.enroll-dropdown {
  margin-top: 5px;
}

</style>
