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
          </a>
        </li>
        <li>
          <a :class="{'is-active': routePath=='/'}" @click="switchRoute('/')">
            <span class="icon">
              <v-icon name="search"/>
            </span>
            Search Groups
          </a>
        </li>
        <li>
          <div>
            <a :class="{'is-active': routePath=='/add_group'}" @click="switchRoute('/add_group')">
              <span>
                <span class="icon">
                  <v-icon name="user-friends"/>
                </span>
                My Groups
                <span class="icon">
                  <v-icon name="plus" class="plus-icon"/>
                </span>
              </span>
           </a>
          </div>
          <ul v-if="groups.length" class="sub-menu">
            <li v-for="g in groups" :key="'nav-group-'+g.id">
              <a :class="{'is-active': routePath=='/group/' + g.id, 'has-text-weight-bold': (g.timestamp && (!g.userTimestamp || g.userTimestamp < g.timestamp))}"
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
        </li>
      </ul>
    </aside>
  </div>
</template>

<script>


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
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    groups () {
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return g
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
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.plus-icon {
  height: 12px;
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

</style>
