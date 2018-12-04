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
        <div v-if="!myGroups.length">No group you are involved yet.</div>
        <div v-else>
          <div v-for="g in myGroups" class="group-box">
            <div class="box clickable" @click="openGroup(g.id)">
              <article class="media">
                <div class="media-content">
                  <div class="content">
                    <p>
                      <small class="group-note">
                        <span>{{g.owner.fullName}}</span> &nbsp; | &nbsp; 
                        <span>{{g.membershipCount}} people</span>
                      </small>
                      <strong>{{g.name}} </strong>
                      <span class="icon" v-if="(groups[g.id] && groups[g.id].timestamp && (!groups[g.id].userTimestamp || groups[g.id].userTimestamp < groups[g.id].timestamp))">
                        <v-icon name="comment-dots"/>
                      </span>
                      <br/>
                      <small>{{g.latestMessage}}</small>
                    </p>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </div>

        <div class="field is-grouped">
          <div class="control">
            <button class="button is-link" @click="addGroup">New Group</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'my-groups',
  data () {
    return {
      waiting: false,
      error: '',
      myGroups: []
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    groups () {
      return this.$store.state.groups.groups
    },
  },
  methods: {
    requestMyGroups () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_my_groups').then(response => {
        var resp = response.body
        var userMap = {}
        resp[2].forEach(function(u){
          userMap[u.id] = u
        })
        var chatMap = {}
        resp[1].forEach(function(c){
          c.user = userMap[c.userId]
          chatMap[c.groupId] = c
        })
        this.myGroups = resp[0].map(function(g){
          g.owner = userMap[g.ownerId]
          g.latestChat = chatMap[g.id]
          if(g.latestChat){
            var latestMessage = g.latestChat.message ? g.latestChat.message : "..."
            g.latestMessage = g.latestChat.user.fullName + ": " + latestMessage
          }
          return g
        })
        console.log(this.myGroups)
        this.waiting= false
        this.error = ''
      }, response => {
        this.error = 'Failed to get public groups!'
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
    addGroup () {
      this.$router.push('/add_group')
    }
  },
  mounted () {
    this.$nextTick(function(){
      this.requestMyGroups ()
    })
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.desktop-body {
  margin-top: 50px;
  padding: 20px;
}

.mobile-body {
  margin-top: 40px;
  padding: 10px;
}

.group-box {
  margin-bottom: 20px;
}

.group-note {
  float: right;
}

</style>
