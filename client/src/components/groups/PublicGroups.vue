<template>
  <div>
    <div :class="{'mobile-body': isMobile, 'desktop-body': !isMobile}">
      <div class="has-text-centered" v-if="waiting">
        <v-icon name="spinner" class="icon fa-spin"></v-icon>
      </div>
      <div v-else>
        <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <div v-if="!publicGroups.length">No public group found yet.</div>
        <div v-else>
          <div class="columns is-multiline">
            <div v-for="g in publicGroups" class="column is-half">
              <div class="box" :class="{'clickable': groups[g.id]}" @click="groups[g.id] && openGroup(g.id)">
                <a class="button is-link join-button" v-if="!groups[g.id]" @click.stop="joinGroup(g)">Join</a>
                <article class="media">
                  <div class="media-content">
                    <div class="content">
                      <p>
                        <strong>{{g.name}}</strong> <br/>
                        <small> {{g.owner.fullName}} &nbsp; | &nbsp; {{g.membershipCount}} </small> <br/>
                        {{g.description}}
                      </p>
                    </div>
                  </div>
                </article>
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
  name: 'public-groups',
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
    isMobile () {
      return this.$store.state.ui.isMobile
    },
  },
  methods: {
    requestPublicGroups () {
      this.waiting = true
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
          return g
        })
      }, response => {
        this.error = 'Failed to get public groups!'
        this.waiting= false
      })
    },
    joinGroup (group) {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Enroll Activity',
        message: 'Are you sure to join this group: ' + group.name + '?',
        button: 'Yes, I am sure!',
        callback: {
          method: this.joinGroupConfirmed,
          context: this,
          args: [group]
        }
      })
    },
    joinGroupConfirmed (group) {
      var message = {userId: this.userId}
      this.$http.post(xHTTPx + '/join_group/' + group.id, message).then(response => {
        this.waiting= false
        this.error = ''
        this.openGroup(group.id)
      }, response => {
        this.error = 'Failed to enroll!'
        this.waiting= false
      })
    },
    openGroup (groupId) {
      this.$http.get(xHTTPx + '/get_group/' + groupId).then(response => {
        var group = response.body
        this.$store.commit('groups/updateGroup', group)
        this.$nextTick(function(){
          this.$router.push('/group/' + groupId)
        })
      })
    },
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

.join-button {
  float: right;
}

.desktop-body {
  margin-top: 50px;
  padding: 20px;
}

.mobile-body {
  margin-top: 40px;
  padding: 10px;
}

</style>
