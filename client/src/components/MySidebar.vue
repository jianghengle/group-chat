<template>
  <div>
    <aside class="menu">
      <ul class="menu-list">
        <li>
          <a :class="{'is-active': routePath=='/user'}" @click="switchRoute('/user')">
            <span class="icon">
              <v-icon name="user"/>
            </span>
            {{fullName}}
            <span class="icon is-small sign-out-icon" @click.stop="signOut">
              <v-icon name="sign-out-alt"/>
            </span>
          </a>
        </li>
        <hr class="separator"/>
        <li>
          <a :class="{'is-active': routePath=='/public_groups'}" @click="switchRoute('/public_groups')">
            <span class="icon">
              <v-icon name="search"/>
            </span>
            Search Groups
          </a>
        </li>
        <li>
          <div>
            <a :class="{'is-active': routePath=='/' || routePath=='/add_group'}" @click="switchRoute('/')">
              <span>
                <span class="icon">
                  <v-icon name="user-friends"/>
                </span>
                My Groups
                <span class="icon is-small plus-icon" @click.stop="switchRoute('/add_group')">
                  <v-icon name="plus"/>
                </span>
              </span>
           </a>
          </div>
          <ul v-if="groups.length" class="sub-menu">
            <li v-for="g in groups" :key="'nav-group-'+g.id">
              <a :class="{'is-active': groupId==g.id, 'has-text-weight-bold': (g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))}"
                @click="switchRoute('/group/' + g.id)">{{g.name}}
                <span class="icon" v-if="(g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))">
                  <v-icon name="comment-dots"/>
                </span>
              </a>
            </li>
          </ul>
        </li>
        <li>
          <a>
            <span class="icon">
              <v-icon name="comments"/>
            </span>
            Direct Messages
          </a>
          <ul v-if="conversations.length" class="sub-menu">
            <li v-for="g in conversations" :key="'nav-group-'+g.id">
              <a :class="{'is-active': groupId==g.id, 'has-text-weight-bold': (g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))}"
                @click="switchRoute('/group/' + g.id)">{{g.name == '__' ? 'Yourself Only!' : g.name}}
                <span class="icon" v-if="(g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))">
                  <v-icon name="comment-dots"/>
                </span>
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </aside>
  </div>
</template>

<script>
import Vue from 'vue'

export default {
  name: 'my-sidebar',
  data () {
    return {
      addChildModal: {
        opened: false
      },
    }
  },
  computed: {
    fullName () {
      return this.$store.state.user.fullName
    },
    routePath () {
      return this.$route.path
    },
    groupId () {
      return this.$route.params.groupId
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    groups () {
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return (g && (g.category != 'conversation'))
      })
    },
    conversations () {
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return (g && (g.category == 'conversation'))
      }).sort(function(a, b){
        return a.timestamp - b.timestamp
      })
    }
  },
  methods: {
    switchRoute (route) {
      if(this.isMobile){
        this.closeSidebar()
      }
      if(this.routePath != route){
        this.$router.push(route)
      }
    },
    closeSidebar () {
      this.$store.commit('ui/setShowSidebar', false)
    },
    signOut () {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Sign Out',
        message: 'Are you sure to sign out?',
        button: 'Yes, I am sure!',
        callback: {
          method: this.signOutConfirmed,
          context: this,
          args: []
        }
      })
    },
    signOutConfirmed () {
      delete Vue.http.headers.common['Authorization']
      this.$store.commit('user/reset')
      this.$store.commit('groups/reset')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.sign-out-icon {
  margin-left: 15px;
  position: relative;
  top: 2px;
}

.plus-icon {
  margin-left: 15px;
  position: relative;
  top: 2px;
}

.close-button {
  float: right;
  position: relative;
  top: -20px;
  right: 10px;
}

.sub-menu {
  margin-top: 0px;
  margin-bottom: 0px;
  margin-left: 25px;
}

.separator {
  margin-top: 6px;
  margin-bottom: 10px;
}

</style>
